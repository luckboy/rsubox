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
use getopt::Opt;
use crate::utils::*;

struct Options
{
    sysname_flag: bool,
    nodename_flag: bool,
    release_flag: bool,
    version_flag: bool,
    machine_flag: bool,
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "amnrsv");
    let mut opts = Options {
        sysname_flag: false,
        nodename_flag: false,
        release_flag: false,
        version_flag: false,
        machine_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('a', _))) => {
                opts.sysname_flag = true;
                opts.nodename_flag = true;
                opts.release_flag = true;
                opts.version_flag = true;
                opts.machine_flag = true;
            },
            Some(Ok(Opt('m', _))) => opts.machine_flag = true,
            Some(Ok(Opt('n', _))) => opts.nodename_flag = true,
            Some(Ok(Opt('r', _))) => opts.release_flag = true,
            Some(Ok(Opt('s', _))) => opts.sysname_flag = true,
            Some(Ok(Opt('v', _))) => opts.version_flag = true,
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
    if !opts.sysname_flag && !opts.nodename_flag && !opts.release_flag && !opts.version_flag && !opts.machine_flag {
        opts.sysname_flag = true;
    }
    match uname() {
        Ok(name) => {
            let mut is_first = true;
            if opts.sysname_flag {
                print!("{}", name.sysname.to_string_lossy());
                is_first = false;
            }
            if opts.nodename_flag {
                if !is_first { print!(" "); }
                print!("{}", name.nodename.to_string_lossy());
                is_first = false;
            }
            if opts.release_flag {
                if !is_first { print!(" "); }
                print!("{}", name.release.to_string_lossy());
                is_first = false;
            }
            if opts.version_flag {
                if !is_first { print!(" "); }
                print!("{}", name.version.to_string_lossy());
                is_first = false;
            }
            if opts.machine_flag {
                if !is_first { print!(" "); }
                print!("{}", name.machine.to_string_lossy());
            }
            println!("");
            0
        },
        Err(err) => {
            eprintln!("{}", err);
            1
        },
    }
}
