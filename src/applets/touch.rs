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
use std::fs;
use std::fs::*;
use std::os::unix::fs::MetadataExt;
use std::path::*;
use std::time::SystemTime;
use getopt::Opt;
use crate::utils::*;

struct Options
{
    access_time_flag: bool,
    modification_time_flag: bool,
    no_creation_flag: bool,
    times: Times,
}

fn touch_file<P: AsRef<Path>>(path: P, opts: &Options) -> bool
{
    let mut is_success = true;
    let metadata = match fs::metadata(path.as_ref()) {
        Ok(metadata) => Some(metadata),
        Err(err) if err.kind() == ErrorKind::NotFound => {
            if !opts.no_creation_flag {
                let mut open_opts = OpenOptions::new();
                open_opts.write(true);
                open_opts.create_new(true);
                is_success = match open_opts.open(path.as_ref()) {
                    Ok(_)    => true,
                    Err(err) => {
                        eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                        false
                    },
                };
                if is_success {
                    match fs::metadata(path.as_ref()) {
                        Ok(metadata) => Some(metadata),
                        Err(err)     => {
                            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                            is_success = false;
                            None
                        },
                    }
                } else {
                    None
                }
            } else {
                None
            }
        },
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            is_success = false;
            None
        },
    };
    if is_success {
        match metadata {
            Some(metadata) => {
                let mut times = Times {
                    atime: TimeValue {
                        sec: metadata.atime(),
                        usec: metadata.atime_nsec() / 1000,
                    },
                    mtime: TimeValue {
                        sec: metadata.mtime(),
                        usec: metadata.mtime_nsec() / 1000,
                    },
                };
                if opts.access_time_flag {
                    times.atime = opts.times.atime;
                }
                if opts.modification_time_flag {
                    times.mtime = opts.times.mtime;
                }
                match utimes(path.as_ref(), &times) {
                    Ok(())   => (),
                    Err(err) => {
                        eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                        is_success = false;
                    },
                }
            },
            None           => (),
        }
    }
    is_success
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "acmr:t:");
    let mut opts = Options {
        access_time_flag: false,
        modification_time_flag: false,
        no_creation_flag: false,
        times: Times {
            atime: TimeValue { sec: 0, usec: 0, },
            mtime: TimeValue { sec: 0, usec: 0, },
        },
    };
    match SystemTime::now().duration_since(SystemTime::UNIX_EPOCH) {
        Ok(duration) => {
            let time_value = TimeValue {
                sec: duration.as_secs() as i64,
                usec: duration.subsec_micros() as i64,
            };
            opts.times = Times {
                atime: time_value,
                mtime: time_value,
            };
        }
        Err(_)       => (),
    }
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('a', _))) => opts.access_time_flag = true,
            Some(Ok(Opt('c', _))) => opts.no_creation_flag = true,
            Some(Ok(Opt('m', _))) => opts.modification_time_flag = true,
            Some(Ok(Opt('r', Some(opt_arg)))) => {
                match fs::metadata(&opt_arg) {
                    Ok(metadata) => {
                        opts.times = Times {
                            atime: TimeValue {
                                sec: metadata.atime(),
                                usec: metadata.atime_nsec() / 1000,
                            },
                            mtime: TimeValue {
                                sec: metadata.mtime(),
                                usec: metadata.mtime_nsec() / 1000,
                            },
                        };
                    },
                    Err(err)     => {
                        eprintln!("{}: {}", &opt_arg, err);
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('r', None))) => {
                eprintln!("option requires an argument -- 'r'");
                return 1;
            },
            Some(Ok(Opt('t', Some(opt_arg)))) => {
                match parse_date(opt_arg.as_str(), false) {
                    Some(mut tm) => {
                        match mktime(&mut tm) {
                            Ok(time) => {
                                let time_value = TimeValue {
                                    sec: time,
                                    usec: 0,
                                };
                                opts.times = Times {
                                    atime: time_value,
                                    mtime: time_value,
                                };
                            },
                            Err(err) => {
                                eprintln!("{}", err);
                                return 1;
                            },
                        }
                    },
                    None => {
                        eprintln!("Invalid date");
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('t', None))) => {
                eprintln!("option requires an argument -- 't'");
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
    if !opts.access_time_flag && !opts.modification_time_flag {
        opts.access_time_flag = true;
        opts.modification_time_flag = true;
    }
    let mut status = 0;
    let paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    if !paths.is_empty() {
        for path in &paths {
            if !touch_file(path, &opts) { status = 1; }
        }
    } else {
        eprintln!("Too few arguments");
        status = 1;
    }
    status
}
