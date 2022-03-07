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

#[derive(PartialEq)]
enum VerboseFlag
{
    None,
    Verbose,
    Silent,
}

struct Options
{
    verbose_flag: VerboseFlag,
}

fn cmp<R: Read, S: Read>(r1: &mut R, r2: &mut S, path1: Option<&Path>, path2: Option<&Path>, opts: &Options) -> Option<bool>
{
    let mut r1 = ByteReader::new(BufReader::new(r1));
    let mut r2 = ByteReader::new(BufReader::new(r2));
    let mut res = Some(true);
    let mut byte_count: u64 = 1;
    let mut line_count: u64 = 1;
    loop {
        let mut b1: u8 = 0;
        let mut b2: u8 = 0;
        match r1.read_byte(&mut b1) {
            Ok(false) => {
                match r2.read_byte(&mut b2) {
                    Ok(false) => break,
                    Ok(_) => {
                        if opts.verbose_flag != VerboseFlag::Silent {
                            eprintln!("EOF on {}", path1.map(|p| p.to_string_lossy().into_owned()).unwrap_or(String::from("-")));
                        }
                        res = Some(false);
                        break;
                    },
                    Err(err) => {
                        if opts.verbose_flag != VerboseFlag::Silent {
                            match path2 {
                                Some(path2) => eprintln!("{}: {}", path2.to_string_lossy(), err),
                                None        => eprintln!("{}", err),
                            }
                        }
                        res = None;
                        break;
                    },
                }
            },
            Ok(_) => {
                match r2.read_byte(&mut b2) {
                    Ok(false) => {
                        if opts.verbose_flag != VerboseFlag::Silent {
                            eprintln!("EOF on {}", path2.map(|p| p.to_string_lossy().into_owned()).unwrap_or(String::from("-")));
                        }
                        res = Some(false);
                        break;
                    },
                    Ok(_) => {
                        if b1 != b2 {
                            match opts.verbose_flag {
                                VerboseFlag::None => {
                                    let path1 = path1.map(|p| p.to_string_lossy().into_owned()).unwrap_or(String::from("-"));
                                    let path2 = path2.map(|p| p.to_string_lossy().into_owned()).unwrap_or(String::from("-"));
                                    println!("{} {} differ: char {}, line {}", path1, path2, byte_count, line_count);
                                    res = Some(false);
                                    break;
                                },
                                VerboseFlag::Verbose => {
                                    println!("{} {:o} {:o}", byte_count, b1, b2);
                                    res = Some(false);
                                },
                                VerboseFlag::Silent => {
                                    res = Some(false);
                                    break;
                                },
                            }
                        }
                        byte_count += 1;
                        if b1 == b'\n' { line_count += 1; }
                    },
                    Err(err) => {
                        if opts.verbose_flag != VerboseFlag::Silent {
                            match path2 {
                                Some(path2) => eprintln!("{}: {}", path2.to_string_lossy(), err),
                                None        => eprintln!("{}", err),
                            }
                        }
                        res = None;
                        break;
                    },
                }
            },
            Err(err) => {
                if opts.verbose_flag != VerboseFlag::Silent {
                    match path1 {
                        Some(path1) => eprintln!("{}: {}", path1.to_string_lossy(), err),
                        None        => eprintln!("{}", err),
                    }
                }
                res = None;
                break;
            },
        }
    }
    res
}

fn cmp_files(path1: &String, path2: &String, opts: &Options) -> Option<bool>
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
                        Ok(mut file2) => cmp(&mut file1, &mut file2, Some(path1), Some(path2), opts),
                        Err(err) => {
                            if opts.verbose_flag != VerboseFlag::Silent {
                                eprintln!("{}: {}", path2.to_string_lossy(), err);
                            }
                            None
                        }
                    }
                },
                Err(err) => {
                    if opts.verbose_flag != VerboseFlag::Silent {
                        eprintln!("{}: {}", path1.to_string_lossy(), err);
                    }
                    None
                },
            }
        },
        (Some(path1), None) => {
            match File::open(path1) {
                Ok(mut file1) => cmp(&mut file1, &mut stdin(), Some(path1), None, opts),
                Err(err) => {
                    if opts.verbose_flag != VerboseFlag::Silent {
                        eprintln!("{}: {}", path1.to_string_lossy(), err);
                    }
                    None
                },
            }
        },
        (None, Some(path2)) => {
            match File::open(path2) {
                Ok(mut file2) => cmp(&mut stdin(), &mut file2, None, Some(path2), opts),
                Err(err) => {
                    if opts.verbose_flag != VerboseFlag::Silent {
                        eprintln!("{}: {}", path2.to_string_lossy(), err);
                    }
                    None
                },
            }
        },
        (None, None) => Some(true),
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "ls");
    let mut opts = Options {
        verbose_flag: VerboseFlag::None,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('l', _))) => {
                if opts.verbose_flag == VerboseFlag::Silent {
                    eprintln!("Incompatible options");
                    return 2;
                }
                opts.verbose_flag = VerboseFlag::Verbose;
            },
            Some(Ok(Opt('s', _))) => {
                if opts.verbose_flag == VerboseFlag::Verbose {
                    eprintln!("Incompatible options");
                    return 2;
                }
                opts.verbose_flag = VerboseFlag::Silent;
            },
            Some(Ok(Opt(c, _))) => {
                eprintln!("unknown option -- {:?}", c);
                return 2;
            },
            Some(Err(err)) => {
                eprintln!("{}", err);
                return 2;
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
                        return 2;
                    }
                    match cmp_files(&path1, &path2, &opts) {
                        Some(true)  => 0,
                        Some(false) => 1,
                        None        => 2,
                    }
                },
                None => {
                    eprintln!("Too few arguments");
                    2
                },
            }
        },
        None => {
            eprintln!("Too few arguments");
            2
        },
    }
}
