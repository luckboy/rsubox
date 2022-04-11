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

enum NumberingType
{
    AllLines,
    NonEmptyLines,
    NoLines,
    RegexLines(Regex),
}

enum NumberFormat
{
    LeftAlign,
    RightAlign,
    RightAlignWithZeros,
}

struct Options
{
    body_numbering_type: NumberingType,
    header_numbering_type: NumberingType,
    footer_numbering_type: NumberingType,
    delimiter: String,
    increment: u64,
    join_blank_line_count: u64,
    number_format: NumberFormat,
    no_renumber_flag: bool,
    separator: String,
    start_value: u64,
    number_width: usize,
}

enum PageSection
{
    Header,
    Body,
    Footer,
}

struct Data
{
    line_number: u64,
    page_section: PageSection,
    join_blank_line_count: u64,
}

fn get_page_section(line: &str, opts: &Options) -> Option<PageSection>
{
    if line == opts.delimiter.clone() + opts.delimiter.as_str() + opts.delimiter.as_str() {
        Some(PageSection::Header)
    } else if line == opts.delimiter.clone() + opts.delimiter.as_str() {
        Some(PageSection::Body)
    } else if line == opts.delimiter.as_str() {
        Some(PageSection::Footer)
    } else {
        None
    }
}

fn format_line_number(opts: &Options, data: &mut Data, is_number: bool) -> String
{
    if is_number {
        let s = match opts.number_format {
            NumberFormat::LeftAlign           => format!("{:<width$}{}", data.line_number, opts.separator, width = opts.number_width),
            NumberFormat::RightAlign          => format!("{:>width$}{}", data.line_number, opts.separator, width = opts.number_width),
            NumberFormat::RightAlignWithZeros => format!("{:0>width$}{}", data.line_number, opts.separator, width = opts.number_width),
        };
        data.line_number = data.line_number.saturating_add(opts.increment);
        s
    } else {
        let len = opts.separator.chars().fold(0, |x, _| x + 1);
        format!("{:width$}{:width2$}", "", "", width = opts.number_width, width2 = len)
    }
}

fn is_line_number(line: &str, numbering_type: &NumberingType) -> bool
{
    match numbering_type {
        NumberingType::AllLines          => true,
        NumberingType::NonEmptyLines     => !line.is_empty(),
        NumberingType::NoLines           => false,
        NumberingType::RegexLines(regex) => regex.is_match(line, None, 0),
    }
}

fn nl<R: Read>(r: &mut R, path: Option<&Path>, opts: &Options, data: &mut Data) -> bool
{
    let mut r = BufReader::new(r);
    let mut w = BufWriter::new(stdout());
    loop {
        let mut line = String::new();
        match r.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line_without_newline = str_without_newline(line.as_str());
                match get_page_section(line_without_newline, opts) {
                    Some(page_section) => {
                        if !opts.no_renumber_flag {
                            data.line_number = opts.start_value;
                        }
                        data.page_section = page_section;
                        match write!(w, "\n") {
                            Ok(())   => (),
                            Err(err) => {
                                eprintln!("{}", err);
                                return false;
                            },
                        }
                    },
                    None => {
                        let mut is_number = if line_without_newline.is_empty() {
                            data.join_blank_line_count += 1;
                            if data.join_blank_line_count >= opts.join_blank_line_count {
                                data.join_blank_line_count = 0;
                                true
                            } else {
                                false
                            }
                        } else {
                            data.join_blank_line_count = 0;
                            true
                        };
                        if is_number {
                            is_number = match data.page_section {
                                PageSection::Header => is_line_number(line_without_newline, &opts.header_numbering_type),
                                PageSection::Body   => is_line_number(line_without_newline, &opts.body_numbering_type),
                                PageSection::Footer => is_line_number(line_without_newline, &opts.footer_numbering_type),
                            };
                        }
                        let formated_line_number = format_line_number(opts, data, is_number);
                        match write!(w, "{}{}\n", formated_line_number, line_without_newline) {
                            Ok(())   => (),
                            Err(err) => {
                                eprintln!("{}", err);
                                return false;
                            },
                        }
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
        Ok(())   => (),
        Err(err) => {
            eprintln!("{}", err);
            return false;
        },
    }
    true
}

fn nl_file<P: AsRef<Path>>(path: P, opts: &Options, data: &mut Data) -> bool
{
    match File::open(path.as_ref()) {
        Ok(mut file) => nl(&mut file, Some(path.as_ref()), opts, data),
        Err(err)     => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        }
    }
}

fn parse_numbering_type(s: &String) -> Option<NumberingType>
{
    if s == &String::from("a") {
        Some(NumberingType::AllLines)
    } else if s == &String::from("t") {
        Some(NumberingType::NonEmptyLines)
    } else if s == &String::from("n") {
        Some(NumberingType::NoLines)
    } else if s.starts_with("p") {
        match Regex::new(&s[1..], 0) {
            Ok(regex) => Some(NumberingType::RegexLines(regex)),
            Err(err)  => {
                eprintln!("{}", err);
                None
            },
        }
    } else {
        eprintln!("Invalid numbering type");
        None
    }
}

fn parse_delimiter(s: &String) -> String
{
    let len = s.chars().fold(0, |x, _| x + 1);
    if len == 0 {
        String::from("\\:")
    } else if len == 1 {
        s.clone() + ":"
    } else {
        s.clone()
    }
}

fn parse_number_format(s: &String) -> Option<NumberFormat>
{
    if s == &String::from("ln") {
        Some(NumberFormat::LeftAlign)
    } else if s == &String::from("rn") {
        Some(NumberFormat::RightAlign)
    } else if s == &String::from("rz") {
        Some(NumberFormat::RightAlignWithZeros)
    } else {
        eprintln!("Invalid number format");
        None
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "b:d:f:h:i:l:n:ps:v:w:");
    let mut opts = Options {
        body_numbering_type: NumberingType::NonEmptyLines,
        header_numbering_type: NumberingType::NoLines,
        footer_numbering_type: NumberingType::NoLines,
        delimiter: String::from("\\:"),
        increment: 1,
        join_blank_line_count: 1,
        number_format: NumberFormat::RightAlign,
        no_renumber_flag: false,
        separator: String::from("\t"),
        start_value: 1,
        number_width: 6,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('b', Some(opt_arg)))) => {
                match parse_numbering_type(&opt_arg) {
                    Some(number_type) => opts.body_numbering_type = number_type,
                    None              => return 1,
                }
            },
            Some(Ok(Opt('b', None))) => {
                eprintln!("option requires an argument -- 'b'");
                return 1;
            },
            Some(Ok(Opt('d', Some(opt_arg)))) => opts.delimiter = parse_delimiter(&opt_arg),
            Some(Ok(Opt('d', None))) => {
                eprintln!("option requires an argument -- 'd'");
                return 1;
            },
            Some(Ok(Opt('f', Some(opt_arg)))) => {
                match parse_numbering_type(&opt_arg) {
                    Some(number_type) => opts.footer_numbering_type = number_type,
                    None              => return 1,
                }
            },
            Some(Ok(Opt('f', None))) => {
                eprintln!("option requires an argument -- 'f'");
                return 1;
            },
            Some(Ok(Opt('h', Some(opt_arg)))) => {
                match parse_numbering_type(&opt_arg) {
                    Some(number_type) => opts.header_numbering_type = number_type,
                    None              => return 1,
                }
            },
            Some(Ok(Opt('h', None))) => {
                eprintln!("option requires an argument -- 'h'");
                return 1;
            },
            Some(Ok(Opt('i', Some(opt_arg)))) => {
                match opt_arg.parse::<u64>() {
                    Ok(n)    => opts.increment = n,
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('i', None))) => {
                eprintln!("option requires an argument -- 'i'");
                return 1;
            },
            Some(Ok(Opt('l', Some(opt_arg)))) => {
                match opt_arg.parse::<u64>() {
                    Ok(n)    => opts.join_blank_line_count = n,
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('l', None))) => {
                eprintln!("option requires an argument -- 'l'");
                return 1;
            },
            Some(Ok(Opt('n', Some(opt_arg)))) => {
                match parse_number_format(&opt_arg) {
                    Some(number_format) => opts.number_format = number_format,
                    None                => return 1,
                }
            },
            Some(Ok(Opt('n', None))) => {
                eprintln!("option requires an argument -- 'n'");
                return 1;
            },
            Some(Ok(Opt('p', _))) => opts.no_renumber_flag = true,
            Some(Ok(Opt('s', Some(opt_arg)))) => opts.separator = opt_arg.clone(),
            Some(Ok(Opt('s', None))) => {
                eprintln!("option requires an argument -- 's'");
                return 1;
            },
            Some(Ok(Opt('v', Some(opt_arg)))) => {
                match opt_arg.parse::<u64>() {
                    Ok(n)    => opts.start_value = n,
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('v', None))) => {
                eprintln!("option requires an argument -- 'v'");
                return 1;
            },
            Some(Ok(Opt('w', Some(opt_arg)))) => {
                match opt_arg.parse::<usize>() {
                    Ok(n)    => opts.number_width = n,
                    Err(err) => {
                        eprintln!("{}", err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('w', None))) => {
                eprintln!("option requires an argument -- 'w'");
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
    let mut data = Data {
        line_number: opts.start_value,
        page_section: PageSection::Body,
        join_blank_line_count: 0,
    };
    let mut status = 0;
    let paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    if !paths.is_empty() {
        for path in &paths {
            if !nl_file(path, &opts, &mut data) { status = 1; }
        }
    } else {
        if !nl(&mut stdin(), None, &opts, &mut data) { status = 1; }
    }
    status
}
