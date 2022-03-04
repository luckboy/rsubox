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
use std::cmp::max;
use std::cmp::min;
use std::fs::*;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

struct List
{
    start: Option<usize>,
    elems: Vec<usize>,
    end: Option<usize>,
}

enum TypeFlag
{
    Bytes,
    Chars,
    Fields,
}

struct Options
{
    type_flag: TypeFlag,
    list: List,
    delimiter: char,
    only_delimited_flag: bool,
}

fn cut_bytes<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    let mut r = BufReader::new(r);
    let mut w = BufWriter::new(stdout());
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                let bytes: Vec<u8> = line_without_newline.bytes().collect();
                match opts.list.start {
                    Some(high) => {
                        let n = min(high + 1, bytes.len());
                        for b in &bytes[0..n] {
                            let buf: [u8; 1] = [*b];
                            match w.write_all(&buf) {
                                Ok(())   => (),
                                Err(err) => {
                                    eprintln!("{}", err);
                                    return false;
                                },
                            }
                        }
                    },
                    None => (),
                }
                for i in &opts.list.elems {
                    match bytes.get(*i) {
                        Some(b) => {
                            let buf: [u8; 1] = [*b];
                            match w.write_all(&buf) {
                                Ok(())   => (),
                                Err(err) => {
                                    eprintln!("{}", err);
                                    return false;
                                },
                            }
                        }
                        None => (),
                    }
                }
                match opts.list.end {
                    Some(low) => {
                        let n = min(low, bytes.len());
                        for b in &bytes[n..] {
                            let buf: [u8; 1] = [*b];
                            match w.write_all(&buf) {
                                Ok(())   => (),
                                Err(err) => {
                                    eprintln!("{}", err);
                                    return false;
                                },
                            }
                        }
                    },
                    None => (),
                }
                match write!(w, "\n") {
                    Ok(())   => (),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
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

fn cut_chars<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    let mut r = BufReader::new(r);
    let mut w = BufWriter::new(stdout());
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                let chars: Vec<char> = line_without_newline.chars().collect();
                match opts.list.start {
                    Some(high) => {
                        let n = min(high + 1, chars.len());
                        for c in &chars[0..n] {
                            match write!(w, "{}", c) {
                                Ok(())   => (),
                                Err(err) => {
                                    eprintln!("{}", err);
                                    return false;
                                },
                            }
                        }
                    },
                    None => (),
                }
                for i in &opts.list.elems {
                    match chars.get(*i) {
                        Some(c) => {
                            match write!(w, "{}", c) {
                                Ok(())   => (),
                                Err(err) => {
                                    eprintln!("{}", err);
                                    return false;
                                },
                            }
                        }
                        None => (),
                    }
                }
                match opts.list.end {
                    Some(low) => {
                        let n = min(low, chars.len());
                        for c in &chars[n..] {
                            match write!(w, "{}", c) {
                                Ok(())   => (),
                                Err(err) => {
                                    eprintln!("{}", err);
                                    return false;
                                },
                            }
                        }
                    },
                    None => (),
                }
                match write!(w, "\n") {
                    Ok(())   => (),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
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

fn cut_fields<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    let mut r = BufReader::new(r);
    let mut w = BufWriter::new(stdout());
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                let fields: Vec<&str> = line_without_newline.split(opts.delimiter).collect();
                if fields.len() > 1 {
                    let mut is_first = true;
                    match opts.list.start {
                        Some(high) => {
                            let n = min(high + 1, fields.len());
                            for f in &fields[0..n] {
                                if !is_first {
                                    match write!(w, "{}", opts.delimiter) {
                                        Ok(())   => (),
                                        Err(err) => {
                                            eprintln!("{}", err);
                                            return false;
                                        },
                                    }
                                }
                                match write!(w, "{}", f) {
                                    Ok(())   => (),
                                    Err(err) => {
                                        eprintln!("{}", err);
                                        return false;
                                    },
                                }
                                is_first = false;
                            }
                        },
                        None => (),
                    }
                    for i in &opts.list.elems {
                        match fields.get(*i) {
                            Some(f) => {
                                if !is_first {
                                    match write!(w, "{}", opts.delimiter) {
                                        Ok(())   => (),
                                        Err(err) => {
                                            eprintln!("{}", err);
                                            return false;
                                        },
                                    }
                                }
                                match write!(w, "{}", f) {
                                    Ok(())   => (),
                                    Err(err) => {
                                        eprintln!("{}", err);
                                        return false;
                                    },
                                }
                                is_first = false;
                            }
                            None => (),
                        }
                    }
                    match opts.list.end {
                        Some(low) => {
                            let n = min(low, fields.len());
                            for f in &fields[n..] {
                                if !is_first {
                                    match write!(w, "{}", opts.delimiter) {
                                        Ok(())   => (),
                                        Err(err) => {
                                            eprintln!("{}", err);
                                            return false;
                                        },
                                    }
                                }
                                match write!(w, "{}", f) {
                                    Ok(())   => (),
                                    Err(err) => {
                                        eprintln!("{}", err);
                                        return false;
                                    },
                                }
                                is_first = false;
                            }
                        },
                        None => (),
                    }
                    match write!(w, "\n") {
                        Ok(())   => (),
                        Err(err) => {
                            eprintln!("{}", err);
                            return false;
                        },
                    }
                } else {
                    if !opts.only_delimited_flag {
                       match write!(w, "{}", line_without_newline) {
                           Ok(())   => (),
                           Err(err) => {
                               eprintln!("{}", err);
                               return false;
                           },
                        }
                        match write!(w, "\n") {
                            Ok(())   => (),
                            Err(err) => {
                                eprintln!("{}", err);
                                return false;
                            },
                        }
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

fn cut<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    match opts.type_flag {
        TypeFlag::Bytes  => cut_bytes(r, path, opts),
        TypeFlag::Chars  => cut_chars(r, path, opts),
        TypeFlag::Fields => cut_fields(r, path, opts),
    }
}

fn cut_file<P: AsRef<Path>>(path: P, opts: &Options) -> bool
{
    match File::open(path.as_ref()) {
        Ok(mut file) => cut(&mut file, Some(path.as_ref()), opts),
        Err(err)     => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        }
    }
}

fn parse_list(s: &String, list: &mut List) -> bool
{
    list.start = None;
    list.elems.clear();
    list.end = None;
    let mut new_elems: Vec<usize> = Vec::new();
    for t in s.split(',') {
        match t.split_once("-") {
            Some(("", "")) => {
                eprintln!("Invalid list");
                return false;
            },
            Some((low_s, "")) => {
                match low_s.parse::<usize>() {
                    Ok(0) => {
                        eprintln!("Low is zero");
                        return false;
                    },
                    Ok(low) => list.end = Some(min(list.end.unwrap_or(usize::MAX), low - 1)),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
                }
            },
            Some(("", high_s)) => {
                match high_s.parse::<usize>() {
                    Ok(0) => {
                        eprintln!("High is zero");
                        return false;
                    },
                    Ok(high) => list.start = Some(max(list.start.unwrap_or(0), high - 1)),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
                }
            },
            Some((low_s, high_s)) => {
                match low_s.parse::<usize>() {
                    Ok(0) => {
                        eprintln!("Low is zero");
                        return false;
                    },
                    Ok(low) => {
                        match high_s.parse::<usize>() {
                            Ok(0) => {
                                eprintln!("High is zero");
                                return false;
                            },
                            Ok(high) => {
                                for i in (low - 1)..high {
                                    new_elems.push(i);
                                }
                            },
                            Err(err) => {
                                eprintln!("{}", err);
                                return false;
                            },
                        }
                    }
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
                }
            },
            None => {
                match t.parse::<usize>() {
                    Ok(0) => {
                        eprintln!("Element is zero");
                        return false;
                    }
                    Ok(elem) => new_elems.push(elem - 1),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
                }
            },
        }
    }
    list.elems = new_elems.into_iter().filter(|e| {
            list.start.map(|n| *e > n).unwrap_or(true) && list.end.map(|n| *e < n).unwrap_or(true)
    }).collect();
    list.elems.sort();
    list.elems.dedup();
    true
}

fn parse_delimiter(s: &String) -> Option<char>
{
    let mut iter = s.chars();
    match iter.next() {
        Some(c) => {
            match iter.next()  {
                Some(_) => {
                    eprintln!("Delimiter isn't single character");
                    return None;
                },
                None => (),
            }
            Some(c)
        },
        None => Some('\0'),
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "b:c:d:f:ns");
    let mut opts = Options {
        type_flag: TypeFlag::Bytes,
        list: List {
            start: None,
            elems: Vec::new(),
            end: None,
        },
        delimiter: '\t',
        only_delimited_flag: false,
    };
    let mut is_list = false;
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('b', Some(opt_arg)))) => {
                opts.type_flag = TypeFlag::Bytes;
                if !parse_list(&opt_arg, &mut opts.list) {
                    return 1;
                }
                is_list = true;
            },
            Some(Ok(Opt('b', None))) => {
                eprintln!("option requires an argument -- 'b'");
                return 1;
            },
            Some(Ok(Opt('c', Some(opt_arg)))) => {
                opts.type_flag = TypeFlag::Chars;
                if !parse_list(&opt_arg, &mut opts.list) {
                    return 1;
                }
                is_list = true;
            },
            Some(Ok(Opt('c', None))) => {
                eprintln!("option requires an argument -- 'c'");
                return 1;
            },
            Some(Ok(Opt('d', Some(opt_arg)))) => {
                match parse_delimiter(&opt_arg) {
                    Some(c) => opts.delimiter = c,
                    None    => return 1,
                }
            },
            Some(Ok(Opt('d', None))) => {
                eprintln!("option requires an argument -- 'd'");
                return 1;
            },
            Some(Ok(Opt('f', Some(opt_arg)))) => {
                opts.type_flag = TypeFlag::Fields;
                if !parse_list(&opt_arg, &mut opts.list) {
                    return 1;
                }
                is_list = true;
            },
            Some(Ok(Opt('f', None))) => {
                eprintln!("option requires an argument -- 'f'");
                return 1;
            },
            Some(Ok(Opt('n', _))) => (),
            Some(Ok(Opt('s', _))) => opts.only_delimited_flag = true,            
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
    if !is_list {
        eprintln!("No list");
        return 1;
    }
    let mut status = 0;
    let paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    if !paths.is_empty() {
        for path in &paths {
            if !cut_file(path, &opts) { status = 1; }
        }
    } else {
        if !cut(&mut stdin(), None, &opts) { status = 1; }
    }
    status
}
