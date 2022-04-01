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
use std::ffi::*;
use std::io::*;
use std::os::unix::process::CommandExt;
use std::process::*;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    increment: i32,
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "n:");
    let mut opts = Options {
        increment: 10,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('n', Some(opt_arg)))) => {
                match opt_arg.parse::<i32>() {
                    Ok(n)    => opts.increment = n,
                    Err(err) => {
                        eprintln!("{}", err);
                        return 125;
                    },
                }
            },
            Some(Ok(Opt('n', None))) => {
                eprintln!("option requires an argument -- 'n'");
                return 125;
            },
            Some(Ok(Opt(c, _))) => {
                eprintln!("unknown option -- {:?}", c);
                return 125;
            },
            Some(Err(err)) => {
                eprintln!("{}", err);
                return 125;
            },
            None => break,
        }
    }
    let mut arg_iter = args.iter().skip(opt_parser.index());
    match arg_iter.next() {
        Some(prog) => {
            match nice(opts.increment) {
                Ok(_)    => (),
                Err(err) => {
                    eprintln!("{}", err);
                    return 125;
                },
            }
            let prog_args: Vec<OsString> = arg_iter.map(|a| OsString::from(a)).collect();
            let mut cmd = Command::new(prog);
            cmd.args(prog_args);
            let err = cmd.exec();
            eprintln!("{}: {}", prog, err);
            if err.kind() == ErrorKind::NotFound { 127 } else { 126 }
        },
        None => {
            eprintln!("No program");
            125
        },
    }
}
