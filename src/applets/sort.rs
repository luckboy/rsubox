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
use std::cmp::Ordering;
use std::cmp::min;
use std::fs::*;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

enum CommandFlag
{
    Sort,
    Check,
    Merge,
}

struct OrderOptions
{
    start_b_flag: bool,
    end_b_flag: bool,
    d_flag: bool,
    f_flag: bool,
    i_flag: bool,
    n_flag: bool,
    r_flag: bool,
}

#[derive(Copy, Clone)]
struct KeyPosition
{
    field_pos: usize,
    char_pos: Option<usize>,
}

struct Key
{
    field_start: KeyPosition,
    field_end: Option<KeyPosition>,
    order_options: OrderOptions,
}

struct Options
{
    command_flag: CommandFlag,
    unique_flag: bool,
    output_path: Option<PathBuf>,
    separator: Option<char>,
    order_options: OrderOptions,
    keys: Vec<Key>,
}

fn is_sorted_string_array_by<F>(ss: &[String], is_unique: bool, mut f: F) -> bool
    where F: FnMut(&String, &String) -> Ordering
{
    if ss.len() > 1 {
        let mut is_sorted = true;
        for i in 0..(ss.len() - 1) {
            match f(&ss[i], &ss[i + 1]) {
                Ordering::Less => (),
                Ordering::Equal if !is_unique => (),
                _ => {
                    is_sorted = false;
                    break;
                },
            }
        }
        is_sorted
    } else {
        true
    }
}

fn merge_string_arrays_by<F>(ss: &[String], ts: &[String], mut f: F) -> Vec<String>
    where F: FnMut(&String, &String) -> Ordering
{
    let mut us: Vec<String> = Vec::new();
    let mut i = 0;
    let mut j = 0;
    while i < ss.len() && j < ts.len() {
        match f(&ss[i], &ts[j]) {
            Ordering::Less | Ordering::Equal => {
                us.push(ss[i].clone());
                i += 1;
            },
            Ordering::Greater => {
                us.push(ts[j].clone());
                j += 1;
            }
        }
    }
    while i < ss.len() {
        us.push(ss[i].clone());
        i += 1
    }
    while j < ts.len() {
        us.push(ts[j].clone());
        j += 1
    }
    us
}

fn str_to_number_str(s: &str) -> &str
{
    let t = if s.starts_with('-') { &s[1..] } else { s };
    let u = t.trim_start_matches(|c: char| c.is_ascii_digit());
    &s[0..(u.as_ptr() as usize - s.as_ptr() as usize)]
}

fn simply_compare_strs_for_order_opts(s1: &str, s2: &str, order_opts: &OrderOptions) -> Ordering
{
    let res = if order_opts.n_flag {
        let t1 = str_to_number_str(s1);
        let n1 = if t1.is_empty() || t1 == "-" {
            0
        } else {
            match t1.parse::<i64>() {
                Ok(n)  => n,
                Err(_) => {
                    if s1.starts_with('-') { i64::MIN } else { i64::MAX }
                },
            }
        };
        let t2 = str_to_number_str(s2);
        let n2 = if t2.is_empty() || t2 == "-" {
            0
        } else {
            match t2.parse::<i64>() {
                Ok(n)  => n,
                Err(_) => {
                    if s2.starts_with('-') { i64::MIN } else { i64::MAX }
                },
            }
        };
        n1.cmp(&n2)
    } else {
        s1.cmp(s2)
    };
    if order_opts.r_flag {
        match res {
            Ordering::Less    => Ordering::Greater,
            Ordering::Equal   => Ordering::Equal,
            Ordering::Greater => Ordering::Less,
        }
    } else {
        res
    }
}

fn simply_compare_strings_for_order_opts(s1: &String, s2: &String, order_opts: &OrderOptions) -> Ordering
{ simply_compare_strs_for_order_opts(s1.as_str(), s2.as_str(), order_opts) }

fn simply_compare_strings(s1: &String, s2: &String, opts: &Options) -> Ordering
{ simply_compare_strings_for_order_opts(s1, s2, &opts.order_options) }

fn get_string_for_order_opts(s: &str, order_opts: &OrderOptions) -> String
{
    let s = if order_opts.start_b_flag { s.trim_start() } else { s };
    let s = if order_opts.end_b_flag { s.trim_end() } else { s };
    let new_s = if order_opts.d_flag {
        s.replace(|c: char| { !c.is_whitespace() && !c.is_alphanumeric() }, "")
    } else {
        String::from(s)
    };
    let new_s = if order_opts.i_flag {
        new_s.replace(|c: char| { c != ' ' && c.is_control() }, "")
    } else {
        new_s
    };
    let new_s = if order_opts.f_flag {
        new_s.to_uppercase()
    } else {
        new_s
    };
    new_s
}

fn compare_strs_for_order_opts(s1: &str, s2: &str, order_opts: &OrderOptions) -> Ordering
{
    let new_s1 = get_string_for_order_opts(s1, order_opts);
    let new_s2 = get_string_for_order_opts(s2, order_opts);
    simply_compare_strings_for_order_opts(&new_s1, &new_s2, order_opts)
}

fn compare_strings(s1: &String, s2: &String, opts: &Options) -> Ordering
{ compare_strs_for_order_opts(s1.as_str(), s2.as_str(), &opts.order_options) }

fn get_fields_from_str<'a>(s: &'a str, opts: &Options) -> Vec<&'a str>
{
    match opts.separator {
        Some(c) => s.split(c).collect(),
        None    => s.split(char::is_whitespace).collect(),
    }
}

fn get_string_for_key<'a>(s: &'a str, fields: &[&'a str], key: &Key) -> &'a str
{
    let start = match fields.get(key.field_start.field_pos) {
        Some(field) => {
            let i = field.as_ptr() as usize - s.as_ptr() as usize;
            match key.field_start.char_pos {
                Some(char_pos) => i + char_pos,
                None           => i,
            }
        },
        None        => s.len(),
    };
    let end = match key.field_end {
        Some(field_end) => {
            match fields.get(field_end.field_pos) {
                Some(field) => {
                    let i = field.as_ptr() as usize - s.as_ptr() as usize;
                    match field_end.char_pos {
                        Some(char_pos) => i + char_pos + 1,
                        None           => i + field.len(),
                    }
                },
                None => s.len(),
            }
        },
        None => s.len(),
    };
    if start <= end {
        &s[min(start, s.len())..min(end, s.len())]
    } else {
        &s[min(start, s.len())..min(start, s.len())]
    }
}

fn compare_strings_for_keys(s1: &String, s2: &String, opts: &Options) -> Ordering
{
    let t1 = s1.as_str();
    let t2 = s2.as_str();
    let fields1 = get_fields_from_str(t1, opts);
    let fields2 = get_fields_from_str(t2, opts);
    let mut res = Ordering::Equal;
    for key in &opts.keys {
        let u1 = get_string_for_key(t1, &fields1, key);
        let u2 = get_string_for_key(t2, &fields2, key);
        let order_opts = if key.order_options.start_b_flag || key.order_options.end_b_flag || key.order_options.d_flag || key.order_options.f_flag || key.order_options.i_flag || key.order_options.n_flag || key.order_options.r_flag {
            &key.order_options
        } else {
            &opts.order_options
        };
        if !order_opts.start_b_flag && !order_opts.end_b_flag && !order_opts.d_flag && !order_opts.f_flag && !order_opts.i_flag {
            res = simply_compare_strs_for_order_opts(u1, u2, order_opts);
        } else {
            res = compare_strs_for_order_opts(u1, u2, order_opts);
        }
        if res != Ordering::Equal {
            break;
        }
    }
    res
}

fn read_lines<R: Read>(r: &mut R, lines: &mut Vec<String>, path: Option<&Path>) -> bool
{
    let mut r = BufReader::new(r);
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0)    => break,
            Ok(_)    => lines.push(String::from(str_without_newline(line.as_str()))),
            Err(err) => {
                match path {
                    Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                    None       => eprintln!("{}", err),
                }
                return false
            },
        }
    }
    true
}

fn read_file_lines(path: &String, lines: &mut Vec<String>) -> bool
{
    if path == &String::from("-") {
        read_lines(&mut stdin(), lines, None)
    } else {
        match File::open(path) {
            Ok(mut file) => read_lines(&mut file, lines, Some(path.as_ref())),
            Err(err)     => {
                eprintln!("{}: {}", path, err);
                false
            },
        }
    }
}

fn write_lines<W: Write>(w: &mut W, lines: &[String], path: Option<&Path>) -> bool
{
    let mut w = BufWriter::new(w);
    for line in lines.iter() {
        match write!(w, "{}", line) {
            Ok(())   => (),
            Err(err) => {
                match path {
                    Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                    None       => eprintln!("{}", err),
                }
                return false;
            },
        }
        match write!(w, "\n") {
            Ok(())   => (),
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
        Ok(())   => (),
        Err(err) => {
           match path {
               Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
               None       => eprintln!("{}", err),
           }
           return false;
        },
    }
    true
}

fn write_file_lines<P: AsRef<Path>>(path: P, lines: &[String]) -> bool
{
    match File::create(path.as_ref()) {
        Ok(mut file) => write_lines(&mut file, lines, Some(path.as_ref())),
        Err(err)     => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    }
}

fn sort_files<F>(paths: &[&String], opts: &Options, f: F) -> Option<bool>
    where F: Fn(&String, &String, &Options) -> Ordering
{
    let mut lines: Vec<String> = Vec::new();
    for path in paths.iter() {
        if !read_file_lines(path, &mut lines) {
            return None;
        }
    }
    lines.sort_by(|s, t| f(s, t, opts));
    if opts.unique_flag {
        lines.dedup_by(|s, t| f(s, t, opts) == Ordering::Equal);
    }
    let is_success = match &opts.output_path {
        Some(path_buf) => write_file_lines(path_buf.as_path(), &lines),
        None           => write_lines(&mut stdout(), &lines, None),
    };
    if is_success { Some(true) } else { None }
}

fn check_file<F>(path: &String, opts: &Options, f: F) -> Option<bool>
    where F: Fn(&String, &String, &Options) -> Ordering
{
    let mut lines: Vec<String> = Vec::new();
    if !read_file_lines(path, &mut lines) {
        return None
    }
    Some(is_sorted_string_array_by(&lines, opts.unique_flag, |s, t| f(s, t, opts)))
}

fn merge_files<F>(paths: &[&String], opts: &Options, f: F) -> Option<bool>
    where F: Fn(&String, &String, &Options) -> Ordering
{
    match paths.get(0) {
        Some(first_path) => {
            let mut lines: Vec<String> = Vec::new();
            if !read_file_lines(first_path, &mut lines) {
                return None;
            }
            for path in paths.iter().skip(1) {
                let mut tmp_lines: Vec<String> = Vec::new();
                if !read_file_lines(path, &mut tmp_lines) {
                    return None;
                }
                lines = merge_string_arrays_by(&lines, &tmp_lines, |s, t| f(s, t, opts));
            }
            if opts.unique_flag {
                lines.dedup_by(|s, t| f(s, t, opts) == Ordering::Equal);
            }
            let is_success = match &opts.output_path {
                Some(path_buf) => write_file_lines(path_buf.as_path(), &lines),
                None           => write_lines(&mut stdout(), &lines, None),
            };
            if is_success { Some(true) } else { None }
        },
        None => Some(true),
    }
}

fn set_order_opt(c: char, order_opts: &mut OrderOptions, is_start: bool) -> bool
{
    match c {
        'b' => {
            if is_start {
                order_opts.start_b_flag = true;
            } else {
                order_opts.end_b_flag = true;
            }
        },
        'd' => order_opts.d_flag = true,
        'f' => order_opts.f_flag = true,
        'i' => order_opts.i_flag = true,
        'n' => order_opts.n_flag = true,
        'r' => order_opts.r_flag = true,
        _   => {
            eprintln!("Invalid type");
            return false
        },
    }
    true
}

fn parse_key_part(s: &str, order_opts: &mut OrderOptions, is_start: bool) -> Option<KeyPosition>
{
    let s2 = s.trim_end_matches(char::is_alphabetic);
    let key_pos = match s2.split_once('.') {
        Some((t, u)) => {
            match t.parse::<usize>() {
                Ok(0) => {
                    eprintln!("Field position is zero");
                    return None;
                },
                Ok(n) => {
                    match u.parse::<usize>() {
                        Ok(0) => {
                            if !is_start {
                                KeyPosition {
                                    field_pos: n - 1,
                                    char_pos: None,
                                }
                            } else {
                                eprintln!("Character position is zero");
                                return None;
                            }
                        },
                        Ok(m) => {
                            KeyPosition {
                                field_pos: n - 1,
                                char_pos: Some(m - 1),
                            }
                        },
                        Err(err) => {
                            eprintln!("{}", err);
                            return None;
                        },
                    }
                },
                Err(err) => {
                    eprintln!("{}", err);
                    return None;
                },
            }
        },
        None => {
            match s2.parse::<usize>() {
                Ok(0) => {
                    eprintln!("Field position is zero");
                    return None;
                },
                Ok(n) => {
                    KeyPosition {
                        field_pos: n - 1,
                        char_pos: None,
                    }
                }
                Err(err) => {
                    eprintln!("{}", err);
                    return None;
                },
            }
        },
    };
    let s3 = &s[s2.len()..];
    for c in s3.chars() {
        if !set_order_opt(c, order_opts, is_start) {
            return None;
        }
    }
    Some(key_pos)
}

fn parse_and_add_key(s: &String, keys: &mut Vec<Key>) -> bool
{
    let mut order_opts = OrderOptions {
        start_b_flag: false,
        end_b_flag: false,
        d_flag: false,
        f_flag: false,
        i_flag: false,
        n_flag: false,
        r_flag: false,
    };
    let key = match s.split_once(',') {
        Some((t, u)) => {
            match parse_key_part(t, &mut order_opts, true) {
                Some(field_start) => {
                    match parse_key_part(u, &mut order_opts, false) {
                        Some(field_end) => {
                            Key {
                                field_start,
                                field_end: Some(field_end),
                                order_options: order_opts,
                            }
                        }
                        None => return false,
                    }
                },
                None => return false,
            }
        },
        None => {
            match parse_key_part(s.as_str(), &mut order_opts, true) {
                Some(field_start) => {
                    Key {
                        field_start,
                        field_end: None,
                        order_options: order_opts,
                    }
                },
                None => return false,
            }
        },
    };
    keys.push(key);
    true
}

fn parse_separator(s: &String) -> Option<char>
{
    let mut chars = s.chars();
    match chars.next() {
        Some(c) => {
            match chars.next()  {
                Some(_) => {
                    eprintln!("Separator isn't single character");
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
    let mut opt_parser = getopt::Parser::new(args, "bcdfik:mno:rt:u");
    let mut opts = Options  {
        command_flag: CommandFlag::Sort,
        unique_flag: false,
        output_path: None,
        separator: None,
        order_options: OrderOptions {
            start_b_flag: false,
            end_b_flag: false,
            d_flag: false,
            f_flag: false,
            i_flag: false,
            n_flag: false,
            r_flag: false,
        },
        keys: Vec::new(),
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt(c @ ('b' | 'd' | 'f' | 'i' | 'n' | 'r'), _))) => {
                set_order_opt(c, &mut opts.order_options, true);
            },
            Some(Ok(Opt('c', _))) => opts.command_flag = CommandFlag::Check,
            Some(Ok(Opt('k', Some(opt_arg)))) => {
                if !parse_and_add_key(&opt_arg, &mut opts.keys) {
                    return 2;
                }
            },
            Some(Ok(Opt('k', None))) => {
                eprintln!("option requires an argument -- 'k'");
                return 2;
            },
            Some(Ok(Opt('m', _))) => opts.command_flag = CommandFlag::Merge,
            Some(Ok(Opt('o', Some(opt_arg)))) => opts.output_path = Some(PathBuf::from(opt_arg)),
            Some(Ok(Opt('o', None))) => {
                eprintln!("option requires an argument -- 'o'");
                return 2;
            },
            Some(Ok(Opt('t', Some(opt_arg)))) => {
                match parse_separator(&opt_arg) {
                    Some(c) => opts.separator = Some(c),
                    None    => return 2,
                }
            },
            Some(Ok(Opt('t', None))) => {
                eprintln!("option requires an argument -- 't'");
                return 2;
            },
            Some(Ok(Opt('u', _))) => opts.unique_flag = true,
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
    let mut paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    let minus = String::from("-");
    if paths.is_empty() {
        paths.push(&minus);
    }
    let mut f: fn(&String, &String, &Options) -> Ordering = simply_compare_strings;
    if !opts.keys.is_empty() {
        f = compare_strings_for_keys;
    } else if opts.order_options.start_b_flag || opts.order_options.end_b_flag || opts.order_options.d_flag || opts.order_options.f_flag || opts.order_options.i_flag {
        f = compare_strings;
    }
    let res = match opts.command_flag {
        CommandFlag::Sort  => sort_files(&paths, &opts, f),
        CommandFlag::Check => {
            match paths.get(0) {
                Some(path) => {
                    if paths.len() == 1 {
                        check_file(path, &opts, f)
                    } else {
                        eprintln!("Too many arguments");
                        None
                    }
                }
                None => {
                    eprintln!("Too few arguments");
                    None
                },
            }
        },
        CommandFlag::Merge => merge_files(&paths, &opts, f),
    };
    match res {
        Some(true)  => 0,
        Some(false) => 1,
        None        => 2,
    }
}
