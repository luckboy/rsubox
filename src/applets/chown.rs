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
use std::os::unix::fs::MetadataExt;
use std::path::*;
use getopt::Opt;
use users::get_user_by_name;
use users::get_group_by_name;
use crate::utils::*;

struct Options
{
    lchown_flag: bool,
    recursive_flag: bool,
    do_flag: DoFlag,
}

fn parse_owner_and_group(s: &String) -> Option<(uid_t, Option<gid_t>)>
{
    let (owner, group) = match s.split_once(':') {
        Some((owner, group)) => (owner, Some(group)),
        None => (s.as_str(), None),
    };
    let uid = match owner.parse::<uid_t>() {
        Ok(uid) => uid,
        Err(_)  => {
            match get_user_by_name(owner) {
                Some(user) => user.uid(),
                None       => {
                    eprintln!("Invalid user");
                    return None;
                },
            }
        },
    };
    let gid = match group {
        Some(group) => {
            let gid = match group.parse::<gid_t>() {
                Ok(gid) => gid,
                Err(_)  => {
                    match get_group_by_name(group) {
                        Some(group) => group.gid(),
                        None        => {
                            eprintln!("Invalid group");
                            return None;
                        },
                    }
                }
            };
            Some(gid)
        },
        None => None,
    };
    Some((uid, gid))
}

fn chown_file<P: AsRef<Path>>(path: P, uid_and_gid: (uid_t, Option<gid_t>), opts: &Options) -> bool
{
    let metadata = if opts.lchown_flag {
        fs::symlink_metadata(path.as_ref())
    } else {
        fs::metadata(path.as_ref())
    };
    match metadata {
        Ok(metadata) => {
            let res = if opts.lchown_flag {
                lchown(path.as_ref(), uid_and_gid.0, uid_and_gid.1.unwrap_or(metadata.gid() as gid_t))
            } else {
                chown(path.as_ref(), uid_and_gid.0, uid_and_gid.1.unwrap_or(metadata.gid() as gid_t))
            };
            match res {
                Ok(())   => true,
                Err(err) => {
                    eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                    false
                },
            }
        },
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "HhLPR");
    let mut opts = Options {
        lchown_flag: false,
        recursive_flag: false,
        do_flag: DoFlag::NoDereference,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('H', _))) => opts.do_flag = DoFlag::NonRecursiveDereference,
            Some(Ok(Opt('h', _))) => opts.lchown_flag = true,
            Some(Ok(Opt('L', _))) => opts.do_flag = DoFlag::RecursiveDereference,
            Some(Ok(Opt('P', _))) => opts.do_flag = DoFlag::NoDereference,
            Some(Ok(Opt('R', _))) => opts.recursive_flag = true,
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
    let args: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    if args.len() >= 2 {
        match parse_owner_and_group(args[0]) {
            Some(uid_and_gid) => {
                for path in args.iter().skip(1) {
                    let is_success = if opts.recursive_flag {
                        recursively_do(path, opts.do_flag, true, &mut (|path, _, _, action| {
                                match action {
                                    DoAction::DirActionBeforeList => (true, true),
                                    DoAction::FileAction          => (chown_file(path, uid_and_gid, &opts), true),
                                    DoAction::DirActionAfterList  => (chown_file(path, uid_and_gid, &opts), true),
                                }
                        }))
                    } else {
                        non_recursively_do(path, opts.do_flag, true, true, &mut (|path, _| {
                                chown_file(path, uid_and_gid, &opts)
                        }))
                    };
                    if !is_success { status = 1; } 
                }
            },
            None => status = 1,
        }
    } else {
        eprintln!("Too few arguments");
        status = 1;
    }
    status
}
