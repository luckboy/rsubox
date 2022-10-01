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
    tab_stops: Vec<u64>,
}

fn get_tab_stop(i: usize, opts: &Options) -> u64
{
    if opts.tab_stops.is_empty() {
        ((i as u64) + 1).saturating_mul(8)
    } else if opts.tab_stops.len() == 1 {
        ((i as u64) + 1).saturating_mul(opts.tab_stops[0])
    } else {
        if i < opts.tab_stops.len() {
            opts.tab_stops[i]
        } else {
            opts.tab_stops[opts.tab_stops.len() - 1].saturating_add(((i - opts.tab_stops.len()) as u64) + 1)
        }
    }
}

fn expand<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    let mut r = CharByteReader::new(BufReader::new(r));
    let mut w = BufWriter::new(stdout());
    let mut column: u64 = 0;
    let mut i: usize = 0;
    loop {
        let mut c = '\0';
        match r.read_char(&mut c) {
            Ok(0) => break,
            Ok(_) => {
                if c == '\x08' {
                    match write!(w, "\x08") {
                        Ok(()) => (),
                        Err(err) => {
                            eprintln!("{}", err);
                            return false;
                        },
                    }
                    column = column.saturating_sub(1);
                    if column < get_tab_stop(i.saturating_sub(1), opts) {
                        i = i.saturating_sub(1);
                    }
                } else if c == '\t' {
                    let tab_stop = get_tab_stop(i, opts);
                    for _ in column..tab_stop {
                        match write!(w, " ") {
                            Ok(()) => (),
                            Err(err) => {
                                eprintln!("{}", err);
                                return false;
                            },
                        }
                    }
                    column = tab_stop;
                    i += 1
                } else if c == '\n' {
                    match write!(w, "\n") {
                        Ok(()) => (),
                        Err(err) => {
                            eprintln!("{}", err);
                            return false;
                        },
                    }
                    column = 0;
                    i = 0;
                } else {
                    match write!(w, "{}", c) {
                        Ok(()) => (),
                        Err(err) => {
                            eprintln!("{}", err);
                            return false;
                        },
                    }
                    column += 1;
                    if column >= get_tab_stop(i, opts) {
                        i += 1;
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
    match w.flush() {
        Ok(()) => (),
        Err(err) => {
            eprintln!("{}", err);
            return false;
        },
    }
    true
}

fn expand_file(path: &String, opts: &Options) -> bool
{
    if path == &String::from("-") {
        expand(&mut stdin(), None, opts)
    } else {
        match File::open(path) {
            Ok(mut file) => expand(&mut file, Some(path.as_ref()), opts),
            Err(err)     => {
                eprintln!("{}: {}", path, err);
                false
            },
        }
    }
}

fn parse_tab_stops(s: &String, tab_stops: &mut Vec<u64>) -> bool
{
    tab_stops.clear();
    for t in s.split(|c: char| { c.is_whitespace() || c == ',' }) {
        match t.parse::<u64>() {
            Ok(0)    => {
                eprintln!("Tab stop is zero");
                return false;
            },
            Ok(n)    => tab_stops.push(n),
            Err(err) => {
                eprintln!("{}", err);
                break;
            },
        }
    }
    if tab_stops.len() >= 2 {
        let mut prev_n = tab_stops[0];
        for n in &tab_stops[1..] {
            if prev_n >= *n {
                eprintln!("Tab stops must be ascending");
                return false;
            }
            prev_n = *n;
        }
    }
    true
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "t:");
    let mut opts = Options {
        tab_stops: Vec::new(),
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('t', Some(opt_arg)))) => {
                if !parse_tab_stops(&opt_arg, &mut opts.tab_stops) {
                    return 1;
                }
            },
            Some(Ok(Opt('t', None))) => {
                eprintln!("option requires an argument -- 't'");
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
            if !expand_file(path, &opts) { status = 1; }
        }
    } else {
        if !expand(&mut stdin(), None, &opts) { status = 1; }
    }
    status
}
