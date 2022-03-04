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
    delimiters: Vec<char>,
    serial_flag: bool,
}

struct Stream<R: Read>
{
    path_buf: Option<PathBuf>,
    reader: BufReader<R>,
    has_eof: bool,
}

fn paste_line<R: Read>(stream: &mut Stream<R>, lines: &mut Vec<String>) -> bool
{
    let mut line = String::new();
    if !stream.has_eof {
        match stream.reader.read_line(&mut line) {
            Ok(0) => {
                lines.push(String::new());
                stream.has_eof = true;
            },
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                lines.push(String::from(line_without_newline));
            },
            Err(err) => {
                match &stream.path_buf {
                    Some(path_buf) => eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err),
                    None           => eprintln!("{}", err),
                }
                return false;
            },
        }
    } else {
        lines.push(String::new());
    }
    true
}

fn paste_files(paths: &[&String], opts: &Options) -> bool
{
    let mut streams: Vec<Option<Stream<File>>> = Vec::new();
    let mut stdin_stream = Stream {
        path_buf: None,
        reader: BufReader::new(stdin()),
        has_eof: false,
    };
    let mut w = BufWriter::new(stdout());
    for path in paths.iter() {
        if *path == &String::from("-") {
            streams.push(None);
        } else {
            let path_buf = PathBuf::from(path);
            match File::open(path_buf.as_path()) {
                Ok(file) => streams.push(Some(Stream {
                        path_buf: Some(path_buf.clone()),
                        reader: BufReader::new(file),
                        has_eof: false,
                })),
                Err(err)     => {
                    eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                    return false
                }
            }
        }
    }
    loop {
        let mut lines: Vec<String> = Vec::new();
        for stream in &mut streams {
            let is_success = match stream {
                Some(stream) => paste_line(stream, &mut lines),
                None         => paste_line(&mut stdin_stream, &mut lines),
            };
            if !is_success { return false; }
        }
        let is_eof = streams.iter().all(|stream| {
                match stream {
                    Some(stream) => stream.has_eof,
                    None         => stdin_stream.has_eof,
                }
        });
        if is_eof { break; }
        let mut i = 0;
        let mut is_first = true;
        for line in &lines {
            if !is_first {
                if opts.delimiters[i] != '\0' {
                    match write!(w, "{}", opts.delimiters[i]) {
                        Ok(()) => (),
                        Err(err) => {
                            eprintln!("{}", err);
                            return false;
                        },
                    }
                }
                i += 1;
                if i >= opts.delimiters.len() { i = 0; }
            }
            match write!(w, "{}", line) {
                Ok(())   => (),
                Err(err) => {
                    eprintln!("{}", err);
                    return false;
                },
            }
            is_first = false;
        }
        match write!(w, "\n") {
            Ok(()) => (),
            Err(err) => {
                eprintln!("{}", err);
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

fn paste_serial<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options) -> bool
{
    let mut r = BufReader::new(r);
    let mut w = BufWriter::new(stdout());
    let mut i = 0;
    let mut is_first = true;
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                if !is_first {
                    if opts.delimiters[i] != '\0' {
                        match write!(w, "{}", opts.delimiters[i]) {
                            Ok(()) => (),
                            Err(err) => {
                                eprintln!("{}", err);
                                return false;
                            },
                        }
                    }
                    i += 1;
                    if i >= opts.delimiters.len() { i = 0; }
                }
                let line_without_newline = str_without_newline(line.as_str());
                match write!(w, "{}", line_without_newline) {
                    Ok(())   => (),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
                }
                is_first = false;
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
    match write!(w, "\n") {
        Ok(()) => (),
        Err(err) => {
            eprintln!("{}", err);
            return false;
        },
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

fn paste_serial_file(path: &String, opts: &Options) -> bool
{
    if path == &String::from("-") {
        paste_serial(&mut stdin(), None, opts)
    } else {
        let path_buf = PathBuf::from(path);
        match File::open(path_buf.as_path()) {
            Ok(mut file) => paste_serial(&mut file, Some(path_buf.as_path()), opts),
            Err(err)     => {
                eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                false
            }
        }
    }
}

fn parse_delimiters(s: &String, delimiters: &mut Vec<char>)
{
    let mut iter = s.chars();
    delimiters.clear();
    loop {
        match iter.next() {
            Some('\\') => {
                match iter.next() {
                    Some('n')  => delimiters.push('\n'),
                    Some('t')  => delimiters.push('\t'),
                    Some('\\') => delimiters.push('\\'),
                    Some('0')  => delimiters.push('\0'),
                    Some(c)    => delimiters.push(c),
                    None       => delimiters.push('\0'),
                }
            },
            Some(c) => delimiters.push(c),
            None    => break,
        }
    }
    if delimiters.is_empty() {
        delimiters.push('\0');
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "d:s");
    let mut opts = Options {
        delimiters: vec!['\t'],
        serial_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('d', Some(opt_arg)))) => parse_delimiters(&opt_arg, &mut opts.delimiters),
            Some(Ok(Opt('d', None))) => {
                eprintln!("option requires an argument -- 'd'");
                return 1;
            },
            Some(Ok(Opt('s', _))) => opts.serial_flag = true,
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
        if !opts.serial_flag {
            if !paste_files(&paths, &opts) { status = 1; }
        } else {
            for path in &paths {
                if !paste_serial_file(path, &opts) { status = 1; }
            }
        }
    } else {
        eprintln!("Too few arguments");
        status = 1;
    }
    status
}
