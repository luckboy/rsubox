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
use std::cmp::max;
use std::cmp::min;
use std::iter::*;
use std::str::*;
use std::slice::*;
use crate::utils::*;

#[derive(Copy, Clone)]
enum SignFlag
{
    None,
    Plus,
    Space,
}

enum ConversionSpecifier
{
    Integer,
    Octal,
    Unsigned,
    LowerHexdecimal,
    UpperHexdecimal,
    Byte,
    Character,
    String,
}

struct ConversionSpecification
{
    minus_flag: bool,
    sign_flag: SignFlag,
    hash_flag: bool,
    zero_flag: bool,
    field_width: Option<isize>,
    precision: Option<isize>,
    specifier: ConversionSpecifier,
}

fn next_integer(arg_iter: &mut Skip<Iter<'_, String>>) -> Option<i64>
{
    match arg_iter.next() {
        Some(s) => {
            match s.parse::<i64>() {
                Ok(x)    => Some(x),
                Err(err) => {
                    eprintln!("Invalid argument: {}", err);
                    None
                },
            }
        },
        None => {
            eprintln!("No argument");
            None
        },
    }
}

fn next_unsigned(arg_iter: &mut Skip<Iter<'_, String>>) -> Option<u64>
{
    match arg_iter.next() {
        Some(s) => {
            match s.parse::<u64>() {
                Ok(x)    => Some(x),
                Err(err) => {
                    eprintln!("Invalid argument: {}", err);
                    None
                },
            }
        },
        None => {
            eprintln!("No argument");
            None
        },
    }
}

fn next_byte(arg_iter: &mut Skip<Iter<'_, String>>) -> Option<String>
{
    match arg_iter.next() {
        Some(s) => {
            let mut chars = PushbackIter::new(s.chars());
            match chars.next() {
                Some('\\') => Some(escape(&mut chars)),
                Some(c)   => {
                    let mut s2 = String::new();
                    s2.push(c);
                    Some(s2)
                }
                None => {
                    let mut s2 = String::new();
                    s2.push('\0');
                    Some(s2)
                }
            }
        },
        None => {
            eprintln!("No argument");
            None
        },
    }
}

fn next_char(arg_iter: &mut Skip<Iter<'_, String>>) -> Option<char>
{
    match arg_iter.next() {
        Some(s) => Some(s.chars().next().unwrap_or('\0')),
        None => {
            eprintln!("No argument");
            None
        },
    }
}

fn next_string(arg_iter: &mut Skip<Iter<'_, String>>) -> Option<String>
{
    match arg_iter.next() {
        Some(s) => Some(s.clone()),
        None => {
            eprintln!("No argument");
            None
        },
    }
}

fn parse_format_number(format_iter: &mut PushbackIter<Chars>, err_name: &str) -> Option<Option<isize>>
{
    let mut s = String::new();
    loop {
        match format_iter.next() {
            Some(c @('0'..='9')) => s.push(c),
            Some(c) => {
                format_iter.undo(c);
                break;
            },
            None => break,
        }
    }
    if !s.is_empty() {
        match s.parse::<isize>() {
            Ok(x)    => Some(Some(x)),
            Err(err) => {
                eprintln!("Invalid {}: {}", err_name, err);
                None
            }
        }
    } else {
        Some(None)
    }
}

fn parse_format(format_iter: &mut PushbackIter<Chars>) -> Option<Option<ConversionSpecification>>
{
    match format_iter.next() {
        Some('%') => Some(None),
        Some(c) => {
            format_iter.undo(c);
            let mut conv_spec = ConversionSpecification {
                minus_flag: false,
                sign_flag: SignFlag::None,
                hash_flag: false,
                zero_flag: false,
                field_width: None,
                precision: None,
                specifier: ConversionSpecifier::Integer,
            };
            loop {
                match format_iter.next() {
                    Some('-') => conv_spec.minus_flag = true,
                    Some('+') => conv_spec.sign_flag = SignFlag::Plus,
                    Some(' ') => conv_spec.sign_flag = SignFlag::Space,
                    Some('#') => conv_spec.hash_flag = true,
                    Some('0') => conv_spec.zero_flag = true,
                    Some(c)   => {
                        format_iter.undo(c);
                        break;
                    },
                    None      => break,
                }
            }
            match parse_format_number(format_iter, "field width") {
                Some(x) => conv_spec.field_width = x,
                None    => return None,
            }
            match format_iter.next() {
                Some('.') => {
                    match parse_format_number(format_iter, "precision") {
                        Some(x) => conv_spec.precision = x,
                        None    => return None,
                    }
                },
                Some(c) => format_iter.undo(c),
                None    => (),
            }
            match format_iter.next() {
                Some('d' | 'i') => conv_spec.specifier = ConversionSpecifier::Integer,
                Some('o')       => conv_spec.specifier = ConversionSpecifier::Octal,
                Some('u')       => conv_spec.specifier = ConversionSpecifier::Unsigned,
                Some('x')       => conv_spec.specifier = ConversionSpecifier::LowerHexdecimal,
                Some('X')       => conv_spec.specifier = ConversionSpecifier::UpperHexdecimal,
                Some('b')       => conv_spec.specifier = ConversionSpecifier::Byte,
                Some('c')       => conv_spec.specifier = ConversionSpecifier::Character,
                Some('s')       => conv_spec.specifier = ConversionSpecifier::String,
                Some(_)         => {
                    eprintln!("Invalid format character");
                    return None;
                },
                None            => {
                    eprintln!("No format character");
                    return None;
                },
            }
            Some(Some(conv_spec))
        },
        None => {
            eprintln!("No format character");
            None
        },
    }
}

fn convert_chars(conv_spec: &ConversionSpecification, arg: &str)
{
    let field_width = conv_spec.field_width.unwrap_or(0);
    let filled_char_count = field_width - (arg.len() as isize);
    if !conv_spec.minus_flag {
        if filled_char_count > 0 {
            for _ in 0..filled_char_count {
                print!(" ");
            }
        }
    }
    print!("{}", arg);
    if conv_spec.minus_flag {
        if filled_char_count > 0 {
            for _ in 0..filled_char_count {
                print!(" ");
            }
        }
    }
}

fn convert_byte(conv_spec: &ConversionSpecification, arg_iter: &mut Skip<Iter<'_, String>>) -> bool
{
    match next_byte(arg_iter) {
        Some(s) => {
            convert_chars(conv_spec, s.as_str());
            true
        },
        None    => false,
    }
}

fn convert_char(conv_spec: &ConversionSpecification, arg_iter: &mut Skip<Iter<'_, String>>) -> bool
{
    match next_char(arg_iter) {
        Some(c) => {
            let mut s = String::new();
            s.push(c);
            convert_chars(conv_spec, s.as_str());
            true
        },
        None    => false,
    }
}

fn convert_string(conv_spec: &ConversionSpecification, arg_iter: &mut Skip<Iter<'_, String>>) -> bool
{
    match next_string(arg_iter) {
        Some(s) => {
            let precision = conv_spec.precision.unwrap_or(isize::MAX); 
            convert_chars(conv_spec, &s[0..min(precision as usize, s.len())]);
            true
        },
        None    => false,
    }
}

fn convert_integer(conv_spec: &ConversionSpecification, arg_iter: &mut Skip<Iter<'_, String>>) -> bool
{
    let (s, sign, prefix) = match conv_spec.specifier {
        ConversionSpecifier::Integer => {
            match next_integer(arg_iter) {
                Some(x) => {
                    let y = match x.checked_abs() {
                        Some(abs_x) => abs_x as u64,
                        None        => (u64::MAX >> 1) + 1,
                    };
                    let sign = x < 0;
                    (format!("{}", y), Some(sign), "")
                },
                None    => return false,
            }
        },
        ConversionSpecifier::Octal => {
            match next_unsigned(arg_iter) {
                Some(x) => (format!("{:o}", x), None, "0"),
                None    => return false,
            }
        },
        ConversionSpecifier::Unsigned => {
            match next_unsigned(arg_iter) {
                Some(x) => (format!("{}", x), None, ""),
                None    => return false,
            }
        },
        ConversionSpecifier::LowerHexdecimal => {
            match next_unsigned(arg_iter) {
                Some(x) => (format!("{:x}", x), None, "0x"),
                None    => return false,
            }
        },
        ConversionSpecifier::UpperHexdecimal => {
            match next_unsigned(arg_iter) {
                Some(x) => (format!("{:X}", x), None, "0X"),
                None    => return false,
            }
        },
        _ => {
            eprintln!("Invalid conversion specifier");
            return false;
        },
    };
    let field_width = conv_spec.field_width.unwrap_or(0);
    let precision = conv_spec.precision.unwrap_or(1);
    let s2 = if precision > 0 {
        s
    } else {
        if s == String::from("0") { String::from("") } else { s }
    };
    let mut filled_char_count = field_width - (s2.len() as isize);
    let mut filled_zero_count = precision - (s2.len() as isize);
    match (sign, conv_spec.sign_flag) {
        (Some(true), _) => filled_char_count -= 1,
        (Some(false), SignFlag::Plus | SignFlag::Space) => filled_char_count -= 1,
        (_, _) => (),
    }
    if conv_spec.hash_flag && !((prefix == "0x" || prefix == "0X") && s2.is_empty()) { 
        filled_char_count -= prefix.len() as isize;
    }
    let filled_space_count = if conv_spec.zero_flag && !conv_spec.minus_flag && conv_spec.precision.is_none() {
        filled_zero_count = max(filled_zero_count, filled_char_count);
        0
    } else {
        filled_char_count - max(filled_zero_count, 0)
    };
    if !conv_spec.minus_flag {
        if filled_space_count > 0 {
            for _ in 0..filled_space_count {
                print!(" ");
            }
        }
    }
    match (sign, conv_spec.sign_flag) {
        (Some(true), _) => print!("-"),
        (Some(false), SignFlag::Plus) => print!("+"),
        (Some(false), SignFlag::Space) => print!(" "),
        (_, _) => (),
    }
    if conv_spec.hash_flag && !((prefix == "0x" || prefix == "0X") && s2.is_empty()) {
        print!("{}", prefix);
    }
    if filled_zero_count > 0 {
        for _ in 0..filled_zero_count {
            print!("0");
        }
    }
    print!("{}", s2);
    if conv_spec.minus_flag {
        if filled_space_count > 0 {
            for _ in 0..filled_space_count {
                print!(" ");
            }
        }
    }
    true
}

fn convert_arg(format_iter: &mut PushbackIter<Chars>, arg_iter: &mut Skip<Iter<'_, String>>) -> bool
{
    match parse_format(format_iter) {
        Some(Some(conv_spec)) => {
            match conv_spec.specifier {
                ConversionSpecifier::Byte => convert_byte(&conv_spec, arg_iter),
                ConversionSpecifier::Character => convert_char(&conv_spec, arg_iter),
                ConversionSpecifier::String => convert_string(&conv_spec, arg_iter),
                _ => convert_integer(&conv_spec, arg_iter),
            }
        },
        Some(None) => {
            print!("%");
            true
        },
        None => false,
    }
}

fn printf(format: &String, arg_iter: &mut Skip<Iter<'_, String>>) -> bool
{
    let mut format_iter = PushbackIter::new(format.chars());
    loop {
        match format_iter.next() {
            Some('%')  => if !convert_arg(&mut format_iter, arg_iter) { return false; },
            Some('\\') => print!("{}", escape_for_printf(&mut format_iter)),
            Some(c)    => print!("{}", c),
            None       => break,
        }
    }
    true
}

pub fn main(args: &[String]) -> i32
{
    let mut arg_iter = args.iter().skip(1);
    match arg_iter.next() {
        Some(format) => {
            if printf(format, &mut arg_iter) { 0 } else { 1 }
        },
        None => {
            eprintln!("No format");
            1
        },
    }
}
