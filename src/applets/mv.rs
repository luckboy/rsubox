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
    force_flag: bool,
    interactive_flag: bool,
    no_rename_flag: bool,
    tty_stdin_flag: bool,
}

fn utimes_and_chown_and_set_permissions<P: AsRef<Path>>(path: P, times: &Times, uid: uid_t, gid: gid_t, perms: Permissions) -> Result<()>
{
    utimes(path.as_ref(), &times)?;
    chown(path.as_ref(), uid, gid)?;
    set_permissions(path.as_ref(), perms)
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
        match utimes_and_chown_and_set_permissions(dst_path.as_ref(), &times, src_metadata.uid(), src_metadata.gid(), src_metadata.permissions()) {
            Ok(())   => true,
            Err(err) => {
                eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
                false
            },
        }
    } else {
        match lchown(dst_path.as_ref(), src_metadata.uid(), src_metadata.gid()) {
            Ok(())   => true,
            Err(err) => {
                eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
                false
            },
        }
    }
}

fn mv_file<P: AsRef<Path>, Q: AsRef<Path>>(src_path: P, src_metadata: &fs::Metadata, dst_path: Q) -> bool
{
    let mut is_success = if src_metadata.file_type().is_file() {
        copy_file(src_path.as_ref(), dst_path.as_ref()) 
    } else if src_metadata.file_type().is_symlink() {
        copy_symlink(src_path.as_ref(), dst_path.as_ref())
    } else {
        mknod_for_copy(dst_path.as_ref(), src_metadata)
    };
    if is_success {
        is_success = preserve(src_metadata, dst_path.as_ref());
    }
    if is_success {
        match remove_file(src_path.as_ref()) {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}: {}", src_path.as_ref().to_string_lossy(), err);
                is_success = false;
            },
        }
    }
    is_success
}

fn preserve_and_remove_dir<P: AsRef<Path>, Q: AsRef<Path>>(src_path: P, src_metadata: &fs::Metadata, dst_path: Q) -> bool
{
    let mut is_success = preserve(src_metadata, dst_path.as_ref());
    if is_success {
        match remove_dir(src_path.as_ref()) {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}: {}", src_path.as_ref().to_string_lossy(), err);
                is_success = false;
            },
        }
    }
    is_success
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "fiNT");
    let mut opts = Options {
        force_flag: false,
        interactive_flag: false,
        no_rename_flag: false,
        tty_stdin_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('f', _))) => opts.force_flag = true,
            Some(Ok(Opt('i', _))) => opts.interactive_flag = true,
            Some(Ok(Opt('N', _))) => opts.no_rename_flag = true,
            Some(Ok(Opt('T', _))) => opts.tty_stdin_flag = true,
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
    match isatty(0) {
        Ok(true) => opts.tty_stdin_flag = true,
        _        => (),
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
                        let mut answer = true; 
                        match fs::symlink_metadata(dst_path_buf.as_path()) {
                            Ok(_) => {
                                let mut is_success = true;
                                answer = if opts.interactive_flag || (!opts.force_flag && opts.tty_stdin_flag && !access_for_remove(dst_path_buf.as_path(), &mut is_success)) {
                                    ask_for_path("overwrite", dst_path_buf.as_path())
                                } else {
                                    true
                                };
                                if !is_success {
                                    status = 1;
                                    continue;
                                }
                            },
                            Err(err) if err.kind() == ErrorKind::NotFound => (),
                            Err(err) => {
                                eprintln!("{}: {}", dst_path_buf.as_path().to_string_lossy(), err);
                                status = 1;
                                continue;
                            },
                        }
                        if !answer { continue; }
                        let mut is_success = true;
                        let is_exdev = if !opts.no_rename_flag {
                            match rename(src_path, dst_path_buf.as_path()) {
                                Ok(()) => false,
                                Err(err) => {
                                    match err.raw_os_error() {
                                        Some(os_err) if os_err == libc::EXDEV => true,
                                        Some(os_err) if os_err == libc::EISDIR || os_err == libc::ENOTEMPTY => {
                                            eprintln!("{}: {}", dst_path_buf.as_path().to_string_lossy(), err);
                                            is_success = false;
                                            false
                                        },
                                        _ => {
                                            eprintln!("{}: {}", src_path, err);
                                            is_success = false;
                                            false
                                        },
                                    }
                                },
                            }
                        } else {
                            true
                        };
                        if is_success && is_exdev {
                            let dst_path_buf_r = &mut dst_path_buf;
                            let dst_metadata_stack_r = &mut dst_metadata_stack;
                            is_success = recursively_do(src_path, DoFlag::NoDereference, true, &mut (|src_path, src_metadata, name, action| {
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
                                                Ok(_) => {
                                                    mv_file(src_path, src_metadata, dst_path_buf_r.as_path())
                                                },
                                                Err(err) if err.kind() == ErrorKind::NotFound => {
                                                    mv_file(src_path, src_metadata, dst_path_buf_r.as_path())
                                                },
                                                Err(err) => {
                                                    eprintln!("{}: {}", dst_path_buf_r.as_path().to_string_lossy(), err);
                                                    false
                                                },
                                            }
                                        },
                                        DoAction::DirActionAfterList => preserve_and_remove_dir(src_path, src_metadata, dst_path_buf_r.as_path()),
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
                            }));
                        }
                        if !is_success { status = 1; } 
                    },
                    None => (),
                }
            }
        },
        None => status = 1,
    }
    status
}
