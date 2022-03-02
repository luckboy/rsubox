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
    number: u64,
}

fn head<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    let mut r = CharByteReader::new(BufReader::new(r));
    let mut w = BufWriter::new(stdout());
    let mut i: u64 = 0;
    loop {
        let mut c = '\0';
        match r.read_char(&mut c) {
            Ok(0) => break,
            Ok(_) => {
                if i >= opts.number { break; }
                match write!(&mut w, "{}", c) {
                    Ok(())   => (),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
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

fn head_file<P: AsRef<Path>>(path: P, opts: &Options, are_many_files: bool, is_first: &mut bool) -> bool
{
    match File::open(path.as_ref()) {
        Ok(mut file) => {
            if are_many_files {
                if !*is_first { println!(""); }
                println!("==> {} <==", path.as_ref().to_string_lossy());
            }
            let is_success = head(&mut file, Some(path.as_ref()), opts);
            *is_first = false;
            is_success
        },
        Err(err)     => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "n:");
    let mut opts = Options {
        number: 10,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('n', Some(opt_arg)))) => {
                match opt_arg.parse::<u64>() {
                    Ok(n)    => opts.number = n,
                    Err(err) => {
                        eprintln!("{}", err);
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
            if !head_file(path, &opts, paths.len() > 1, &mut is_first) { status = 1; }
        }
    } else {
        if !head(&mut stdin(), None, &opts) { status = 1; }
    }
    status
}
