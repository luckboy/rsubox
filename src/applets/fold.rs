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
use std::path::*;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    byte_flag: bool,
    space_flag: bool,
    width: usize,
}

fn adjust_column(column: usize, c: char, opts: &Options) -> usize
{
    if !opts.byte_flag {
        match c {
            '\x08' => {
                if column >= 1 { column - 1 } else { 0 }
            },
            '\r'   => 0,
            '\t'   => column + 8 + (column % 8),
            _      => column + 1,
        }
    } else {
        column + c.len_utf8()
    }
}

fn fold<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    let mut r = CharByteReader::new(BufReader::new(r));
    let mut w = BufWriter::new(stdout());
    let mut line = String::new();
    let mut column = 0;
    loop {
        let mut c = '\0';
        match r.read_char(&mut c) {
            Ok(0) => break,
            Ok(_) => {
               if c == '\n' {
                   line.push(c);
                   match write!(w, "{}", line) {
                       Ok(()) => (),
                       Err(err) => {
                            eprintln!("{}", err);
                            return false;
                        },
                    }
                    line.clear();
                    column = 0;
               } else {
                   loop {
                        column = adjust_column(column, c, opts);
                        if column <= opts.width { 
                            line.push(c);
                            break;
                        }
                        if opts.space_flag {
                            let bytes = line.as_bytes();
                            let i = (0..bytes.len()).rev().find(|i| {
                                bytes[*i] == b' ' || bytes[*i] == b'\t'
                            });
                            match i {
                                Some(i) => {
                                    match write!(w, "{}\n", &line[0..(i + 1)]) {
                                        Ok(()) => (),
                                        Err(err) => {
                                            eprintln!("{}", err);
                                            return false;
                                        },
                                    }
                                    line = String::from(&line[(i + 1)..]);
                                    column = 0;
                                    for c in line.chars() {
                                        column = adjust_column(column, c, opts);
                                    }
                                    continue;
                                },
                                None => (),
                            }
                        }
                        if line.is_empty() {
                            line.push(c);
                            column = adjust_column(0, c, opts);
                            break;
                        }
                        match write!(w, "{}\n", line) {
                            Ok(()) => (),
                            Err(err) => {
                                eprintln!("{}", err);
                                return false;
                            },
                        }
                        line.clear();
                        column = 0;
                    }
                }
            },
            Err(err) => {
                match path {
                   Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                   None       => eprintln!("{}", err),
                }
                return false;
            },
        }
    }
    if !line.is_empty() {
        match write!(w, "{}", line) {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}", err);
                return false;
            },
        }
    }
    match w.flush() {
        Ok(())   => (),
        Err(err) => {
            eprintln!("{}", err);
            return false;
        },
    }
    true
}

fn fold_file(path: &String, opts: &Options) -> bool
{
    if path == &String::from("-") {
        fold(&mut stdin(), None, opts)
    } else {
        match File::open(path) {
            Ok(mut file) => fold(&mut file, Some(path.as_ref()), opts),
            Err(err)     => {
                eprintln!("{}: {}", path, err);
                false
            }
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "bsw:");
    let mut opts = Options {
        byte_flag: false,
        space_flag: false,
        width: 80,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('b', _))) => opts.byte_flag = true,
            Some(Ok(Opt('s', _))) => opts.space_flag = true,
            Some(Ok(Opt('w', Some(opt_arg)))) => {
                match opt_arg.parse::<usize>() {
                    Ok(n)    => opts.width = n,
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    }
                }
            },
            Some(Ok(Opt('w', None))) => {
                eprintln!("option requires an argument -- 'w'");
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
            if !fold_file(path, &opts) { status = 1; }
        }
    } else {
        if !fold(&mut stdin(), None, &opts) { status = 1; }
    }
    status
}
