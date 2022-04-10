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
use std::path::*;
use getopt::Opt;
use libc;
use crate::utils::*;

struct Options
{
    mode: Option<u32>,
}

#[derive(Copy, Clone, PartialEq)]
enum FileType
{
    BlockDevice,
    CharDevice,
    Fifo,
}

fn mknod_file<P: AsRef<Path>>(path: P, file_type: FileType, major: Option<u32>, minor: Option<u32>, opts: &Options) -> bool
{
    if file_type == FileType::BlockDevice || file_type == FileType::CharDevice {
        if major.is_none() || minor.is_none() {
            eprintln!("No major and/or no minor");
            return false;
        }
    }
    let mut mode = match file_type {
        FileType::BlockDevice => libc::S_IFBLK,
        FileType::CharDevice  => libc::S_IFCHR,
        FileType::Fifo        => libc::S_IFIFO,
    };
    mode |= 0o666;
    let dev = makedev(major.unwrap_or(0), minor.unwrap_or(0));
    let mut is_success = match mknod(path.as_ref(), mode, dev) {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    };
    if is_success {
        is_success = match opts.mode {
            Some(mode) => set_mode(path.as_ref(), mode),
            None       => true,
        };
    }
    is_success
}

fn parse_file_type(s: &String) -> Option<FileType>
{
    if s == &String::from("b") {
        Some(FileType::BlockDevice)
    } else if s == &String::from("c") || s == &String::from("u") {
        Some(FileType::CharDevice)
    } else if s == &String::from("p") {
        Some(FileType::Fifo)
    } else {
        eprintln!("Invalid file type");
        None
    }
}

fn parse_number(s: &String) -> Option<u32>
{
    if s.starts_with("0x") || s.starts_with("0X") {
        match u32::from_str_radix(&s[2..], 16) {
            Ok(n)    => Some(n),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    } else if s.starts_with("0") {
        match u32::from_str_radix(s.as_str(), 8) {
            Ok(n)    => Some(n),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    } else {
        match s.parse::<u32>() {
            Ok(n)    => Some(n),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "m:");
    let mut opts = Options {
        mode: None,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('m', Some(opt_arg)))) => {
                match Mode::parse(opt_arg.as_str()) {
                    Some(mode) => {
                        let mask = umask(0);
                        umask(mask);
                        opts.mode = Some(mode.change_mode(0o666 & !mask, true));
                    },
                    None       => {
                        eprintln!("Invalid mode");
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('m', None))) => {
                eprintln!("option requires an argument -- 'm'");
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
    let args: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    match args.get(0) {
        Some(path) => {
            let file_type = match args.get(1) {
                Some(arg) => {
                    match parse_file_type(arg) {
                        Some(file_type) => file_type,
                        None            => return 1,
                    }
                },
                None => {
                    eprintln!("Too few arguments");
                    return 1;
                },
            };
            let major = match args.get(2) {
                Some(arg) => {
                    match parse_number(arg) {
                        Some(n) => Some(n),
                        None    => return 1,
                    }
                },
                None => None,
            };
            let minor = match args.get(3) {
                Some(arg) => {
                    match parse_number(arg) {
                        Some(n) => Some(n),
                        None    => return 1,
                    }
                },
                None => None,
            };
            if args.len() > 4 {
                eprintln!("Too many arguments");
                return 1;
            }
            if mknod_file(path, file_type, major, minor, &opts) { 0 } else { 1 }
        },
        None => {
            eprintln!("Too few arguments");
            1
        },
    }
}
