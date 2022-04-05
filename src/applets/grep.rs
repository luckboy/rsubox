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
use libc;
use crate::utils::*;

#[derive(PartialEq)]
enum RegexFlag
{
    BasicRegex,
    FixedString,
    ExtendedRegex,
}

enum OutputFlag
{
    None,
    Count,
    OnlyFileName,
    Quiet,
}

struct Options
{
    patterns: Vec<String>,
    regex_flag: RegexFlag,
    output_flag: OutputFlag,
    ignored_case_flag: bool,
    line_number_flag: bool,
    no_message_flag: bool,
    inverted_match_flag: bool,
    line_flag: bool,
}

enum CompiledPatternList
{
    FixedStringList(Vec<String>),
    RegexList(Vec<Regex>),
}

fn print_path(path: Option<&Path>)
{
    match path {
        Some(path) => println!("{}", path.to_string_lossy()),
        None       => println!("(standard input)"),
    }
}

fn print_path_and_colon(path: Option<&Path>, is_more_than_one_file: bool)
{
    if is_more_than_one_file {
        match path {
            Some(path) => print!("{}:", path.to_string_lossy()),
            None       => print!("(standard input):"),
        }
    }
}

fn is_match(compiled_patterns: &CompiledPatternList, s: &str, opts: &Options) -> bool
{
    let mut res = false;
    match compiled_patterns {
        CompiledPatternList::FixedStringList(fixed_ss) => {
            let t = if opts.ignored_case_flag {
                s.to_uppercase()
            } else {
                String::from(s)
            };
            for fixed_s in fixed_ss {
                let fixed_t = if opts.ignored_case_flag {
                    fixed_s.to_uppercase()
                } else {
                    fixed_s.clone()
                };
                if !opts.line_flag {
                    if t.contains(fixed_t.as_str()) {
                        res = true;
                        break;
                    }
                } else {
                    if t == fixed_t {
                        res = true;
                        break;
                    }
                }
            }
        },
        CompiledPatternList::RegexList(regexes) => {
            for regex in regexes {
                let mut matches: Vec<RegexMatch> = Vec::new();
                if regex.is_match(s, Some((1, &mut matches)), 0) {
                    match matches.get(0) {
                        Some(m) => {
                            if !opts.line_flag {
                                res = true;
                                break;
                            } else {
                                if m.start == 0 && m.end == s.len() {
                                    res = true;
                                    break;
                                }
                            }
                        },
                        None => (),
                    }
                }
            }
        },
    };
    if !opts.inverted_match_flag {
        res
    } else {
        !res
    }
}

fn grep<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options, compiled_patterns: &CompiledPatternList, is_more_than_one_file: bool) -> Option<bool>
{
    let mut r = BufReader::new(r);
    let mut i: i64 = 0;
    let mut count: i64 = 0;
    let mut res = false;
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                if is_match(compiled_patterns, &line_without_newline, opts) {
                    res = true;
                    count += 1;
                    match opts.output_flag {
                        OutputFlag::None => {
                            print_path_and_colon(path, is_more_than_one_file);
                            if opts.line_number_flag {
                                print!("{}:", i + 1);
                            }
                            println!("{}", line_without_newline);
                        },
                        OutputFlag::Count => (),
                        OutputFlag::OnlyFileName => {
                            print_path(path);
                            break;
                        },
                        OutputFlag::Quiet => break,
                    }
                }
                i += 1;
            },
            Err(err) => {
                if !opts.no_message_flag {
                    match path {
                        Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                        None       => eprintln!("{}", err),
                    }
                }
                return None;
            },
        }
    }
    match opts.output_flag {
        OutputFlag::Count => {
            print_path_and_colon(path, is_more_than_one_file);
            println!("{}", count);
        },
        _                 => (),
    }
    Some(res)
}

fn grep_file(path: &String, opts: &Options, compiled_patterns: &CompiledPatternList, is_more_than_one_file: bool) -> Option<bool>
{
    if path == &String::from("-") {
        grep(&mut stdin(), None, opts, compiled_patterns, is_more_than_one_file)
    } else {
        match File::open(path) {
            Ok(mut file) => grep(&mut file, Some(path.as_ref()), opts, compiled_patterns, is_more_than_one_file),
            Err(err)     => {
                if !opts.no_message_flag {
                    eprintln!("{}: {}", path, err);
                }
                None
            },
        }
    }
}

fn read_patterns<R: Read>(r: R, path: Option<&Path>, patterns: &mut Vec<String>) -> bool
{
    let mut r = BufReader::new(r);
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                if !line_without_newline.is_empty() {
                    patterns.push(String::from(line_without_newline));
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
    true
}

fn read_patterns_from_file<P: AsRef<Path>>(path: P, patterns: &mut Vec<String>) -> bool
{
    match File::open(path.as_ref()) {
        Ok(mut file) => read_patterns(&mut file, Some(path.as_ref()), patterns),
        Err(err)     => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    }
}

fn add_patterns_from_string(s: &String, patterns: &mut Vec<String>) -> bool
{
    let mut cursor = Cursor::new(s.as_bytes());
    read_patterns(&mut cursor, None, patterns)
}

fn compile_patterns(opts: &Options) -> Option<CompiledPatternList>
{
    match opts.regex_flag {
        RegexFlag::BasicRegex | RegexFlag::ExtendedRegex => {
            let mut regexes: Vec<Regex> = Vec::new();
            let mut flags =  0;
            if opts.regex_flag == RegexFlag::ExtendedRegex {
                flags |= libc::REG_EXTENDED;
            }
            if opts.ignored_case_flag {
                flags |= libc::REG_ICASE;
            }
            for pattern in &opts.patterns {
                match Regex::new(pattern, flags) {
                    Ok(regex) => regexes.push(regex),
                    Err(err)  => {
                        eprintln!("{}", err);
                        return None;
                    },
                }
            }
            Some(CompiledPatternList::RegexList(regexes))
        },
        RegexFlag::FixedString => {
            Some(CompiledPatternList::FixedStringList(opts.patterns.clone()))
        },
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "cEe:Ff:ilnqsvx");
    let mut opts = Options {
        patterns: Vec::new(),
        regex_flag: RegexFlag::BasicRegex,
        output_flag: OutputFlag::None,
        ignored_case_flag: false,
        line_number_flag: false,
        no_message_flag: false,
        inverted_match_flag: false,
        line_flag: false,
    };
    let mut is_regex_or_file = false;
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('c', _))) => opts.output_flag = OutputFlag::Count,
            Some(Ok(Opt('E', _))) => opts.regex_flag = RegexFlag::ExtendedRegex,
            Some(Ok(Opt('e', Some(opt_arg)))) => {
                if !add_patterns_from_string(&opt_arg, &mut opts.patterns) {
                    return 2;
                }
                is_regex_or_file = true;
            },
            Some(Ok(Opt('e', None))) => {
                eprintln!("option requires an argument -- 'e'");
                return 2;
            },
            Some(Ok(Opt('F', _))) => opts.regex_flag = RegexFlag::FixedString,
            Some(Ok(Opt('f', Some(opt_arg)))) => {
                if !read_patterns_from_file(&opt_arg, &mut opts.patterns) {
                    return 2;
                }
                is_regex_or_file = true;
            },
            Some(Ok(Opt('f', None))) => {
                eprintln!("option requires an argument -- 'f'");
                return 2;
            },
            Some(Ok(Opt('i', _))) => opts.ignored_case_flag = true,
            Some(Ok(Opt('l', _))) => opts.output_flag = OutputFlag::OnlyFileName,
            Some(Ok(Opt('n', _))) => opts.line_number_flag = true,
            Some(Ok(Opt('q', _))) => opts.output_flag = OutputFlag::Quiet,
            Some(Ok(Opt('s', _))) => opts.no_message_flag = true,
            Some(Ok(Opt('v', _))) => opts.inverted_match_flag = true,
            Some(Ok(Opt('x', _))) => opts.line_flag = true,
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
    let mut arg_iter = args.iter().skip(opt_parser.index());
    if !is_regex_or_file {
        match arg_iter.next() {
            Some(patterns) => {
                if !add_patterns_from_string(patterns, &mut opts.patterns) {
                    return 2;
                }
            },
            None => {
                eprintln!("Too few arguments");
                return 2;
            },
        }
    }
    let compiled_patterns = match compile_patterns(&opts) {
        Some(compiled_patterns) => compiled_patterns,
        None                    => return 2,
    };
    let mut status = 1;
    let paths: Vec<&String> = arg_iter.collect();
    if !paths.is_empty() {
        for path in &paths {
            match grep_file(path, &opts, &compiled_patterns, paths.len() > 1) {
                Some(true)  => {
                    if status <= 1 { status = 0; }
                },
                Some(false) => (),
                None        => status = 2,
            }
        }
    } else {
        match grep(&mut stdin(), None, &opts, &compiled_patterns, false) {
            Some(true)  => status = 0,
            Some(false) => (),
            None        => status = 2,
       }
    }
    status
}
