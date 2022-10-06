//
// Rsubox - Rust single unix utilities in one executable.
// Copyright (C) 2022 Łukasz Szpakowski
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
use std::cell::*;
use std::ffi::*;
use std::fs;
use std::fmt;
use std::iter::*;
use std::os::unix::fs::FileTypeExt;
use std::os::unix::fs::MetadataExt;
use std::os::unix::fs::PermissionsExt;
use std::path::*;
use std::process::*;
use std::rc::*;
use std::slice;
use std::str;
use std::time::SystemTime;
use getopt::Opt;
use users::get_user_by_name;
use users::get_group_by_name;
use users::get_user_by_uid;
use users::get_group_by_gid;
use crate::utils::*;

struct Options
{
    do_flag: DoFlag,
}

enum SignedNumber<T>
{
    Plus(T),
    None(T),
    Minus(T),
}

enum FileType
{
    BlockDevice,
    CharDevice,
    Directory,
    File,
    Symlink,
    Fifo,
    Socket,
}

struct ExecPlusData
{
    prog: OsString,
    args: Vec<OsString>,
}

enum Expression
{
    Name(OsString),
    NoUser,
    NoGroup,
    XDev,
    Prune,
    Perm(u32),
    PermMinus(u32),
    Type(FileType),
    Links(SignedNumber<u64>),
    User(uid_t),
    Group(gid_t),
    BlockUnitSize(SignedNumber<u64>),
    ByteUnitSize(SignedNumber<u64>),
    ATime(SignedNumber<i64>),
    CTime(SignedNumber<i64>),
    MTime(SignedNumber<i64>),
    Exec(String, Vec<String>),
    ExecPlus(String, Vec<String>, Rc<RefCell<Option<ExecPlusData>>>),
    Ok(String, Vec<String>),
    Print,
    Newer(PathBuf),
    Depth,
    Not(Box<Expression>),
    And(Box<Expression>, Box<Expression>),
    Or(Box<Expression>, Box<Expression>),
}

struct ExpressionOptions
{
    cross_device_flag: bool,
    pruning_flag: bool,
    printing_flag: bool,
    depth_flag: bool,
    exec_plus_data_vec: Vec<Rc<RefCell<Option<ExecPlusData>>>>
}

fn next_arg<'a>(arg_iter: &mut PushbackIter<Skip<slice::Iter<'a, String>>>) -> Option<(&'a str, &'a String)>
{ arg_iter.next().map(|s| (s.as_str(), s)) }

fn parse_signed_number<T: str::FromStr>(s: &str) -> Option<SignedNumber<T>>
    where <T as str::FromStr>::Err: fmt::Display
{
    if s.starts_with('+') {
        match (&s[1..]).parse::<T>() {
            Ok(n)    => Some(SignedNumber::Plus(n)),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    } else if s.starts_with('-') {
        match (&s[1..]).parse::<T>() {
            Ok(n)    => Some(SignedNumber::Minus(n)),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    } else {
        match s.parse::<T>() {
            Ok(n)    => Some(SignedNumber::None(n)),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    }
}

fn compare_signed_number<T: PartialOrd>(x: T, n: &SignedNumber<T>) -> bool
{
    match n {
        SignedNumber::Plus(y)  => x > *y,
        SignedNumber::None(y)  => x == *y,
        SignedNumber::Minus(y) => x < *y,
    }
}

fn time_to_days(time: i64) -> i64
{
    let now = match SystemTime::now().duration_since(SystemTime::UNIX_EPOCH) {
        Ok(duration) => duration.as_secs() as i64,
        Err(_)       => 0,
    };
    (now - time) / (24 * 60 * 60)
}

fn replace_exec_args<S: AsRef<OsStr>>(args: &[String], name: S) -> Vec<OsString>
{ args.iter().map(|a| { OsString::from(a.replace("{}", name.as_ref().to_string_lossy().into_owned().as_str()).as_str()) }).collect() }

fn check_exec_plus(args: &[String]) -> bool
{
    if args.iter().all(|a| !a.contains("{}")) {
        true
    } else {
        eprintln!("Only one occurrence of {{}} is supported");
        false
    }
}

fn spawn_command(prog: &OsString, args: &[OsString]) -> (bool, bool)
{
    let mut cmd = Command::new(prog);
    cmd.args(args);
    match cmd.status() {
        Ok(status) => (status.success(), true),
        Err(err)   => {
            eprintln!("{}: {}", prog.to_string_lossy(), err);
            (false, false)
        },
    }
}

fn parse4(arg_iter: &mut PushbackIter<Skip<slice::Iter<'_, String>>>) -> Option<Expression>
{
    match next_arg(arg_iter) {
        Some(("(", _)) => {
            let res = parse1(arg_iter, true)?;
            match next_arg(arg_iter) {
                Some((")", _)) => Some(res),
                Some((_, _))   => {
                    eprintln!("Syntax error");
                    None
                },
                None           => {
                    eprintln!("Unclosed parentheses");
                    None
                },
            }
        },
        Some(("-name", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => Some(Expression::Name(OsString::from(s))),
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-nouser", _)) => Some(Expression::NoUser),
        Some(("-nogroup", _)) => Some(Expression::NoGroup),
        Some(("-xdev", _)) => Some(Expression::XDev),
        Some(("-prune", _)) => Some(Expression::Prune),
        Some(("-perm", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => {
                    if s.starts_with('-') {
                        match Mode::parse(&s[1..]) {
                            Some(mode) => Some(Expression::PermMinus(mode.change_mode(0, false))),
                            None       => {
                                eprintln!("Invalid mode");
                                None
                            },
                        }
                    } else {
                        match Mode::parse(s) {
                            Some(mode) => Some(Expression::Perm(mode.change_mode(0, false))),
                            None       => {
                                eprintln!("Invalid mode");
                                None
                            },
                        }
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-type", _)) => {
            match next_arg(arg_iter) {
                Some(("b", _)) => Some(Expression::Type(FileType::BlockDevice)),
                Some(("c", _)) => Some(Expression::Type(FileType::CharDevice)),
                Some(("d", _)) => Some(Expression::Type(FileType::Directory)),
                Some(("f", _)) => Some(Expression::Type(FileType::File)),
                Some(("l", _)) => Some(Expression::Type(FileType::Symlink)),
                Some(("p", _)) => Some(Expression::Type(FileType::Fifo)),
                Some(("s", _)) => Some(Expression::Type(FileType::Socket)),
                Some((_, _))   => {
                    eprintln!("Invalit file type");
                    None
                },
                None                 => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-links", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => {
                    match parse_signed_number::<u64>(s) {
                        Some(n) => Some(Expression::Links(n)),
                        None    => None,
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-user", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => {
                    match s.parse::<uid_t>() {
                        Ok(uid) => Some(Expression::User(uid)),
                        Err(_)  => {
                            match get_user_by_name(s) {
                                Some(user) => Some(Expression::User(user.uid())),
                                None       => {
                                    eprintln!("Invalid user");
                                    None
                                },
                            }
                        },
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-group", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => {
                    match s.parse::<gid_t>() {
                        Ok(gid) => Some(Expression::Group(gid)),
                        Err(_)  => {
                            match get_group_by_name(s) {
                                Some(group) => Some(Expression::Group(group.gid())),
                                None        => {
                                    eprintln!("Invalid group");
                                    None
                                },
                            }
                        },
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-size", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => {
                    if s.ends_with('c') {
                        match parse_signed_number::<u64>(&s[0..(s.len() - 1)]) {
                            Some(n) => Some(Expression::ByteUnitSize(n)),
                            None    => None,
                        }
                    } else {
                        match parse_signed_number::<u64>(s) {
                            Some(n) => Some(Expression::BlockUnitSize(n)),
                            None    => None,
                        }
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-atime", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => {
                    match parse_signed_number::<i64>(s) {
                        Some(n) => Some(Expression::ATime(n)),
                        None    => None,
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-ctime", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => {
                    match parse_signed_number::<i64>(s) {
                        Some(n) => Some(Expression::CTime(n)),
                        None    => None,
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-mtime", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => {
                    match parse_signed_number::<i64>(s) {
                        Some(n) => Some(Expression::MTime(n)),
                        None    => None,
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-exec", _)) => {
            match next_arg(arg_iter) {
                Some((_, exec_prog)) => {
                    let mut exec_args: Vec<String> = Vec::new();
                    loop {
                        match next_arg(arg_iter) {
                            Some(("{}", arg)) => {
                                match next_arg(arg_iter) {
                                    Some(("+", _)) => {
                                        if !check_exec_plus(exec_args.as_slice()) {
                                            break None;
                                        }
                                        break Some(Expression::ExecPlus(exec_prog.clone(), exec_args, Rc::new(RefCell::new(None))));
                                    },
                                    Some((_, s)) => {
                                        arg_iter.undo(s);
                                        exec_args.push(arg.clone());
                                    },
                                    None => {
                                        eprintln!("No argument");
                                        break None;
                                    }
                                }
                            },
                            Some((";", _)) => {
                                break Some(Expression::Exec(exec_prog.clone(), exec_args));
                            },
                            Some((_, arg)) => exec_args.push(arg.clone()),
                            None => {
                                eprintln!("No argument");
                                break None;
                            },
                        }
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        }
        Some(("-ok", _)) => {
            match next_arg(arg_iter) {
                Some((_, exec_prog)) => {
                    let mut exec_args: Vec<String> = Vec::new();
                    loop {
                        match next_arg(arg_iter) {
                            Some((";", _)) => {
                                break Some(Expression::Ok(exec_prog.clone(), exec_args));
                            },
                            Some((_, arg)) => exec_args.push(arg.clone()),
                            None => {
                                eprintln!("No argument");
                                break None;
                            },
                        }
                    }
                },
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-print", _)) => Some(Expression::Print),
        Some(("-newer", _)) => {
            match next_arg(arg_iter) {
                Some((s, _)) => Some(Expression::Newer(PathBuf::from(s))),
                None => {
                    eprintln!("No argument");
                    None
                },
            }
        },
        Some(("-depth", _)) => Some(Expression::Depth),
        _ => {
            eprintln!("Syntax error");
            None
        },
    }
}

fn parse3(arg_iter: &mut PushbackIter<Skip<slice::Iter<'_, String>>>) -> Option<Expression>
{
    match next_arg(arg_iter) {
        Some(("!", _)) => {
            let expr = parse3(arg_iter)?;
            Some(Expression::Not(Box::new(expr)))
        },
        Some((_, s)) => {
            arg_iter.undo(s);
            parse4(arg_iter)
        },
        None => {
            eprintln!("Syntax error");
            None
        },
    }
}

fn parse2(arg_iter: &mut PushbackIter<Skip<slice::Iter<'_, String>>>, in_paren: bool) -> Option<Expression>
{
    let mut expr = parse3(arg_iter)?;
    loop {
        match next_arg(arg_iter) {
            Some(("-a", _)) => {
                let expr2 = parse3(arg_iter)?;
                expr = Expression::And(Box::new(expr), Box::new(expr2));
            },
            Some(("-o", s)) => {
                arg_iter.undo(s);
                break Some(expr);
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(expr)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, s)) => {
                arg_iter.undo(s);
                let expr2 = parse3(arg_iter)?;
                expr = Expression::And(Box::new(expr), Box::new(expr2));
            },
            None => break Some(expr),
        }
    }
}

fn parse1(arg_iter: &mut PushbackIter<Skip<slice::Iter<'_, String>>>, in_paren: bool) -> Option<Expression>
{
    let mut expr = parse2(arg_iter, in_paren)?;
    loop {
        match next_arg(arg_iter) {
            Some(("-o", _)) => {
                let expr2 = parse2(arg_iter, in_paren)?;
                expr = Expression::Or(Box::new(expr), Box::new(expr2));
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(expr)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, _)) => {
                eprintln!("Syntax error");
                break None
            },
            None => break Some(expr),
        }
    }
}

fn parse(arg_iter: &mut PushbackIter<Skip<slice::Iter<'_, String>>>) -> Option<Option<Expression>>
{
    match next_arg(arg_iter) {
        Some((_, s)) => {
            arg_iter.undo(s);
            match parse1(arg_iter, false) {
                Some(expr) => Some(Some(expr)),
                None       => None,
            }
        },
        None => Some(None),
    }
}
fn update_expr_options1(expr: &Expression, expr_opts: &mut ExpressionOptions, is_exec_or_ok_or_print: &mut bool)
{
    match expr {
        Expression::XDev => expr_opts.cross_device_flag = true,
        Expression::Prune => expr_opts.pruning_flag = true,
        Expression::Exec(_, _) => *is_exec_or_ok_or_print = true,
        Expression::ExecPlus(_, _, exec_plus_data) => {
            expr_opts.exec_plus_data_vec.push(exec_plus_data.clone());
            *is_exec_or_ok_or_print = true;
        },
        Expression::Ok(_, _) => *is_exec_or_ok_or_print = true,
        Expression::Print => *is_exec_or_ok_or_print = true,
        Expression::Depth => expr_opts.depth_flag = true,
        Expression::Not(expr1) => update_expr_options1(&(*expr1), expr_opts, is_exec_or_ok_or_print),
        Expression::And(expr1, expr2) => {
            update_expr_options1(&(*expr1), expr_opts, is_exec_or_ok_or_print);
            update_expr_options1(&(*expr2), expr_opts, is_exec_or_ok_or_print);
        },
        Expression::Or(expr1, expr2) => {
            update_expr_options1(&(*expr1), expr_opts, is_exec_or_ok_or_print);
            update_expr_options1(&(*expr2), expr_opts, is_exec_or_ok_or_print);
        },
        _ => (),
    }
}

fn update_expr_options(expr: &Option<Expression>, expr_opts: &mut ExpressionOptions)
{
    let mut is_exec_or_ok_or_print = false;
    match expr {
        Some(expr) => update_expr_options1(expr, expr_opts, &mut is_exec_or_ok_or_print),
        None       => (),
    }
    if is_exec_or_ok_or_print { expr_opts.printing_flag = false; }
}

fn evaluate1<P: AsRef<Path>, S: AsRef<OsStr>>(path: P, metadata: &fs::Metadata, name: S, expr: &Expression, expr_opts: &ExpressionOptions) -> (bool, bool)
{
    match expr {
        Expression::Name(pattern) => (fnmatch(pattern, Path::new(name.as_ref()), 0), true),
        Expression::NoUser => {
            match get_user_by_uid(metadata.uid() as uid_t) {
                Some(_) => (false, true),
                None    => (true, true),
            }
        },
        Expression::NoGroup => {
            match get_group_by_gid(metadata.gid() as gid_t) {
                Some(_) => (false, true),
                None    => (true, true),
            }
        },
        Expression::XDev => (true, true),
        Expression::Prune => (true, true),
        Expression::Perm(mode) => (metadata.permissions().mode() == *mode, true),
        Expression::PermMinus(mode) => ((metadata.permissions().mode() & *mode & 0o7777) == *mode, true),
        Expression::Type(FileType::BlockDevice) => (metadata.file_type().is_block_device(), true),
        Expression::Type(FileType::CharDevice) => (metadata.file_type().is_char_device(), true),
        Expression::Type(FileType::Directory) => (metadata.file_type().is_dir(), true),
        Expression::Type(FileType::File) => (metadata.file_type().is_file(), true),
        Expression::Type(FileType::Symlink) => (metadata.file_type().is_symlink(), true),
        Expression::Type(FileType::Fifo) => (metadata.file_type().is_fifo(), true),
        Expression::Type(FileType::Socket) => (metadata.file_type().is_socket(), true),
        Expression::Links(links) => (compare_signed_number(metadata.nlink(), links), true),
        Expression::User(uid) => (metadata.uid() as uid_t == *uid, true),
        Expression::Group(gid) => (metadata.gid() as gid_t == *gid, true),
        Expression::BlockUnitSize(size) => (compare_signed_number(metadata.size().saturating_add(511) / 512, size), true),
        Expression::ByteUnitSize(size) => (compare_signed_number(metadata.size(), size), true),
        Expression::ATime(days) => (compare_signed_number(time_to_days(metadata.atime()), days), true),
        Expression::CTime(days) => (compare_signed_number(time_to_days(metadata.ctime()), days), true),
        Expression::MTime(days) => (compare_signed_number(time_to_days(metadata.mtime()), days), true),
        Expression::Exec(exec_prog, exec_args) => {
            let prog = OsString::from(exec_prog);
            let args = replace_exec_args(exec_args, path.as_ref());
            spawn_command(&prog, args.as_slice())
        },
        Expression::ExecPlus(exec_prog, exec_args, exec_plus_data) => {
            let mut exec_plus_data_r = exec_plus_data.borrow_mut();
            match &mut (*exec_plus_data_r) {
                Some(exec_plus_data) => exec_plus_data.args.push(OsString::from(path.as_ref())),
                None => {
                    let mut exec_plus_data = ExecPlusData {
                        prog: OsString::from(exec_prog),
                        args: exec_args.iter().map(|a| OsString::from(a)).collect(), 
                    };
                    exec_plus_data.args.push(OsString::from(path.as_ref()));
                    *exec_plus_data_r = Some(exec_plus_data);
                },
            }
            (true, true)
        },
        Expression::Ok(exec_prog, exec_args) => {
            let prog = OsString::from(exec_prog);
            let args = replace_exec_args(exec_args, path.as_ref());
            let msg = if !args.is_empty() {
                format!("{} {}", prog.to_string_lossy(), args.iter().map(|a| a.to_string_lossy().into_owned()).collect::<Vec<String>>().join(" "))
            } else {
                format!("{}", prog.to_string_lossy())
            };
            if ask(msg.as_str()) {
                spawn_command(&prog, args.as_slice())
            } else {
                (false, true)
            }
        },
        Expression::Print => {
            println!("{}", path.as_ref().to_string_lossy());
            (true, true)
        },
        Expression::Newer(path2) => {
            match fs::metadata(path2.as_path()) {
                Ok(metadata2) => (metadata.mtime() > metadata2.mtime(), true),
                Err(err)      => {
                    eprintln!("{}: {}", path2.as_path().to_string_lossy(), err);
                    (false, false)
                },
            }
        },
        Expression::Depth => (true, true),
        Expression::Not(expr1) => {
            let (b, is_success) = evaluate1(path.as_ref(), metadata, name.as_ref(), &(*expr1), expr_opts);
            (!b, is_success)
        },
        Expression::And(expr1, expr2) => {
            let (b1, is_success1) = evaluate1(path.as_ref(), metadata, name.as_ref(), &(*expr1), expr_opts);
            let (b2, is_success2) = if b1 {
                evaluate1(path.as_ref(), metadata, name.as_ref(), &(*expr2), expr_opts)
            } else {
                (false, true)
            };
            (b2, is_success1 & is_success2)
        },
        Expression::Or(expr1, expr2) => {
            let (b1, is_success1) = evaluate1(path.as_ref(), metadata, name.as_ref(), &(*expr1), expr_opts);
            let (b2, is_success2) = if b1 {
                (true, true)
            } else {
                evaluate1(path.as_ref(), metadata, name.as_ref(), &(*expr2), expr_opts)
            };
            (b2, is_success1 & is_success2)
        },
    }
}

fn evaluate<P: AsRef<Path>, S: AsRef<OsStr>>(path: P, metadata: &fs::Metadata, name: S, expr: &Option<Expression>, expr_opts: &ExpressionOptions) -> (bool, bool)
{
    match expr {
        Some(expr) => evaluate1(path.as_ref(), metadata, name.as_ref(), expr, expr_opts),
        None       => (true, true),
    }
}

fn descend_into_dir(metadata: &fs::Metadata, is_name: bool, expr_opts: &ExpressionOptions, fs_dev: &mut Option<u64>) -> bool
{
    if expr_opts.pruning_flag { return false; }
    if expr_opts.cross_device_flag {
        match fs_dev {
            Some(fs_dev) => {
                if metadata.dev() != *fs_dev { return false; }
            },
            None         => {
                if !is_name { *fs_dev = Some(metadata.dev()); }
            },
        }
    }
    true
}

fn find<P: AsRef<Path>>(path: P, metadata: &fs::Metadata, name: Option<&OsStr>, expr: &Option<Expression>, expr_opts: &ExpressionOptions) -> bool
{
    let name = match name {
        Some(tmp_name) => OsString::from(tmp_name),
        None           => {
            let path_s = path.as_ref().to_string_lossy().into_owned();
            let (_, base_name) = dir_name_and_base_name(path_s.as_str(), None);
            OsString::from(base_name)
        },
    };
    let (b, is_success) = evaluate(path.as_ref(), metadata, name.as_os_str(), expr, expr_opts);
    if b && expr_opts.printing_flag {
        println!("{}", path.as_ref().to_string_lossy());
    }
    is_success
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "aHkLsx");
    let mut opts = Options {
        do_flag: DoFlag::NoDereference,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('H', _))) => opts.do_flag = DoFlag::NonRecursiveDereference,
            Some(Ok(Opt('L', _))) => opts.do_flag = DoFlag::RecursiveDereference,
            Some(Ok(Opt(c, _))) => {
                eprintln!("unknown option -- {:?}", c);
                return 1;
            },
            Some(Err(err)) => {
                eprintln!("{}", err);
                return 1;
            },
            None => break,
        }
    }
    let mut status = 0;
    let mut arg_iter = PushbackIter::new(args.iter().skip(opt_parser.index()));
    let dot = String::from(".");
    let mut paths: Vec<&String> = Vec::new();
    loop {
        match next_arg(&mut arg_iter) {
            Some(("!" | "(", s)) => {
                arg_iter.undo(s);
                break;
            },
            Some((_, s)) if s.starts_with('-') => {
                arg_iter.undo(s);
                break;
            },
            Some((_, s)) => paths.push(s),
            None => break,
        }
    }
    if paths.is_empty() { paths = vec![&dot]; }
    let expr = match parse(&mut arg_iter) {
        Some(tmp_expr) => tmp_expr,
        None => return 1,
    };
    let mut expr_opts = ExpressionOptions {
        cross_device_flag: false,
        pruning_flag: false,
        printing_flag: true,
        depth_flag: false,
        exec_plus_data_vec: Vec::new(),
    };
    update_expr_options(&expr, &mut expr_opts);
    for path in &paths {
        let expr_r = &expr;
        let expr_opts_r = &expr_opts;
        let mut fs_dev: Option<u64> = None;
        let fs_dev_r = &mut fs_dev;
        let mut is_success = true;
        let is_success_r = &mut is_success;
        recursively_do(path, opts.do_flag, true, |path, metadata, name, action| {
                match action {
                    DoAction::DirActionBeforeList => {
                        if !expr_opts.depth_flag {
                            if !find(path, metadata, name, expr_r, expr_opts_r) {
                                *is_success_r = false;
                            }
                        }
                        if descend_into_dir(metadata, name.is_some(), expr_opts_r, fs_dev_r) {
                            (true, true)
                        } else {
                            if expr_opts.depth_flag {
                                if !find(path, metadata, name, expr_r, expr_opts_r) {
                                    *is_success_r = false;
                                }
                            }
                            (true, false)
                        }
                    },
                    DoAction::FileAction => {
                        if !find(path, metadata, name, expr_r, expr_opts_r) {
                            *is_success_r = false;
                        }
                        (true, true)
                    },
                    DoAction::DirActionAfterList => {
                        if expr_opts.depth_flag {
                            if !find(path, metadata, name, expr_r, expr_opts_r) {
                                *is_success_r = false;
                            }
                        }
                        (true, true)
                    },
                }
        });
        if !is_success { status = 1; }
    }
    for exec_plus_data in &expr_opts.exec_plus_data_vec {
        let exec_plus_data_r = exec_plus_data.borrow();
        match &(*exec_plus_data_r) {
            Some(exec_plus_data) => {
                let (b, is_success) = spawn_command(&exec_plus_data.prog, exec_plus_data.args.as_slice());
                if !b { status = 1; }
                if !is_success { status = 1; } 
            },
            None => (),
        }
    }
    status
}
