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
use std::collections::VecDeque;
use std::io::*;
use std::fs::*;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

enum Number
{
    Plus(u64),
    Minus(u64),
}

enum ByteOrLineNumber
{
    Bytes(Number),
    Lines(Number),
}

struct Options
{
    number: ByteOrLineNumber,
}

fn tail_bytes_from_start<R: Read>(r: &mut R, path: Option<&Path>, n: u64) -> bool
{
    let mut r = ByteReader::new(BufReader::new(r));
    let mut w = BufWriter::new(stdout());
    let mut i: u64 = 0;
    loop {
        let mut b: u8 = 0;
        match r.read_byte(&mut b) {
            Ok(false) => break,
            Ok(_) => {
                if i + 1 >= n {
                    let buf: [u8; 1] = [b];
                    match w.write_all(&buf) {
                        Ok(())   => (),
                        Err(err) => {
                            eprintln!("{}", err);
                            return false;
                        },
                    }
                }
                i += 1;
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

fn tail_bytes_from_end<R: Read>(r: &mut R, path: Option<&Path>, n: u64) -> bool
{
    let mut r = ByteReader::new(BufReader::new(r));
    let mut w = BufWriter::new(stdout());
    let mut bytes: VecDeque<u8> = VecDeque::new();
    loop {
        let mut b: u8 = 0;
        match r.read_byte(&mut b) {
            Ok(false) => break,
            Ok(_) => {
                bytes.push_back(b);
                if bytes.len() as u64 > n {
                    bytes.pop_front();
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
    let buf = Vec::from(bytes);
    match w.write_all(&buf) {
        Ok(())   => (),
        Err(err) => {
            eprintln!("{}", err);
            return false;
        },
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

fn tail_lines_from_start<R: Read>(r: &mut R, path: Option<&Path>, n: u64) -> bool
{
    let mut r = CharByteReader::new(BufReader::new(r));
    let mut w = BufWriter::new(stdout());
    let mut i: u64 = 0;
    loop {
        let mut c = '\0';
        match r.read_char(&mut c) {
            Ok(0) => break,
            Ok(_) => {
                if i + 1 >= n {
                    match write!(w, "{}", c) {
                        Ok(())   => (),
                        Err(err) => {
                            eprintln!("{}", err);
                            return false;
                        },
                    }
                }
                if c == '\n' { i += 1; }
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

fn tail_lines_from_end<R: Read>(r: &mut R, path: Option<&Path>, n: u64) -> bool
{
    let mut r = BufReader::new(r);
    let mut w = BufWriter::new(stdout());
    let mut lines: VecDeque<String> = VecDeque::new();
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                lines.push_back(line.clone());
                if lines.len() as u64 > n {
                    lines.pop_front();
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
    for line in &lines {
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

fn tail<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    match opts.number {
        ByteOrLineNumber::Bytes(Number::Plus(n))  => tail_bytes_from_start(r, path, n),
        ByteOrLineNumber::Bytes(Number::Minus(n)) => tail_bytes_from_end(r, path, n),
        ByteOrLineNumber::Lines(Number::Plus(n))  => tail_lines_from_start(r, path, n),
        ByteOrLineNumber::Lines(Number::Minus(n))  => tail_lines_from_end(r, path, n),
    }
}

fn tail_file<P: AsRef<Path>>(path: P, opts: &Options, are_many_files: bool, is_first: &mut bool) -> bool
{
    match File::open(path.as_ref()) {
        Ok(mut file) => {
            if are_many_files {
                if !*is_first { println!(""); }
                println!("==> {} <==", path.as_ref().to_string_lossy());
            }
            let is_success = tail(&mut file, Some(path.as_ref()), opts);
            *is_first = false;
            is_success
        },
        Err(err)     => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        }
    }
}

fn parse_number(s: &String) -> Option<Number>
{
    if s.starts_with('+') {
        match (&s[1..]).parse::<u64>() {
            Ok(n)    => Some(Number::Plus(n)),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    } else if s.starts_with('-') {
        match (&s[1..]).parse::<u64>() {
            Ok(n)    => Some(Number::Minus(n)),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    } else {
        match s.parse::<u64>() {
            Ok(n)    => Some(Number::Minus(n)),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "c:fn:");
    let mut opts = Options {
        number: ByteOrLineNumber::Lines(Number::Minus(10)),
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('c', Some(opt_arg)))) => {
                match parse_number(&opt_arg) {
                    Some(n) => opts.number = ByteOrLineNumber::Bytes(n),
                    None    => {
                        return 1;
                    }
                }
            },
            Some(Ok(Opt('c', None))) => {
                eprintln!("option requires an argument -- 'c'");
                return 1;
            },
            Some(Ok(Opt('f', _))) => (),
            Some(Ok(Opt('n', Some(opt_arg)))) => {
                match parse_number(&opt_arg) {
                    Some(n) => opts.number = ByteOrLineNumber::Lines(n),
                    None    => {
                        return 1;
                    }
                }
            },
            Some(Ok(Opt('n', None))) => {
                eprintln!("option requires an argument -- 'n'");
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
        let mut is_first = true;
        for path in &paths {
            if !tail_file(path, &opts, paths.len() > 1, &mut is_first) { status = 1; }
        }
    } else {
        if !tail(&mut stdin(), None, &opts) { status = 1; }
    }
    status
}
