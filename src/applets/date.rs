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
use std::env;
use std::str::*;
use std::time::SystemTime;
use getopt::Opt;
use libc;
use crate::utils::*;

struct Options
{
    utc_flag: bool,
    tm: Option<Tm>,
}

fn hour24_to_hour12(hour: i32) -> i32
{
    if hour >= 1 && hour <= 12 {
        hour
    } else if hour == 0 {
        12
    } else {
        hour - 12
    }
}

fn am_or_pm(hour: i32) -> &'static str
{ if hour >= 0 && hour <= 11 { "AM" } else { "PM" } }

fn is_leap(year: i32) -> bool
{ year % 4 == 0  && (year % 100 != 0 || year % 400 == 0) }

// iso_week_days function and week_number function uses algorithms from strftime_l.c file of GNU C
// Library.

fn iso_week_days(yday: i32, wday: i32) -> i32
{ yday - (yday - wday + 4 + (366 / 7 + 2) * 7) % 7 + 3 }

fn week_number(tm: &Tm) -> i32
{
    let mut year = tm.year + 1900;
    let mut days = iso_week_days(tm.yday, tm.wday);
    if days < 0 {
        year -= 1;
        days = iso_week_days(tm.yday + (365 + (if is_leap(year) { 1 } else { 0 })), tm.wday);
    } else {
        let tmp_days = iso_week_days(tm.yday - (365 + (if is_leap(year) { 1 } else { 0 })), tm.wday);
        if tmp_days >= 0 { days = tmp_days; }
    }
    days / 7 + 1
}

fn convert_tm_without_modifier(format_iter: &mut PushbackIter<Chars>, tm: &Tm) -> bool
{
    match format_iter.next() {
        Some('a') => print!("{}", abbreviated_week_day_name(tm.wday).unwrap_or("Unk")),
        Some('A') => print!("{}", week_day_name(tm.wday).unwrap_or("Unknown")),
        Some('b') => print!("{}", abbreviated_month_name(tm.mon).unwrap_or("Unk")),
        Some('B') => print!("{}", month_name(tm.mon).unwrap_or("Unknown")),
        Some('c') => print!("{} {} {:2} {:02}:{:02}:{:02} {}", abbreviated_week_day_name(tm.wday).unwrap_or("Unk"), abbreviated_month_name(tm.mon).unwrap_or("Unk"), tm.mday, tm.hour, tm.min, tm.sec, tm.year + 1900),
        Some('C') => print!("{}", (tm.year + 1900) / 100),
        Some('d') => print!("{:02}", tm.mday),
        Some('D') => print!("{:02}/{:02}/{:02}", tm.mon + 1, tm.mday, tm.year % 100),
        Some('e') => print!("{:2}", tm.mday),
        Some('h') => print!("{}", abbreviated_month_name(tm.mon).unwrap_or("Unk")),
        Some('H') => print!("{:02}", tm.hour),
        Some('I') => print!("{:02}", hour24_to_hour12(tm.hour)),
        Some('j') => print!("{:03}", tm.yday + 1),
        Some('m') => print!("{:02}", tm.mon + 1),
        Some('M') => print!("{:02}", tm.min),
        Some('n') => print!("\n"),
        Some('p') => print!("{}", am_or_pm(tm.hour)),
        Some('r') => print!("{:02}:{:02}:{:02} {}", hour24_to_hour12(tm.hour), tm.min, tm.sec, am_or_pm(tm.hour)),
        Some('S') => print!("{:02}", tm.sec),
        Some('t') => print!("\t"),
        Some('u') => print!("{}", (tm.wday + 6) % 7 + 1),
        Some('U') => print!("{:02}", (tm.yday + 7 - tm.wday) / 7),
        Some('V') => print!("{:02}", week_number(tm)),
        Some('w') => print!("{}", tm.wday),
        Some('W') => print!("{:02}", (tm.yday + 7 - (tm.wday + 6) % 7) / 7),
        Some('x') => print!("{:02}/{:02}/{:02}", tm.mon + 1, tm.mday, tm.year % 100),
        Some('X') => print!("{:02}:{:02}:{:02}", tm.hour, tm.min, tm.sec),
        Some('y') => print!("{:02}", tm.year % 100),
        Some('Y') => print!("{}", tm.year + 1900),
        Some('Z') => {
            match &tm.zone {
                Some(zone) => print!("{}", zone.to_string_lossy()),
                None       => print!("UNKNOWN"),
            }
        },
        Some(_)   => {
            eprintln!("Invalid format character");
            return false;
        },
        None      => {
            eprintln!("No format character");
            return false;
        },
    }
    true
}

fn convert_tm(format_iter: &mut PushbackIter<Chars>, tm: &Tm) -> bool
{
    match format_iter.next() {
        Some('%') => {
            print!("%");
            true
        },
        Some('E' | 'O') => convert_tm_without_modifier(format_iter, tm),
        Some(c) => {
            format_iter.undo(c);
            convert_tm_without_modifier(format_iter, tm)
        },
        None => {
            eprintln!("No format character");
            false
        },
    }
}

fn print_date_for_format(format: &str, tm: &Tm) -> bool
{
    let mut format_iter = PushbackIter::new(format.chars());
    loop {
        match format_iter.next() {
            Some('%')  => if !convert_tm(&mut format_iter, tm) { return false; },
            Some(c)    => print!("{}", c),
            None       => break,
        }
    }
    println!("");
    true
}

fn print_date(tm: &Tm)
{
    let zone_s = match &tm.zone {
        Some(zone) => zone.to_string_lossy().into_owned(),
        None       => String::from("UNKNOWN"),
    };
    println!("{} {} {:2} {:02}:{:02}:{:02} {} {}", abbreviated_week_day_name(tm.wday).unwrap_or("Unk"), abbreviated_month_name(tm.mon).unwrap_or("Unk"), tm.mday, tm.hour, tm.min, tm.sec, zone_s, tm.year + 1900);
}

fn get_tm(opts: &Options) -> Option<Tm>
{
    let time = match &opts.tm {
        Some(tm) => {
            let mut tmp_tm = tm.clone();
            match mktime(&mut tmp_tm) {
                Ok(time) => time,
                Err(err) => {
                    eprintln!("{}", err);
                    return None;
                },
            }
        },
        None     => {
            match SystemTime::now().duration_since(SystemTime::UNIX_EPOCH) {
                Ok(duration) => duration.as_secs() as i64,
                Err(_)       => 0,
            }
        },
    };
    match localtime(time) {
        Ok(tm)   => Some(tm),
        Err(err) => {
            eprintln!("{}", err);
            return None;
        },
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "T:u");
    let mut opts = Options {
        utc_flag: false,
        tm: None,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('T', Some(opt_arg)))) => {
                match parse_date(opt_arg.as_str(), true) {
                    Some(tm) => opts.tm = Some(tm),
                    None     => {
                        eprintln!("Invalid date");
                        return 1;
                    },
                }
            },
            Some(Ok(Opt('T', None))) => {
                eprintln!("option requires an argument -- 'T'");
                return 1;
            },
            Some(Ok(Opt('u', _))) => opts.utc_flag = true,
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
    if opts.utc_flag {
        env::set_var("TZ", "UTC0");
    }
    let mut arg_iter = args.iter().skip(opt_parser.index());
    match arg_iter.next() {
        Some(arg) if arg.starts_with("+") => {
            match arg_iter.next() {
                None => (),
                _    => {
                    eprintln!("Too many arguments");
                    return 1;
                },
            }
            match get_tm(&opts) {
                Some(tm) => if print_date_for_format(&arg[1..], &tm) { 0 } else { 1 },
                None     => 1,
            }
        },
        Some(arg) => {
            match arg_iter.next() {
                None => (),
                _    => {
                    eprintln!("Too many arguments");
                    return 1;
                },
            }
            match parse_date(arg.as_str(), true) {
                Some(mut tm) => {
                    match mktime(&mut tm) {
                        Ok(time) => {
                            let mut status = 0;
                            let time_value = TimeSpec {
                                sec: time,
                                nsec: 0,
                            };
                            match clock_settime(libc::CLOCK_REALTIME, &time_value) {
                                Ok(()) => (),
                                Err(err) => {
                                    eprintln!("{}", err);
                                    status = 1;
                                },
                            }
                            let now = match SystemTime::now().duration_since(SystemTime::UNIX_EPOCH) {
                                Ok(duration) => duration.as_secs() as i64,
                                Err(_)       => 0,
                            };
                            match localtime(now) {
                                Ok(tm)   => print_date(&tm),
                                Err(err) => {
                                    eprintln!("{}", err);
                                    status = 1;
                                },
                            }
                            status
                        },
                        Err(err) => {
                            eprintln!("{}", err);
                            1
                        },
                    }
                },
                None => {
                   eprintln!("Invalid date");
                   1
                },
            }
        },
        None => {
            match get_tm(&opts) {
                Some(tm) => { print_date(&tm); 0 },
                None     => 1,
            }
        },
    }
}
