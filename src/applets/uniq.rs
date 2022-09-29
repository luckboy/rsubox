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

enum CommandFlag
{
    None,
    Count,
    Delete,
    Unique,
}

enum IgnoringFlag
{
    None,
    Fields(usize),
    Chars(usize),
}

struct Options
{
    command_flag: CommandFlag,
    ignoring_flag: IgnoringFlag,
}

fn iqnore_filds_or_chars<'a>(s: &'a str, opts: &Options) -> &'a str
{
    match opts.ignoring_flag {
        IgnoringFlag::None => s,
        IgnoringFlag::Fields(n) => {
            let mut iter = s.char_indices();
            let mut i: usize = 0;
            for _ in 0..n {
                let mut is_stop = false;
                loop {
                    match iter.next() {
                        Some((_, c)) if c.is_whitespace() => (),
                        Some((_, _)) => break,
                        None => {
                            is_stop = true;
                            break;
                        },
                    }
                }
                if is_stop {
                    i = s.len();
                    break;
                }
                loop {
                    match iter.next() {
                        Some((_, c)) if !c.is_whitespace() => (),
                        Some((j, _)) => {
                            i = j;
                            break;
                        },
                        None => {
                            is_stop = true;
                            break;
                        },
                    }
                }
                if is_stop {
                    i = s.len();
                    break;
                }
            }
            &s[i..]
        },
        IgnoringFlag::Chars(n) => {
            let mut iter = s.char_indices();
            match iter.nth(n) {
                Some((i, _)) => &s[i..],
                None         => &s[s.len()..],
            }
        },
    }
}

fn uniq<R: Read, W: Write>(r: &mut R, w: &mut W, in_path: Option<&Path>, out_path: Option<&Path>, opts: &Options) -> bool
{
    let mut r = BufReader::new(r);
    let mut w = BufWriter::new(w);
    let mut prev_line: Option<String> = None;
    let mut is_prev_line_printing = false;
    let mut count: u64 = 1;
    let mut is_prev_repeated = false;
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                let is_repeated = match &prev_line {
                    Some(prev_line) => {
                        let s = iqnore_filds_or_chars(prev_line.as_str(), opts);
                        let t = iqnore_filds_or_chars(line_without_newline, opts);
                        s == t
                    },
                    None            => false,
                };
                match opts.command_flag {
                    CommandFlag::None => {
                        if !is_repeated {
                            match write!(w, "{}\n", line_without_newline) {
                                Ok(())   => (),
                                Err(err) => {
                                    match out_path {
                                        Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                                        None           => eprintln!("{}", err),
                                    }
                                    return false;
                                },
                            }
                            prev_line = Some(String::from(line_without_newline));
                        }
                    },
                    CommandFlag::Count => {
                        if is_repeated {
                            count += 1;
                        } else {
                            match &prev_line {
                                Some(prev_line) => {
                                    match write!(w, "{} {}\n", count, prev_line) {
                                        Ok(())   => (),
                                        Err(err) => {
                                            match out_path {
                                                Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                                                None           => eprintln!("{}", err),
                                            }
                                            return false;
                                        },
                                    }
                                },
                                None            => (),
                            }
                            count = 1;
                            prev_line = Some(String::from(line_without_newline));
                            is_prev_line_printing = true;
                        }
                    },
                    CommandFlag::Delete => {
                        if is_repeated {
                            is_prev_line_printing = true;
                        } else {
                            if is_prev_repeated {
                                match &prev_line {
                                    Some(prev_line) => {
                                        match write!(w, "{}\n", prev_line) {
                                            Ok(())   => (),
                                            Err(err) => {
                                                match out_path {
                                                    Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                                                    None           => eprintln!("{}", err),
                                                }
                                                return false;
                                            },
                                        }
                                    },
                                    None            => (),
                                }
                            }
                            prev_line = Some(String::from(line_without_newline));
                            is_prev_line_printing = false;
                        }
                        is_prev_repeated = is_repeated;
                    },
                    CommandFlag::Unique => {
                        if is_repeated {
                            is_prev_line_printing = false;
                        } else {
                            if !is_prev_repeated {
                                match &prev_line {
                                    Some(prev_line) => {
                                        match write!(w, "{}\n", prev_line) {
                                            Ok(())   => (),
                                            Err(err) => {
                                                match out_path {
                                                    Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                                                    None           => eprintln!("{}", err),
                                                }
                                                return false;
                                            },
                                        }
                                    },
                                    None            => (),
                                }
                            }
                            prev_line = Some(String::from(line_without_newline));
                            is_prev_line_printing = true;
                        }
                        is_prev_repeated = is_repeated;
                    },
                }
            },
            Err(err) => {
                match in_path {
                    Some(in_path) => eprintln!("{}: {}", in_path.to_string_lossy(), err),
                    None          => eprintln!("{}", err),
                }
                return false;
            }
        }
    }
    if is_prev_line_printing {
        match opts.command_flag {
            CommandFlag::Count => {
                match &prev_line {
                    Some(prev_line) => {
                        match write!(w, "{} {}\n", count, prev_line) {
                            Ok(())   => (),
                            Err(err) => {
                                match out_path {
                                    Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                                    None           => eprintln!("{}", err),
                                }
                                return false;
                            },
                        }
                    },
                    None            => (),
                }
            },
            _ => {
                match &prev_line {
                    Some(prev_line) => {
                        match write!(w, "{}\n", prev_line) {
                            Ok(())   => (),
                            Err(err) => {
                                match out_path {
                                    Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                                    None           => eprintln!("{}", err),
                                }
                                return false;
                            },
                        }
                    },
                    None            => (),
                }
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

fn uniq_file(in_path: &String, out_path: Option<&Path>, opts: &Options) -> bool
{
    if in_path == &String::from("-") {
        uniq(&mut stdin(), &mut stdout(), None, None, opts)
    } else {
        match File::open(in_path) {
            Ok(mut in_file) => {
                match out_path {
                    Some(out_path) => {
                        match File::create(out_path) {
                            Ok(mut out_file) => uniq(&mut in_file, &mut out_file, Some(in_path.as_ref()), Some(out_path), opts),
                            Err(err)         => {
                                eprintln!("{}: {}", out_path.to_string_lossy(), err);
                                false
                            },
                        }
                    },
                    None           => uniq(&mut in_file, &mut stdout(), Some(in_path.as_ref()), None, opts),
                }
            },
            Err(err)        => {
                eprintln!("{}: {}", in_path, err);
                false
            },
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "cdf:s:u");
    let mut opts = Options {
        command_flag: CommandFlag::None,
        ignoring_flag: IgnoringFlag::None, 
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('c', _))) => opts.command_flag = CommandFlag::Count,
            Some(Ok(Opt('d', _))) => opts.command_flag = CommandFlag::Delete,
            Some(Ok(Opt('f', Some(opt_arg)))) => {
                match opt_arg.parse::<usize>() {
                    Ok(n)    => opts.ignoring_flag = IgnoringFlag::Fields(n),
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('f', None))) => {
                eprintln!("option requires an argument -- 'f'");
                return 1;
            },
            Some(Ok(Opt('s', Some(opt_arg)))) => {
                match opt_arg.parse::<usize>() {
                    Ok(n)    => opts.ignoring_flag = IgnoringFlag::Chars(n),
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('s', None))) => {
                eprintln!("option requires an argument -- 's'");
                return 1;
            },
            Some(Ok(Opt('u', _))) => opts.command_flag = CommandFlag::Unique,
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
    match paths.get(0) {
        Some(in_path) => {
            match paths.get(1) {
                Some(out_path) => {
                    if paths.len() > 2 {
                        eprintln!("Too many arguments");
                        return 1;
                    }
                    if !uniq_file(in_path, Some(out_path.as_ref()), &opts) { status = 1; }
                },
                None           => {
                    if !uniq_file(in_path, None, &opts) { status = 1; }
                },
            }
        },
        None          => {
            if !uniq_file(&String::from("-"), None, &opts) { status = 1; }
        },
    }
    status
}
