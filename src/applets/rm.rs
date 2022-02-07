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
use std::path::*;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    force_flag: bool,
    interactive_flag: bool,
    recursive_flag: bool,
    tty_stdin_flag: bool,
}

fn descend_into_dir<P: AsRef<Path>>(path: P, opts: &Options) -> (bool, bool)
{
    let mut is_success = true;
    if opts.interactive_flag || (!opts.force_flag && opts.tty_stdin_flag && !access_for_remove(path.as_ref(), &mut is_success)) {
        if is_success {
            (true, ask_for_path("descend into", path.as_ref()))
        } else {
            (false, true)
        }
    } else {
        (is_success, true)
    }
}

fn rm_file<P: AsRef<Path>>(path: P, metadata: &fs::Metadata, opts: &Options) -> bool {
    let mut is_success = true;
    let answer = if opts.interactive_flag || (!opts.force_flag && opts.tty_stdin_flag && !metadata.file_type().is_symlink() && !access_for_remove(path.as_ref(), &mut is_success)) {
        if is_success {
            ask_for_path("remove", path.as_ref())
        } else {
            true
        }
    } else {
        true
    };
    if is_success && answer {
        match remove_file(path.as_ref()) {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                is_success = false;
            },
        }
    }
    is_success
}

fn rm_dir<P: AsRef<Path>>(path: P, opts: &Options) -> bool {
    let mut is_success = true;
    let answer = if opts.interactive_flag {
        if is_success {
            ask_for_path("remove", path.as_ref())
        } else {
            true
        }
    } else {
        true
    };
    if is_success && answer {
        match remove_dir(path.as_ref()) {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                is_success = false;
            },
        }
    }
    is_success
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "fiRrT");
    let mut opts = Options {
        force_flag: false,
        interactive_flag: false,
        recursive_flag: false,
        tty_stdin_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('f', _))) => opts.force_flag = true,
            Some(Ok(Opt('i', _))) => opts.interactive_flag = true,
            Some(Ok(Opt('R' | 'r', _))) => opts.recursive_flag = true,
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
    let paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    if !paths.is_empty() {
        for path in &paths {
            let (_, name) = dir_name_and_base_name(path.as_str(), None);
            if name != String::from(".") && name != String::from("..") {
                let is_success = if opts.recursive_flag {
                    recursively_do(path, DoFlag::NoDereference, !opts.force_flag, &mut (|path, metadata, _, action| {
                            match action {
                                DoAction::DirActionBeforeList => descend_into_dir(path, &opts),
                                DoAction::FileAction => (rm_file(path, metadata, &opts), true),
                                DoAction::DirActionAfterList => (rm_dir(path, &opts), true),
                            }
                    }))
                } else {
                    non_recursively_do(path, DoFlag::NoDereference, !opts.force_flag, false, &mut (|path, metadata| {
                            rm_file(path, metadata, &opts)
                    }))
                };
                if !is_success { status = 1; }
            } else {
                eprintln!("Can't remove . or ..");
                status = 1
            }
        }
    } else {
        if !opts.force_flag {
            eprintln!("Too few arguments");
            status = 1;
        }
    }
    status
}
