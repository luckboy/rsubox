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
use std::path::*;
use getopt::Opt;

struct Options
{
    parent_flag: bool,
}

fn rmdir<P: AsRef<Path>>(path: P) -> bool
{
    match remove_dir(path.as_ref()) {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    }
}

fn rmdir_with_parents<P: AsRef<Path>>(path: P) -> bool
{
    let mut ancestors: Vec<&Path> = path.as_ref().ancestors().collect();
    if ancestors.len() > 0 {
        match ancestors.get(ancestors.len() - 1) {
            Some(path) if path.as_os_str().is_empty() => { ancestors.pop(); () },
            Some(_) | None => (),
        }
    }
    for ancestor in &ancestors {
        if !rmdir(ancestor) { return false; }
    }
    true
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "p");
    let mut opts = Options {
        parent_flag: false,
    };
    loop {
        match opt_parser.next() {
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
                rmdir_with_parents(path)
            } else {
                rmdir(path)
            };
            if !is_success { status = 1; }
        }
    } else {
        eprintln!("Too few arguments");
        status = 1;
    }
    status
}
