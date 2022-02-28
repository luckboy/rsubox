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
use std::fs::*;
use std::os::unix::fs::symlink;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    force_flag: bool,
    symbolic_link_flag: bool,
}

fn ln_file<P: AsRef<Path>, Q: AsRef<Path>>(src_path: P, dst_path: Q, opts: &Options) -> bool
{
    let mut is_success = if opts.force_flag {
        match remove_file(dst_path.as_ref()) {
            Ok(()) => true,
            Err(err) if err.kind() == ErrorKind::NotFound => true,
            Err(err) => {
                eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
                false
            },
        }
    } else {
        true
    };
    if is_success {
        let res = if !opts.symbolic_link_flag {
            hard_link(src_path.as_ref(), dst_path.as_ref())
        } else {
            symlink(src_path.as_ref(), dst_path.as_ref())
        };
        is_success = match res {
            Ok(())   => true,
            Err(err) => {
                if !opts.symbolic_link_flag {
                    if err.kind() == ErrorKind::AlreadyExists {
                        eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
                    } else {
                        eprintln!("{}: {}", src_path.as_ref().to_string_lossy(), err);
                    }
                } else {
                    eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
                }
                false
            },
        };
    }
    is_success
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "fs");
    let mut opts = Options {
        force_flag: false,
        symbolic_link_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('f', _))) => opts.force_flag = true,
            Some(Ok(Opt('s', _))) => opts.symbolic_link_flag = true,
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
                match dst_path_buf {
                    Some(dst_path_buf) => {
                        if !ln_file(src_path, dst_path_buf.as_path(), &opts) {
                            status = 1;
                        }
                    },
                    None => (),
                }
            }
        },
        None => status = 1,
    }
    status
}
