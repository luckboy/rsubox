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
use std::env;
use std::fs;
use std::os::unix::fs::MetadataExt;
use std::path;
use getopt::Opt;

enum PathFlag
{
    None,
    Logical,
    Physical,
}

struct Options
{
    path_flag: PathFlag,
}

fn print_current_dir() -> bool
{
    match env::current_dir() {
        Ok(path_buf) => {
            println!("{}", path_buf.as_path().to_string_lossy());
            true
        },
        Err(err) => {
            eprintln!("{}", err);
            false
        },
    }
}

fn print_logical_current_dir() -> bool
{
    match env::var("PWD") {
        Ok(path) => {
            if !path.starts_with(path::MAIN_SEPARATOR) {
                return false;
            }
            if path.split(path::MAIN_SEPARATOR).any(|s| { s == "." || s == ".." }) {
                return false;
            }
            match fs::metadata(path.as_str()) {
                Ok(metadata) => {
                    match fs::metadata(".") {
                        Ok(metadata2) => {
                            if metadata.dev() == metadata2.dev() && metadata.ino() == metadata2.ino() {
                                println!("{}", path.as_str());
                                true
                            } else {
                                false
                            }
                        },
                        Err(_) => false,
                    }
                },
                Err(_) => false,
            }
        },
        Err(_) => false,
    }
}

fn print_physical_current_dir() -> bool
{
    match env::current_dir() {
        Ok(path_buf) => {
            match fs::canonicalize(path_buf.as_path()) {
                Ok(path_buf) => {
                    println!("{}", path_buf.as_path().to_string_lossy());
                    true
                },
                Err(err)     => {
                    eprintln!("{}", err);
                    false
                },
            }
        },
        Err(err) => {
            eprintln!("{}", err);
            false
        },
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "LP");
    let mut opts = Options {
        path_flag: PathFlag::None,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('L', _))) => opts.path_flag = PathFlag::Logical,
            Some(Ok(Opt('P', _))) => opts.path_flag = PathFlag::Physical,
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
    let is_success = match opts.path_flag {
        PathFlag::None     => print_current_dir(),
        PathFlag::Logical  => {
            if print_logical_current_dir() {
                true
            } else {
                print_physical_current_dir()
            }
        },
        PathFlag::Physical => print_physical_current_dir(),
    };
    if is_success { 0 } else { 1 }
}
