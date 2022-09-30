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

enum TypeFlag
{
    Bytes,
    Lines,
}

struct Options
{
    suffix_len: usize,
    type_flag: TypeFlag,
    count: u64,
}

fn is_next_suffix(suffix: &[u32]) -> bool
{ !suffix.iter().all(|x| *x == ('z' as u32)) }

fn next_suffix(suffix: &mut [u32])
{
    for i in (0..suffix.len()).rev() {
        if suffix[i] >= ('z' as u32) {
            suffix[i] = 'a' as u32;
        } else {
            suffix[i] += 1;
            break;
        }
    }
}

fn split<R: Read>(r: &mut R, path: Option<&Path>, name: &String, opts: &Options) -> bool
{
    let mut r = ByteReader::new(BufReader::new(r));
    let mut suffix: Vec<u32> = vec!['a' as u32; opts.suffix_len];
    let mut is_success = true;
    loop {
        let tmp_is_next_suffix = is_next_suffix(suffix.as_slice());
        let mut b: u8 = 0;
        if 0 < opts.count || !tmp_is_next_suffix {
            match r.read_byte(&mut b) {
                Ok(false) => break,
                Ok(true) => (),
                Err(err) => {
                    match path {
                        Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                        None       => eprintln!("{}", err),
                    }
                    is_success = false;
                    break;
                },
            }
        }
        let mut out_path = name.clone();
        out_path.push_str(suffix.iter().map(|x| char::from_u32(*x).unwrap()).collect::<String>().as_str());
        match File::create(&out_path) {
            Ok(out_file) => {
                let mut w = BufWriter::new(&out_file);
                let mut i: u64 = 0;
                let mut is_stop = false;
                let mut is_first = true;
                if i < opts.count {
                    loop {
                        let res = if is_first {
                            Ok(true)
                        } else {
                            r.read_byte(&mut b)
                        };
                        match res {
                            Ok(false) => {
                                is_stop = true;
                                break;
                            },
                            Ok(true) => {
                                let buf: [u8; 1] = [b];
                                match w.write_all(&buf) {
                                    Ok(())   => (),
                                    Err(err) => {
                                        eprintln!("{}: {}", out_path, err);
                                        is_success = false;
                                        break;
                                    },
                                }
                                match opts.type_flag {
                                    TypeFlag::Bytes => i += 1,
                                    TypeFlag::Lines => {
                                        if b == b'\n' {
                                            i += 1;
                                        }
                                    },
                                }
                                if tmp_is_next_suffix {
                                    if i >= opts.count {
                                        break;
                                    }
                                }
                            },
                            Err(err) => {
                                match path {
                                    Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                                    None       => eprintln!("{}", err),
                                }
                                is_success = false;
                                is_stop = true;
                            },
                        }
                        is_first = false;
                    }
                }
                match w.flush() {
                    Ok(()) => (),
                    Err(err) => {
                        eprintln!("{}: {}", out_path, err);
                        return false;
                    },
                }
                if is_stop { break; }
            },
            Err(err) => {
                eprintln!("{}: {}", out_path, err);
                is_success = false;
            },
        }
        if !tmp_is_next_suffix { break; }
        next_suffix(suffix.as_mut_slice());
    }
    is_success
}

fn split_file(path: &String, name: &String, opts: &Options) -> bool
{
    if path == &String::from("-") {
        split(&mut stdin(), None, name, opts)
    } else {
        match File::open(path) {
            Ok(mut file) => split(&mut file, Some(path.as_ref()), name, opts),
            Err(err)     => {
                eprintln!("{}: {}", path, err);
                false
            },
        }
    }
}

fn parse_suffix_len(s: &String) -> Option<usize>
{
    match s.parse::<usize>() {
        Ok(0)    => {
            eprintln!("Suffix length is zero");
            None
        },
        Ok(n)    => Some(n),
        Err(err) => {
            eprintln!("{}", err);
            None
        }
    }
}

fn parse_line_count(s: &String) -> Option<u64>
{
    match s.parse::<u64>() {
        Ok(n)    => Some(n),
        Err(err) => {
            eprintln!("{}", err);
            None
        }
    }
}

fn parse_byte_count(s: &String) -> Option<u64>
{
    if s.ends_with('k') {
        match s[0..(s.len() - 1)].parse::<u64>() {
            Ok(n)    => {
                match n.checked_mul(1024) {
                    Some(x) => Some(x),
                    None    => {
                        eprintln!("Overflow");
                        None
                    },
                }
            },
            Err(err) => {
                eprintln!("{}", err);
                None
            }
        }
    } else if s.ends_with('m') {
        match s[0..(s.len() - 1)].parse::<u64>() {
            Ok(n)    => {
                match n.checked_mul(1024 * 1024) {
                    Some(x) => Some(x),
                    None    => {
                        eprintln!("Overflow");
                        None
                    },
                }
            },
            Err(err) => {
                eprintln!("{}", err);
                None
            }
        }
    } else {
        match s.parse::<u64>() {
            Ok(n)    => Some(n),
            Err(err) => {
                eprintln!("{}", err);
                None
            }
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "a:b:l:");
    let mut opts = Options {
        suffix_len: 2,
        type_flag: TypeFlag::Lines,
        count: 1000,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('a', Some(opt_arg)))) => {
                match parse_suffix_len(&opt_arg) {
                    Some(n) => opts.suffix_len = n,
                    None    => return 1,
                }
            },
            Some(Ok(Opt('a', None))) => {
                eprintln!("option requires an argument -- 'a'");
                return 1;
            },
            Some(Ok(Opt('b', Some(opt_arg)))) => {
                opts.type_flag = TypeFlag::Bytes;
                match parse_byte_count(&opt_arg) {
                    Some(n) => opts.count = n,
                    None    => return 1,
                }
            },
            Some(Ok(Opt('b', None))) => {
                eprintln!("option requires an argument -- 'b'");
                return 1;
            },
            Some(Ok(Opt('l', Some(opt_arg)))) => {
                opts.type_flag = TypeFlag::Lines;
                match parse_line_count(&opt_arg) {
                    Some(n) => opts.count = n,
                    None    => return 1,
                }
            },
            Some(Ok(Opt('l', None))) => {
                eprintln!("option requires an argument -- 'l'");
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
    let args: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    match args.get(0) {
        Some(path) => {
            match args.get(1) {
                Some(name) => {
                    if args.len() > 2 {
                        eprintln!("Too many arguments");
                        return 1;
                    }
                    if !split_file(path, &name, &opts) { status = 1; }
                },
                None           => {
                    if !split_file(path, &String::from("x"), &opts) { status = 1; }
                },
            }
        },
        None => {
            if !split_file(&String::from("-"), &String::from("x"), &opts) { status = 1; }
        },
    }
    status
}
