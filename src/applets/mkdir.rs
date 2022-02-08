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
use std::fs::*;
use std::io::*;
use std::os::unix::fs::PermissionsExt;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    mode: Option<u32>,
    parent_flag: bool,
}

fn mkdir<P: AsRef<Path>>(path: P, opts: &Options, is_err_for_already_exists: bool, is_perm_setting: bool) -> bool
{
    let (mut is_success, is_created) = match create_dir(path.as_ref()) {
        Ok(()) => (true, true),
        Err(err) if !is_err_for_already_exists && err.kind() == ErrorKind::AlreadyExists => (true, false),
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            (false, false)
        },
    };
    if is_success && is_created && is_perm_setting {
        is_success = match opts.mode {
            Some(mode) => {
                match fs::metadata(path.as_ref()) {
                    Ok(metadata) => {
                        if metadata.file_type().is_dir() {
                            let mut perms = metadata.permissions();
                            perms.set_mode(mode);
                            match set_permissions(path.as_ref(), perms) {
                                Ok(())   => true,
                                Err(err) => {
                                    eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                                    false
                                },
                            }
                        } else {
                            eprintln!("{}: Not a directory", path.as_ref().to_string_lossy());
                            false
                        }
                    },
                    Err(err) => {
                        eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                        false
                    },
                }
            },
            None => true,
        };
    }
    is_success
}

fn mkdir_with_parents<P: AsRef<Path>>(path: P, opts: &Options) -> bool
{
    let mut ancestors: Vec<&Path> = path.as_ref().ancestors().collect();
    if ancestors.len() > 0 {
        match ancestors.get(ancestors.len() - 1) {
            Some(path) if path.as_os_str().is_empty() => { ancestors.pop(); () },
            Some(_) | None => (),
        }
    }
    ancestors.reverse();
    for (i, ancestor) in ancestors.iter().enumerate() {
        if !mkdir(ancestor, opts, false, i == ancestors.len() - 1) { return false; }
    }
    true
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "m:p");
    let mut opts = Options {
        mode: None,
        parent_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('m', Some(opt_arg)))) => {
                match Mode::parse(opt_arg.as_str()) {
                    Some(mode) => {
                        let mask = umask(0);
                        umask(mask);
                        opts.mode = Some(mode.change_mode(0o777 & !mask, true));
                    },
                    None       => {
                        eprintln!("Invalid mode");
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('m', None))) => {
                eprintln!("option requires an argument -- 'm'");
                return 1;
            },
            Some(Ok(Opt('p', _))) => opts.parent_flag = true,
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
    let paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    if !paths.is_empty() {
        for path in &paths {
            let is_success = if opts.parent_flag {
                mkdir_with_parents(path, &opts)
            } else {
                mkdir(path, &opts, true, true)
            };
            if !is_success { status = 1; }
        }
    } else {
        eprintln!("Too few arguments");
        status = 1;
    }
    status
}
