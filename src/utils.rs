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
use std::char;
use std::io::*;
use std::path::*;
use std::str::*;

pub fn escape(chars: &mut Chars) -> String
{
    match chars.next() {
        Some('a')  => String::from("\x07"),
        Some('b')  => String::from("\x08"),
        Some('c')  => String::new(),
        Some('f')  => String::from("\x0c"),
        Some('n')  => String::from("\n"),
        Some('r')  => String::from("\r"),
        Some('t')  => String::from("\t"),
        Some('v')  => String::from("\x0b"),
        Some('\\') => String::from("\\"),
        Some('0')  => {
            let mut tmp_chars = chars.clone();
            let mut digits = String::from("0");
            for _ in 0..3 {
                match chars.next() {
                    Some(c @ ('0'..='7')) => {
                        digits.push(c);
                        tmp_chars = chars.clone();
                    }
                    Some(_) => *chars = tmp_chars.clone(),
                    None => (),
                }
            }
            match char::from_u32(u32::from_str_radix(digits.as_str(), 8).unwrap()) {
                Some(c) => format!("{}", c),
                None    => format!("{}", char::REPLACEMENT_CHARACTER),
            }
        },
        Some(c)    => format!("\\{}", c),
        None       => String::new(),
    }
}

pub fn copy_stream<R: Read, W: Write>(r: &mut R, w: &mut W, in_path: Option<&Path>, out_path: Option<&Path>) -> bool
{
    let mut buf: Vec<u8> = vec![0; 4096];
    let mut is_success = true;
    loop {
        match r.read(&mut buf) {
            Ok(0) => break,
            Ok(n) => {
                match w.write_all(&buf[0..n]) {
                    Ok(())   => (),
                    Err(err) => {
                        match out_path {
                            Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                            None           => eprintln!("{}", err),
                        }
                        is_success = false;
                        break;
                    },
                }
            },
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                match in_path {
                    Some(in_path) => eprintln!("{}: {}", in_path.to_string_lossy(), err),
                    None          => eprintln!("{}", err),
                }
                is_success = false;
                break;
            }
        }
    }
    is_success
}
