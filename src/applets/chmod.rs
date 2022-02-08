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
use std::os::unix::fs::PermissionsExt;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    recursive_flag: bool,
}

fn chmod_file<P: AsRef<Path>>(path: P, metadata: &fs::Metadata, mode: &Mode) -> bool
{
    if !metadata.file_type().is_symlink() {
        let new_mode = mode.change_mode(metadata.permissions().mode(), metadata.file_type().is_dir());
        let mut perms = metadata.permissions();
        perms.set_mode(new_mode);
        match set_permissions(path.as_ref(), perms) {
            Ok(())   => true,
            Err(err) => {
                eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                false
            },
        }
    } else {
        true
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "HhLPR");
    let mut opts = Options {
        recursive_flag: false,
    };
    loop {
        match opt_parser.next() {
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
        match Mode::parse(args[0].as_str()) {
            Some(mode) => {
                for path in args.iter().skip(1) {
                    let is_success = if opts.recursive_flag {
                        recursively_do(path, DoFlag::NonRecursiveDereference, true, &mut (|path, metadata, _, action| {
                                match action {
                                    DoAction::DirActionBeforeList => (chmod_file(path, metadata, &mode), true),
                                    DoAction::FileAction          => (chmod_file(path, metadata, &mode), true),
                                    DoAction::DirActionAfterList  => (true, true),
                                }
                        }))
                    } else {
                        non_recursively_do(path, DoFlag::NonRecursiveDereference, true, true, &mut (|path, metadata| {
                                chmod_file(path, metadata, &mode)
                        }))
                    };
                    if !is_success { status = 1; } 
                }
            },
            None => {
                eprintln!("Invalid mode");
                status = 1;
            },
        }
    } else {
        eprintln!("Too few arguments");
        status = 1;
    }
    status
}
