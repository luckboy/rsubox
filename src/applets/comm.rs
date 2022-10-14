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
    one_flag: bool,
    two_flag: bool,
    three_flag: bool,
}

fn read_line<R: BufRead>(r: &mut R, path: Option<&Path>, line: &mut Option<String>) -> bool
{
    let mut buf = String::new();
    match r.read_line(&mut buf) {
        Ok(0)    => {
            *line = None;
            true
        },
        Ok(_)    => {
            *line = Some(String::from(str_without_newline(buf.as_str())));
            true
        },
        Err(err) => {
            match path {
                Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                None       => eprintln!("{}", err),
            }
            false
        },
    }
}

fn print_line1<W: Write>(w: &mut W, line: &String) -> bool
{
    match write!(w, "{}\n", line) {
        Ok(()) => true,
        Err(err) => {
            eprintln!("{}", err);
            false
        },
    }
}

fn print_line2<W: Write>(w: &mut W, line: &String, opts: &Options) -> bool
{
    if !opts.one_flag {
        match write!(w, "\t") {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}", err);
                return false;
            },
        }
    }
    match write!(w, "{}\n", line) {
        Ok(()) => true,
        Err(err) => {
            eprintln!("{}", err);
            false
        },
    }
}

fn print_line3<W: Write>(w: &mut W, line: &String, opts: &Options) -> bool
{
    if !opts.one_flag {
        match write!(w, "\t") {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}", err);
                return false;
            },
        }
    }
    if !opts.two_flag {
        match write!(w, "\t") {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}", err);
                return false;
            },
        }
    }
    match write!(w, "{}\n", line) {
        Ok(()) => true,
        Err(err) => {
            eprintln!("{}", err);
            false
        },
    }
}

fn comm<R: Read, S: Read>(r1: &mut R, r2: &mut S, path1: Option<&Path>, path2: Option<&Path>, opts: &Options) -> bool
{
    let mut r1 = BufReader::new(r1);
    let mut r2 = BufReader::new(r2);
    let mut w = BufWriter::new(stdout());
    let mut line1: Option<String> = None;
    let mut line2: Option<String> = None;
    if !read_line(&mut r1, path1, &mut line1) { return false; }
    if !read_line(&mut r2, path2, &mut line2) { return false; }
    loop {
        match (&line1, &line2) {
            (Some(tmp_line1), Some(tmp_line2)) if tmp_line1 < tmp_line2 => {
                if !opts.one_flag {
                    if !print_line1(&mut w, tmp_line1) { return false; }
                }
                if !read_line(&mut r1, path1, &mut line1) { return false; }
            },
            (Some(tmp_line1), Some(tmp_line2)) if tmp_line1 == tmp_line2 => {
                if !opts.three_flag {
                    if !print_line3(&mut w, tmp_line1, opts) { return false; }
                }
                if !read_line(&mut r1, path1, &mut line1) { return false; }
                if !read_line(&mut r2, path2, &mut line2) { return false; }
            },
            (Some(_), Some(tmp_line2)) => {
                if !opts.two_flag {
                    if !print_line2(&mut w, tmp_line2, opts) { return false; }
                }
                if !read_line(&mut r2, path2, &mut line2) { return false; }
            },
            (Some(tmp_line1), None) => {
                if !opts.one_flag {
                    if !print_line1(&mut w, tmp_line1) { return false; }
                }
                if !read_line(&mut r1, path1, &mut line1) { return false; }
            },
            (None, Some(tmp_line2)) => {
                if !opts.two_flag {
                    if !print_line2(&mut w, tmp_line2, opts) { return false; }
                }
                if !read_line(&mut r2, path2, &mut line2) { return false; }
            },
            (None, None) => break, 
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

fn comm_files(path1: &String, path2: &String, opts: &Options) -> bool
{
    let path1: Option<&Path> = if path1 != &String::from("-") {
        Some(path1.as_ref())
    } else {
        None
    };
    let path2: Option<&Path> = if path2 != &String::from("-") {
        Some(path2.as_ref())
    } else {
        None
    };
    match (path1, path2) {
        (Some(path1), Some(path2)) => {
            match File::open(path1) {
                Ok(mut file1) => {
                    match File::open(path2) {
                        Ok(mut file2) => comm(&mut file1, &mut file2, Some(path1), Some(path2), opts),
                        Err(err) => {
                            eprintln!("{}: {}", path2.to_string_lossy(), err);
                            false
                        }
                    }
                },
                Err(err) => {
                    eprintln!("{}: {}", path1.to_string_lossy(), err);
                    false
                },
            }
        },
        (Some(path1), None) => {
            match File::open(path1) {
                Ok(mut file1) => comm(&mut file1, &mut stdin(), Some(path1), None, opts),
                Err(err) => {
                    eprintln!("{}: {}", path1.to_string_lossy(), err);
                    false
                },
            }
        },
        (None, Some(path2)) => {
            match File::open(path2) {
                Ok(mut file2) => comm(&mut stdin(), &mut file2, None, Some(path2), opts),
                Err(err) => {
                    eprintln!("{}: {}", path2.to_string_lossy(), err);
                    false
                },
            }
        },
        (None, None) => comm(&mut stdin(), &mut stdin(), None, None, opts),
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "123");
    let mut opts = Options {
        one_flag: false,
        two_flag: false,
        three_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('1', _))) => opts.one_flag = true,
            Some(Ok(Opt('2', _))) => opts.two_flag = true,
            Some(Ok(Opt('3', _))) => opts.three_flag = true,
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
    let paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    match paths.get(0) {
        Some(path1) => {
            match paths.get(1) {
                Some(path2) => {
                    if paths.len() > 2 {
                        eprintln!("Too many arguments");
                        return 1;
                    }
                    if comm_files(&path1, &path2, &opts) {
                        0
                    } else {
                        1
                    }
                },
                None => {
                    eprintln!("Too few arguments");
                    1
                },
            }
        },
        None => {
            eprintln!("Too few arguments");
            1
        },
    }
}
