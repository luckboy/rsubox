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
use std::fs::*;
use std::io::*;
use std::os::unix::process::ExitStatusExt;
use std::path::*;
use std::process::*;
use getopt::Opt;
use crate::utils::*;

enum CommandFlag
{
    None,
    Replace(String),
    Lines(usize),
    Arguments(usize),
}

struct Options
{
    eof: Option<String>,
    command_flag: CommandFlag,
    prompt_mode_flag: bool,
    size: Option<usize>,
    trace_flag: bool,
    exit_flag: bool,
    question_path_buf: PathBuf,
}

fn replace_args(args: &[String], s: &String, new_s: &String) -> Vec<String>
{ args.iter().map(|a| a.replace(s.as_str(), new_s.as_str())).collect() }

fn get_strings_from_line(s: &str, is_splitting: bool) -> Option<Vec<String>>
{
    let t = s.trim_start();
    let mut char_iter = t.chars();
    let mut ss: Vec<String> = vec![String::new()];
    let mut is_last_s_to_pop = true;
    loop {
        match char_iter.next() {
            Some('\'') => {
                loop {
                    match char_iter.next() {
                        Some('\'') => break,
                        Some(c)    => {
                            let ss_len = ss.len();
                            ss[ss_len - 1].push(c);
                            is_last_s_to_pop = false;
                        },
                        None       => {
                            eprintln!("Unclosed single quote");
                            return None;
                        },
                    }
                }
            },
            Some('"') => {
                loop {
                    match char_iter.next() {
                        Some('"') => break,
                        Some(c)    => {
                            let ss_len = ss.len();
                            ss[ss_len - 1].push(c);
                            is_last_s_to_pop = false;
                        },
                        None       => {
                            eprintln!("Unclosed double quote");
                            return None;
                        },
                    }
                }
            },
            Some(c) if c.is_whitespace() => {
                if is_splitting {
                    if !is_last_s_to_pop {
                        ss.push(String::new());
                        is_last_s_to_pop = true;
                    }
                } else {
                    let ss_len = ss.len();
                    ss[ss_len - 1].push(c);
                    is_last_s_to_pop = false;
                }
            },
            Some(c) => {
                let ss_len = ss.len();
                ss[ss_len - 1].push(c);
                is_last_s_to_pop = false;
            },
            None => break,
        }
    }
    if is_last_s_to_pop { ss.pop(); }
    Some(ss)
}

pub fn ask_for_xargs<P: AsRef<Path>>(prog: &String, args: &[String], path: P) -> bool
{
    loop {
        if !args.is_empty() {
            eprint!("{} {} ?...", prog, args.join(" "));
        } else {
            eprint!("{} ?...", prog);
        }
        match stderr().flush() {
            Ok(()) => {
                match File::open(path.as_ref()) {
                    Ok(file) => {
                        let mut r = LineReader::new(file);
                        let mut line = String::new();
                        match r.read_line(&mut line) {
                            Ok(_)    => {
                                break line.trim().to_lowercase() == String::from("yes") || line.trim().to_lowercase() == String::from("y");
                            },
                            Err(err) => eprintln!("{}", err),
                        }
                    },
                    Err(err) => {
                        eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                        return false;
                    },
                }
            },
            Err(err) => eprintln!("{}", err),
        }
    }
}

fn command_line_len(prog: &String, args: &[String]) -> usize
{ 
    let mut len = prog.len();
    if !args.is_empty() {
        len += args.iter().fold(0usize, |sum, a| sum + a.len() + 1);
    }
    len
}

fn compare_size(prog: &String, args: &[String], args_from_lines: Option<&[String]>, opts: &Options) -> (bool, bool)
{
    match opts.size {
        Some(size) => {
            let mut new_args = Vec::from(args);
            match args_from_lines {
                Some(args_from_lines) => new_args.extend_from_slice(args_from_lines),
                None => (),
            }
            if command_line_len(prog, new_args.as_slice()) >= size {
                eprintln!("Too long command line");
                if opts.exit_flag {
                    return (false, true);
                }
                (false, false)
            } else {
                (true, false)
            }
        },
        None => (true, false),
    }
}

fn trace_command(prog: &String, args: &[String])
{
    eprint!("{}", prog);
    for arg in args.iter() {
        eprint!(" {}", arg);
    }
    eprintln!("");
}

fn spawn_command(prog: &String, args: &[String], opts: &Options) -> i32
{
    let reply = if opts.prompt_mode_flag {
        ask_for_xargs(prog, args, opts.question_path_buf.as_path())
    } else {
        true
    };
    if reply {
        if opts.trace_flag { trace_command(prog, args); }
        let mut cmd = Command::new(prog);
        cmd.args(args);
        match cmd.status() {
            Ok(status) => {
                match status.code() {
                    Some(code) => code,
                    None => {
                        match status.signal() {
                            Some(sig) => sig + 128,
                            None => 128,
                        }
                    },
                }
            },
            Err(err)   => {
                eprintln!("{}: {}", prog, err);
                if err.kind() == ErrorKind::NotFound { 127 } else { 126 }
            },
        }
    } else {
        0
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "E:I:L:n:ps:T:tx");
    let mut opts = Options {
        eof: None,
        command_flag: CommandFlag::None,
        prompt_mode_flag: false,
        size: None,
        trace_flag: false,
        exit_flag: false,
        question_path_buf: PathBuf::from("/dev/tty"),
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('E', Some(opt_arg)))) => opts.eof = Some(opt_arg.clone()),
            Some(Ok(Opt('E', None))) => {
                eprintln!("option requires an argument -- 'E'");
                return 1;
            },
            Some(Ok(Opt('I', Some(opt_arg)))) => opts.command_flag = CommandFlag::Replace(opt_arg.clone()),
            Some(Ok(Opt('I', None))) => {
                eprintln!("option requires an argument -- 'I'");
                return 1;
            },
            Some(Ok(Opt('L', Some(opt_arg)))) => {
                match opt_arg.parse::<usize>() {
                    Ok(0)    => {
                        eprintln!("Number of lines is zero");
                        return 1;
                    },
                    Ok(n)    => opts.command_flag = CommandFlag::Lines(n),
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('L', None))) => {
                eprintln!("option requires an argument -- 'L'");
                return 1;
            },
            Some(Ok(Opt('n', Some(opt_arg)))) => {
                match opt_arg.parse::<usize>() {
                    Ok(0)    => {
                        eprintln!("Number of arguments is zero");
                        return 1;
                    },
                    Ok(n)    => opts.command_flag = CommandFlag::Arguments(n),
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('n', None))) => {
                eprintln!("option requires an argument -- 'n'");
                return 1;
            },
            Some(Ok(Opt('p', _))) => opts.prompt_mode_flag = true,
            Some(Ok(Opt('s', Some(opt_arg)))) => {
                match opt_arg.parse::<usize>() {
                    Ok(0)    => {
                        eprintln!("Size is zero");
                        return 1;
                    },
                    Ok(n)    => opts.size = Some(n),
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('s', None))) => {
                eprintln!("option requires an argument -- 's'");
                return 1;
            },
            Some(Ok(Opt('T', Some(opt_arg)))) => opts.question_path_buf = PathBuf::from(opt_arg),
            Some(Ok(Opt('T', None))) => {
                eprintln!("option requires an argument -- 'T'");
                return 1;
            },
            Some(Ok(Opt('t', _))) => opts.trace_flag = true,
            Some(Ok(Opt('x', _))) => opts.exit_flag = true,
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
    let mut arg_iter = args.iter().skip(opt_parser.index());
    let (prog, args) = match arg_iter.next() {
        Some(tmp_prog) => (tmp_prog.clone(), arg_iter.map(|a| a.clone()).collect::<Vec<String>>()),
        None => (String::from("echo"), Vec::new()),
    };
    let stdin_r = &mut stdin();
    let mut r = BufReader::new(stdin_r);
    let mut args_from_lines: Vec<String> = Vec::new();
    let mut line_count: usize = 0;
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                let is_splitting = match &opts.command_flag {
                    CommandFlag::Replace(_) => false,
                    _ => true,
                };
                match get_strings_from_line(line_without_newline, is_splitting) {
                    Some(mut ss) => {
                        let mut is_eof = false;
                        match &opts.eof {
                            Some(eof) => {
                                let mut ts = Vec::new();
                                for s in &ss {
                                    if s == eof {
                                        is_eof = true;
                                        break;
                                    }
                                    ts.push(s.clone());
                                }
                                ss = ts;
                            },
                            None => (),
                        }
                        if !ss.is_empty() {
                            match &opts.command_flag {
                                CommandFlag::None => {
                                    args_from_lines.extend(ss);
                                    let (is_less, is_exit) = compare_size(&prog, args.as_slice(), Some(args_from_lines.as_slice()), &opts);
                                    if !is_less { args_from_lines = Vec::new(); }
                                    if is_exit { return status; }
                                },
                                CommandFlag::Replace(s) => {
                                    let new_args = replace_args(args.as_slice(), s, &ss[0]);
                                    let (is_less, is_exit) = compare_size(&prog, new_args.as_slice(), None, &opts);
                                    if is_less {
                                        let tmp_status = spawn_command(&prog, new_args.as_slice(), &opts);
                                        if tmp_status != 0 { status = tmp_status; }
                                        args_from_lines = Vec::new();
                                    }
                                    if is_exit { return status; }
                                },
                                CommandFlag::Lines(n) => {
                                    args_from_lines.extend(ss);
                                    let (is_less, is_exit) = compare_size(&prog, args.as_slice(), Some(args_from_lines.as_slice()), &opts);
                                    line_count += 1;
                                    if is_less {
                                        if line_count >= *n {
                                            let mut new_args = args.clone();
                                            new_args.extend_from_slice(args_from_lines.as_slice());
                                            let tmp_status = spawn_command(&prog, new_args.as_slice(), &opts);
                                            if tmp_status != 0 { status = tmp_status; }
                                            args_from_lines = Vec::new();
                                            line_count = 0;
                                        }
                                    } else {
                                        args_from_lines = Vec::new();
                                        line_count = 0;
                                    }
                                    if is_exit { return status; }
                                },
                                CommandFlag::Arguments(n) => {
                                    for s in ss {
                                        args_from_lines.push(s);
                                        let (is_less, is_exit) = compare_size(&prog, args.as_slice(), Some(args_from_lines.as_slice()), &opts);
                                        if is_less {
                                            if args_from_lines.len() >= *n {
                                                let mut new_args = args.clone();
                                                new_args.extend_from_slice(args_from_lines.as_slice());
                                                let tmp_status = spawn_command(&prog, new_args.as_slice(), &opts);
                                                if tmp_status != 0 { status = tmp_status; }
                                                args_from_lines = Vec::new();
                                            }
                                        } else {
                                            args_from_lines = Vec::new();
                                        }
                                        if is_exit { return status; }
                                    }
                                },
                            }
                        }
                        if is_eof { break; }
                    },
                    None => (),
                }
            },
            Err(err) => {
                eprintln!("{}", err);
                return 1;
            },
        }
    }
    match &opts.command_flag {
        CommandFlag::Replace(_) => (),
        _ => {
            if !args_from_lines.is_empty() {
                let mut new_args = args.clone();
                new_args.extend_from_slice(args_from_lines.as_slice());
                let tmp_status = spawn_command(&prog, new_args.as_slice(), &opts);
                if tmp_status != 0 { status = tmp_status; }
            }
        },
    }
    status
}
