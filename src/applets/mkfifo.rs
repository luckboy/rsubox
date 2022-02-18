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
use std::path::*;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    mode: Option<u32>,
}

fn mkfifo_file<P: AsRef<Path>>(path: P, opts: &Options) -> bool
{
    let mut is_success = match mkfifo(path.as_ref(), 0o666) {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    };
    if is_success {
        is_success = match opts.mode {
            Some(mode) => set_mode(path.as_ref(), mode),
            None       => true,
        };
    }
    is_success
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "m");
    let mut opts = Options {
        mode: None,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('m', Some(opt_arg)))) => {
                match Mode::parse(opt_arg.as_str()) {
                    Some(mode) => {
                        let mask = umask(0);
                        umask(mask);
                        opts.mode = Some(mode.change_mode(0o666 & !mask, true));
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
            if !mkfifo_file(path, &opts) { 
                status = 1;
            }
        }
    } else {
        eprintln!("Too few arguments");
        status = 1;
    }
    status
}
