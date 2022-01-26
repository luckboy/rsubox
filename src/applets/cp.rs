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
use std::io::*;
use std::fs;
use std::fs::*;
use std::os::unix::fs::MetadataExt;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    interactive_flag: bool,
    preserve_flag: bool,
    recursive_flag: bool,
    do_flag: DoFlag,
}

fn preserve<P: AsRef<Path>>(src_metadata: &fs::Metadata, dst_path: P) -> bool
{
    if src_metadata.file_type().is_symlink() {
        let times = Times {
            atime: TimeValue {
                sec: src_metadata.atime(),
                usec: src_metadata.atime_nsec() / 1000,
            },
            mtime: TimeValue {
                sec: src_metadata.mtime(),
                usec: src_metadata.mtime_nsec() / 1000,
            },
        };
        let _utimes_res = utimes(dst_path.as_ref(), &times);
        let _chown_res = chown(dst_path.as_ref(), src_metadata.uid(), src_metadata.gid());
        match set_permissions(dst_path.as_ref(), src_metadata.permissions()) {
            Ok(())   => true,
            Err(err) => {
                eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
                false
            },
        }
    } else {
        let _lchown_res = lchown(dst_path.as_ref(), src_metadata.uid(), src_metadata.gid());
        true
    }
}

fn are_same_files(metadata1: &fs::Metadata, metadata2: Option<&fs::Metadata>) -> bool
{
    match metadata2 {
        Some(metadata2) =>metadata1.dev() == metadata2.dev() && metadata1.ino() == metadata2.ino(),
        None            => false
    }
}

fn ask<P: AsRef<Path>>(dst_path: P) -> bool
{
    loop {
        eprint!("override {}? ", dst_path.as_ref().to_string_lossy());
        match stderr().flush() {
            Ok(()) => {
                let mut line = String::new();
                match stdin().read_line(&mut line) {
                    Ok(_)    => {
                        break line.trim().to_lowercase() == String::from("yes") || line.trim().to_lowercase() == String::from("y");
                    },
                    Err(err) => eprintln!("{}", err),
                }
            },
            Err(err) => eprintln!("{}", err),
        }
    }
}

fn cp_file<P: AsRef<Path>, Q: AsRef<Path>>(src_path: P, src_metadata: &fs::Metadata, dst_path: Q, dst_metadata: Option<&fs::Metadata>, opts: &Options) -> bool
{
    if !are_same_files(src_metadata, dst_metadata) {
        let answer = if opts.interactive_flag {
            match dst_metadata {
                Some(_) => ask(dst_path.as_ref()),
                None    => true
            }
        } else {
            true
        };
        if answer {
            let mut is_success = if src_metadata.file_type().is_file() {
                copy_file(src_path.as_ref(), dst_path.as_ref()) 
            } else if src_metadata.file_type().is_symlink() {
                copy_symlink(src_path.as_ref(), dst_path.as_ref())
            } else {
                if opts.recursive_flag {
                    mknod_for_copy(dst_path.as_ref(), src_metadata)
                } else {
                    copy_file(src_path.as_ref(), dst_path.as_ref())
                }
            };
            if is_success {
                if opts.preserve_flag {
                    is_success = preserve(src_metadata, dst_path.as_ref());
                }
            }
            is_success
        } else {
            true
        }
    } else {
        true
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "fHiLPpRr");
    let mut opts = Options {
        interactive_flag: false,
        preserve_flag: false,
        recursive_flag: false,
        do_flag: DoFlag::NoDereference,
    };
    let mut is_default_do_flag = true;
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('f', _))) => (),
            Some(Ok(Opt('H', _))) => opts.do_flag = DoFlag::NonRecursiveDereference,
            Some(Ok(Opt('i', _))) => opts.interactive_flag = true,
            Some(Ok(Opt('L', _))) => opts.do_flag = DoFlag::RecursiveDereference,
            Some(Ok(Opt('P', _))) => {
                opts.do_flag = DoFlag::NoDereference;
                is_default_do_flag = false;
            },
            Some(Ok(Opt('p', _))) => opts.preserve_flag = true,
            Some(Ok(Opt('R' | 'r', _))) => opts.recursive_flag = true,
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
    if is_default_do_flag && !opts.recursive_flag {
        opts.do_flag = DoFlag::NonRecursiveDereference;
    }
    let mut status = 0;
    let mut paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    match get_dest_path_and_dir_flag(&mut paths) {
        Some((dst_path, is_dir)) => {
            for src_path in &paths {
                let mut dst_path_buf = PathBuf::new();
                dst_path_buf.push(dst_path);
                let dst_path_buf = if is_dir {
                    Path::new(src_path).file_name().map(|name| {
                            dst_path_buf.push(name);
                            dst_path_buf
                    })
                } else {
                    Some(dst_path_buf)
                };
                let mut dst_metadata_stack: Vec<Result<fs::Metadata>> = Vec::new();
                match dst_path_buf {
                    Some(mut dst_path_buf) => {
                        let dst_path_buf_r = &mut dst_path_buf;
                        let dst_metadata_stack_r = &mut dst_metadata_stack;
                        let is_success = if opts.recursive_flag {
                            recursively_do(src_path, opts.do_flag, &mut (|src_path, src_metadata, name, action| {
                                    match action {
                                        DoAction::DirActionBeforeList | DoAction::FileAction => {
                                            match name {
                                                Some(name) => dst_path_buf_r.push(name),
                                                None       => (),
                                            }
                                            dst_metadata_stack_r.push(fs::metadata(dst_path_buf_r.as_path()));
                                        },
                                        _ => (),
                                    };
                                    let is_success = match action {
                                        DoAction::DirActionBeforeList => {
                                            match &dst_metadata_stack_r[dst_metadata_stack_r.len() - 1] {
                                                Ok(dst_metadata) => {
                                                    if !dst_metadata.file_type().is_dir() {
                                                        eprintln!("{}: Not a directory", dst_path_buf_r.as_path().to_string_lossy());
                                                        false
                                                    } else {
                                                        true
                                                    }
                                                },
                                                Err(err) if err.kind() == ErrorKind::NotFound => {
                                                    mkdir_for_copy(dst_path_buf_r.as_path(), src_metadata)
                                                },
                                                Err(err) => {
                                                    eprintln!("{}: {}", dst_path_buf_r.as_path().to_string_lossy(), err);
                                                    false
                                                },
                                            }
                                        },
                                        DoAction::FileAction => {
                                            match &dst_metadata_stack_r[dst_metadata_stack_r.len() - 1] {
                                                Ok(dst_metadata) => {
                                                    cp_file(src_path, src_metadata, dst_path_buf_r.as_path(), Some(&dst_metadata), &opts)
                                                },
                                                Err(err) if err.kind() == ErrorKind::NotFound => {
                                                    cp_file(src_path, src_metadata, dst_path_buf_r.as_path(), None, &opts)
                                                },
                                                Err(err) => {
                                                    eprintln!("{}: {}", dst_path_buf_r.as_path().to_string_lossy(), err);
                                                    false
                                                },
                                            }
                                        },
                                        DoAction::DirActionAfterList => preserve(src_metadata, dst_path_buf_r.as_path()),
                                    };
                                    match (action, is_success) {
                                        (DoAction::FileAction | DoAction::DirActionAfterList, _) | (_, false) => {
                                            dst_metadata_stack_r.pop();
                                            match name {
                                                Some(_) => { dst_path_buf_r.pop(); () },
                                                None    => (),
                                            }
                                        },
                                        _ => (),
                                    }
                                    (is_success, true)
                            }))
                        } else {
                            non_recursively_do(src_path, opts.do_flag, &mut (|src_path, src_metadata| {
                                    dst_metadata_stack_r.push(fs::metadata(dst_path_buf_r.as_path()));
                                    let is_success = match &dst_metadata_stack_r[dst_metadata_stack_r.len() - 1] {
                                        Ok(dst_metadata) => {
                                            cp_file(src_path, src_metadata, dst_path_buf_r.as_path(), Some(&dst_metadata), &opts)
                                        },
                                        Err(err) if err.kind() == ErrorKind::NotFound => {
                                            cp_file(src_path, src_metadata, dst_path_buf_r.as_path(), None, &opts)
                                        },
                                        Err(err) => {
                                             eprintln!("{}: {}", dst_path_buf_r.as_path().to_string_lossy(), err);
                                             false
                                        },
                                    };
                                    dst_metadata_stack_r.pop();
                                    is_success
                            }))
                        };
                        if !is_success { status = 1; }
                    },
                    None => (),
                };
            }
        },
        None => status = 1,
    }
    status
}
