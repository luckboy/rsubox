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
use std::fs;
use std::os::unix::fs::FileTypeExt;
use std::os::unix::fs::MetadataExt;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::slice::*;
use users::get_effective_uid;
use users::get_effective_gid;
use crate::utils::*;

#[derive(PartialEq)]
enum FileCondition
{
    BlockDevice,
    CharDevice,
    Directory,
    Existent,
    File,
    GroupIdFlag,
    Symlink,
    Fifo,
    Readable,
    Socket,
    SizeGreaterThanZero,
    UserIdFlag,
    Writable,
    Executable,
}

enum AccessMode
{
    Read,
    Write,
    Execute,
}

fn next_arg<'a>(arg_iter: &mut PushbackIter<Iter<'a, String>>) -> Option<(&'a str, &'a String)>
{ arg_iter.next().map(|s| (s.as_str(), s)) }

fn get_integer_from_string(s: &String) -> Option<i64>
{
    match s.parse::<i64>() {
        Ok(x)    => Some(x),
        Err(err) => {
            eprintln!("{}", err);
            None
        },
    }
}

fn get_fd_from_string(s: &String) -> Option<i32>
{
    match s.parse::<i32>() {
        Ok(x)    => Some(x),
        Err(err) => {
            eprintln!("{}", err);
            None
        },
    }
}

fn next_string(arg_iter: &mut PushbackIter<Iter<'_, String>>) -> Option<String>
{
    match next_arg(arg_iter) {
        Some((_, s)) => Some(s.clone()),
        None         => {
            eprintln!("No argument");
            None
        },
    }
}

fn next_integer(arg_iter: &mut PushbackIter<Iter<'_, String>>) -> Option<i64>
{
    match next_arg(arg_iter) {
        Some((_, s)) => get_integer_from_string(s),
        None         => {
            eprintln!("No argument");
            None
        },
    }
}

fn next_fd(arg_iter: &mut PushbackIter<Iter<'_, String>>) -> Option<i32>
{
    match next_arg(arg_iter) {
        Some((_, s)) => get_fd_from_string(s),
        None         => {
            eprintln!("No argument");
            None
        },
    }
}

fn is_group_member(gid: gid_t) -> bool
{
    match getgroups() {
        Ok(groups) => groups.into_iter().any(|gid2| gid == gid2),
        Err(_)     => false
    }
}

fn test_access(metadata: &fs::Metadata, mode: AccessMode) -> bool
{
    let euid = get_effective_uid(); 
    if euid == 0 {
        match mode {
            AccessMode::Read | AccessMode::Write => return true,
            AccessMode::Execute => return (metadata.permissions().mode() & 0o111) != 0,
        }
    };
    let perms = match mode {
        AccessMode::Read  => 4,
        AccessMode::Write => 2,
        AccessMode::Execute => 1,
    };
    if euid == metadata.uid() as uid_t {
        (metadata.permissions().mode() & (perms << 6)) != 0
    } else if get_effective_gid() == metadata.gid() as gid_t || is_group_member(metadata.gid() as gid_t) {
        (metadata.permissions().mode() & (perms << 3)) != 0
    } else {
        (metadata.permissions().mode() & perms) != 0
    }
}

fn test_file<P: AsRef<Path>>(cond: FileCondition, path: P) -> bool
{
    let metadata = if  cond == FileCondition::Symlink {
        fs::symlink_metadata(path)
    } else {
        fs::metadata(path)
    };
    match metadata {
        Ok(metadata) => {
            match cond {
                FileCondition::BlockDevice         => metadata.file_type().is_block_device(),
                FileCondition::CharDevice          => metadata.file_type().is_char_device(),
                FileCondition::Directory           => metadata.file_type().is_dir(),
                FileCondition::Existent            => true,
                FileCondition::File                => metadata.file_type().is_file(),
                FileCondition::GroupIdFlag         => (metadata.permissions().mode() & 0o2000) != 0,
                FileCondition::Symlink             => metadata.file_type().is_symlink(),
                FileCondition::Readable            => test_access(&metadata, AccessMode::Read),
                FileCondition::Fifo                => metadata.file_type().is_fifo(),
                FileCondition::Socket              => metadata.file_type().is_socket(),
                FileCondition::SizeGreaterThanZero => metadata.size() > 0,
                FileCondition::UserIdFlag          => (metadata.permissions().mode() & 0o4000) != 0,
                FileCondition::Writable            => test_access(&metadata, AccessMode::Write),
                FileCondition::Executable          => test_access(&metadata, AccessMode::Execute),
            }
        },
        Err(_) => false,
    }
}

fn parse_and_test4(arg_iter: &mut PushbackIter<Iter<'_, String>>) -> Option<bool>
{
    match next_arg(arg_iter) {
        Some(("(", _)) => { 
            let res = parse_and_test1(arg_iter, true, false)?;
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
        Some(("-b", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::BlockDevice, path))
        },
        Some(("-c", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::CharDevice, path))
        },
        Some(("-d", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::Directory, path))
        },
        Some(("-e", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::Existent, path))
        },
        Some(("-f", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::File, path))
        },
        Some(("-g", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::GroupIdFlag, path))
        },
        Some(("-h" | "-L", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::Symlink, path))
        },
        Some(("-n", _)) => {
            let s = next_string(arg_iter)?;
            Some(s.len() > 0)
        },
        Some(("-p", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::Fifo, path))
        },
        Some(("-r", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::Readable, path))
        },
        Some(("-S", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::Socket, path))
        },
        Some(("-s", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::SizeGreaterThanZero, path))
        },
        Some(("-t", _)) => {
            let fd = next_fd(arg_iter)?;
            match isatty(fd) {
                Ok(res) => Some(res),
                Err(_)  => Some(false),
            }
        },
        Some(("-u", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::UserIdFlag, path))
        },
        Some(("-w", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::Writable, path))
        },
        Some(("-x", _)) => {
            let path = next_string(arg_iter)?;
            Some(test_file(FileCondition::Executable, path))
        },
        Some(("-z", _)) => {
            let s = next_string(arg_iter)?;
            Some(s.len() == 0)
        },
        Some((_, s)) => {
            match next_arg(arg_iter) {
                Some(("=", _)) => {
                    let t = next_string(arg_iter)?;
                    Some(s == &t)
                },
                Some(("!=", _)) => {
                    let t = next_string(arg_iter)?;
                    Some(s != &t)
                },
                Some(("-eq", _)) => {
                    let x = get_integer_from_string(&s)?;
                    let y = next_integer(arg_iter)?;
                    Some(x == y)
                },
                Some(("-ne", _)) => {
                    let x = get_integer_from_string(&s)?;
                    let y = next_integer(arg_iter)?;
                    Some(x == y)
                },
                Some(("-lt", _)) => {
                    let x = get_integer_from_string(&s)?;
                    let y = next_integer(arg_iter)?;
                    Some(x < y)
                },
                Some(("-ge", _)) => {
                    let x = get_integer_from_string(&s)?;
                    let y = next_integer(arg_iter)?;
                    Some(x >= y)
                },
                Some(("-gt", _)) => {
                    let x = get_integer_from_string(&s)?;
                    let y = next_integer(arg_iter)?;
                    Some(x > y)
                },
                Some(("-le", _)) => {
                    let x = get_integer_from_string(&s)?;
                    let y = next_integer(arg_iter)?;
                    Some(x <= y)
                },
                Some((_, t)) => {
                    arg_iter.undo(t);
                    Some(!s.is_empty())
                },
                None => Some(!s.is_empty()),
            }
        },
        None => {
            eprintln!("No argument");
            None
        },
    }
}

fn parse_and_test3(arg_iter: &mut PushbackIter<Iter<'_, String>>) -> Option<bool>
{
    let mut b = false;
    loop {
        match next_arg(arg_iter) {
            Some(("!", _)) => b ^= true,
            Some((_, s))   => {
                arg_iter.undo(s);
                break;
            },
            None           => {
                eprintln!("Syntax error");
                return None;
            },
        }
    }
    let res = parse_and_test4(arg_iter)?;
    Some(res ^ b)
}

fn parse_and_test2(arg_iter: &mut PushbackIter<Iter<'_, String>>, in_paren: bool, in_bracket: bool) -> Option<bool>
{
    let mut res = parse_and_test3(arg_iter)?;
    loop {
        match next_arg(arg_iter) {
            Some(("-a", _)) => {
                let arg2 = parse_and_test3(arg_iter)?;
                res &= arg2;
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some(("]", s)) => {
                if in_bracket {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, s)) => {
                arg_iter.undo(s);
                break Some(res)
            },
            None => break Some(res),
        }
    }
}

fn parse_and_test1(arg_iter: &mut PushbackIter<Iter<'_, String>>, in_paren: bool, in_bracket: bool) -> Option<bool>
{
    let mut res = parse_and_test2(arg_iter, in_paren, in_bracket)?;
    loop {
        match next_arg(arg_iter) {
            Some(("-o", _)) => {
                let arg2 = parse_and_test2(arg_iter, in_paren, in_bracket)?;
                res |= arg2;
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some(("]", s)) => {
                if in_bracket {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, _)) => {
                eprintln!("Syntax error");
                break None
            },
            None => break Some(res),
        }
    }
}

fn parse_and_test(args: &[String]) -> Option<bool>
{
    let mut arg_iter = PushbackIter::new(args.iter());
    let applet_name = match arg_iter.next() {
        Some(applet_path) => Path::new(applet_path).file_name(),
        None              => None,
    };
    match applet_name.map(|a| a.to_str().unwrap()) {
        Some("[") => {
            match next_arg(&mut arg_iter) {
                Some(("]", _)) => {
                    match next_arg(&mut arg_iter) {
                        Some(_) => {
                            eprintln!("Syntax error");
                            None
                        },
                        None => Some(false),
                    }
                },
                Some((_, s)) => {
                    arg_iter.undo(s);
                    let res = parse_and_test1(&mut arg_iter, false, true)?;
                    match next_arg(&mut arg_iter) {
                        Some(("]", _)) => {
                            match next_arg(&mut arg_iter) {
                                Some(_) => {
                                    eprintln!("Syntax error");
                                    None
                                },
                                None => Some(res),
                            }
                        },
                        Some((_, _)) | None => {
                            eprintln!("Unclosed bracket");
                            None
                        }
                    }
                },
                None => {
                    eprintln!("Unclosed bracket");
                    None
                },
            }
        }
        Some(_) => parse_and_test1(&mut arg_iter, false, false),    
        None => {
            eprintln!("No applet name");
            None
        },
    }
}

pub fn main(args: &[String]) -> i32
{
    match parse_and_test(args) {
        Some(true) => 0,
        Some(false) => 1,
        None => 2,
    }
}
