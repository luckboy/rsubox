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
enum ByteOrCharFlag
{
    None,
    Bytes,
    Chars,
}

struct Options
{
    newline_flag: bool,
    word_flag: bool,
    byte_or_char_flag: ByteOrCharFlag,
}

struct Counts
{
    newline_count: u64,
    word_count: u64,
    char_count: u64,
    byte_count: u64,
}

fn print_counts(counts: &Counts, path: Option<&str>, opts: &Options)
{
    let mut is_first = true;
    if opts.newline_flag { 
        print!("{}", counts.newline_count);
        is_first = false;
    }
    if opts.word_flag {
        if !is_first { print!(" "); }
        print!("{}", counts.word_count);
        is_first = false;
    }
    match opts.byte_or_char_flag {
        ByteOrCharFlag::None  => (),
        ByteOrCharFlag::Bytes => { 
             if !is_first { print!(" "); }
            print!("{}", counts.byte_count); is_first = false;
        },
        ByteOrCharFlag::Chars => {
            if !is_first { print!(" "); }
            print!("{}", counts.char_count);
            is_first = false;
        },
    }
    match path {
        Some(path) => {
            if !is_first { print!(" "); }
            print!("{}", path); 
        },
        None       => (),
    }
    println!("");
}

fn wc<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options, total_counts: &mut Counts) -> bool
{
    let mut counts = Counts {
        newline_count: 0,
        word_count: 0,
        char_count: 0,
        byte_count: 0,
    };
    let mut is_first_word_char = true;
    let mut r = CharByteReader::new(BufReader::new(r)); 
    loop {
        let mut c = '\0';
        match r.read_char(&mut c) {
            Ok(0) => break,
            Ok(n) => {
                if c == '\n' { counts.newline_count += 1; }
                if !c.is_whitespace() {
                    if is_first_word_char { counts.word_count += 1; }
                    is_first_word_char = false;
                } else {
                    is_first_word_char = true;
                }
                counts.char_count += 1;
                counts.byte_count += n as u64;
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
    match path {
        Some(path) => print_counts(&counts, Some(path.to_string_lossy().into_owned().as_str()), opts),
        None       => print_counts(&counts, None, opts),
    }
    total_counts.newline_count += counts.newline_count;
    total_counts.word_count += counts.word_count;
    total_counts.char_count += counts.char_count;
    total_counts.byte_count += counts.byte_count;
    true
}

fn wc_file<P: AsRef<Path>>(path: P, opts: &Options, total_counts: &mut Counts) -> bool
{
    match File::open(path.as_ref()) {
        Ok(mut file) => {
            wc(&mut file, Some(path.as_ref()), opts, total_counts)
        },
        Err(err)     => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "clmw");
    let mut opts = Options {
        newline_flag: false,
        word_flag: false,
        byte_or_char_flag: ByteOrCharFlag::None,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('c', _))) => opts.byte_or_char_flag = ByteOrCharFlag::Bytes,
            Some(Ok(Opt('l', _))) => opts.newline_flag = true,
            Some(Ok(Opt('m', _))) => opts.byte_or_char_flag = ByteOrCharFlag::Chars,
            Some(Ok(Opt('w', _))) => opts.word_flag = true,
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
    if opts.newline_flag == false && opts.word_flag == false && opts.byte_or_char_flag == ByteOrCharFlag::None {
        opts = Options {
            newline_flag: true,
            word_flag: true,
            byte_or_char_flag: ByteOrCharFlag::Bytes,
        };
    }
    let mut status = 0;
    let paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    let mut total_counts = Counts {
        newline_count: 0,
        word_count: 0,
        char_count: 0,
        byte_count: 0,
    };
    if !paths.is_empty() {
        for path in &paths {
            if !wc_file(path, &opts, &mut total_counts) { status = 1; }
        }
        if paths.len() > 1 {
            print_counts(&total_counts, Some("total"), &opts);
        }
    } else {
        if !wc(&mut stdin(), None, &opts, &mut total_counts) { status = 1; }
    }
    status
}
