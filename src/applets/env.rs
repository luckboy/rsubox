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
use std::ffi::*;
use std::io::*;
use std::os::unix::process::CommandExt;
use std::process::*;
use getopt::Opt;

struct Options
{
    ignored_environment_flag: bool,
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "i");
    let mut opts = Options {
        ignored_environment_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('i', _))) => opts.ignored_environment_flag = true,
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
    if opts.ignored_environment_flag {
        for (name, _) in env::vars() {
            env::remove_var(name);
        }
    }
    let mut arg_iter = args.iter().skip(opt_parser.index());
    let mut prog: Option<OsString> = None; 
    loop {
        match arg_iter.next() {
            Some(arg) => {
                match arg.split_once('=') {
                    Some((name, value)) => env::set_var(name, value),
                    None                => {
                        prog = Some(OsString::from(arg));
                        break;
                    },
                }
            },
            None => break,
        }
    }
    match prog {
        Some(prog) => {
            let prog_args: Vec<OsString> = arg_iter.map(|a| OsString::from(a)).collect();
            let mut cmd = Command::new(prog.as_os_str());
            cmd.args(prog_args);
            let err = cmd.exec();
            eprintln!("{}: {}", prog.as_os_str().to_string_lossy(), err);
            if err.kind() == ErrorKind::NotFound { 127 } else { 126 }
        },
        None => {
            for (name, value) in env::vars() {
                println!("{}={}", name, value);
            }
            0
        },
    }
}
