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
use std::iter::Iterator;
use std::path;
use std::path::*;
use std::str::*;

pub trait PushbackIterator: Iterator
{
    fn undo(&mut self, item: Self::Item);
}

pub struct PushbackIter<I: Iterator>
{
    iter: I,
    pushed_items: Vec<I::Item>,
}

impl<I: Iterator> PushbackIter<I>
{
    pub fn new(iter: I) -> PushbackIter<I>
    { PushbackIter { iter, pushed_items: Vec::new(), } }
}

impl<I: Iterator> Iterator for PushbackIter<I>
{
    type Item = I::Item;
    
    fn next(&mut self) -> Option<I::Item>
    {
        match self.pushed_items.pop() {
            Some(item) => Some(item),
            None       => self.iter.next(),
        }
    }
}

impl<I: Iterator> PushbackIterator for PushbackIter<I>
{
    fn undo(&mut self, item: Self::Item)
    { self.pushed_items.push(item); }
}

pub trait CharByteRead: BufRead
{
    fn read_char(&mut self, c: &mut char) -> Result<usize>
    {
        let mut char_buf: Vec<u8> = Vec::new();
        for i in 0..6 {
            let mut buf: [u8; 1] = [0; 1];
            let mut is_eof = false;
            loop {
                match self.read(&mut buf) {
                    Ok(0) => {
                        is_eof = true;
                        break;
                    },
                    Ok(_) => break,
                    Err(err) if err.kind() == ErrorKind::Interrupted => (),
                    Err(err) => return Err(err),
                }
            }
            if !is_eof {
                char_buf.push(buf[0]);
                match String::from_utf8(char_buf.clone()) {
                    Ok(string) => {
                        *c = string.chars().next().unwrap();
                        return Ok(i + 1);
                    }
                    Err(_)     => ()
                }
            } else {
                if i == 0 {
                    return Ok(0);
                } else {
                    return Err(Error::new(ErrorKind::InvalidData, "stream did not contain valid UTF-8"));
                }
            }
        }
        Err(Error::new(ErrorKind::InvalidData, "stream did not contain valid UTF-8"))
    }
}

pub struct CharByteReader<R: BufRead>
{
    reader: R,
}

impl<R: BufRead> CharByteReader<R>
{
    pub fn new(reader: R) -> CharByteReader<R>
    { CharByteReader { reader, } }
}

impl<R: BufRead> Read for CharByteReader<R>
{
    fn read(&mut self, buf: &mut [u8]) -> Result<usize>
    { self.reader.read(buf) }
}

impl<R: BufRead> BufRead for CharByteReader<R>
{
    fn fill_buf(&mut self) -> Result<&[u8]>
    { self.reader.fill_buf() }
    
    fn consume(&mut self, amt: usize)
    { self.reader.consume(amt); }
}

impl<R: BufRead> CharByteRead for CharByteReader<R>
{}

pub fn escape(chars: &mut PushbackIter<Chars>) -> String
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
            let mut digits = String::from("0");
            for _ in 0..3 {
                match chars.next() {
                    Some(c @ ('0'..='7')) => {
                        digits.push(c);
                    }
                    Some(c) => chars.undo(c),
                    None => (),
                }
            }
            match char::from_u32(u32::from_str_radix(digits.as_str(), 8).unwrap()) {
                Some(c) => format!("{}", c),
                None    => format!("{}", char::REPLACEMENT_CHARACTER),
            }
        },
        Some(c)    => format!("\\{}", c),
        None       => String::from("\\"),
    }
}

pub fn dir_name_and_base_name(path: &str, suffix: Option<&str>) -> (String, String)
{
    let (dir_name, base_name) = match path.trim_end_matches(path::MAIN_SEPARATOR).rsplit_once(path::MAIN_SEPARATOR) {
        Some((tmp_dir_name, tmp_base_name)) => {
            let mut dir_name = String::from(tmp_dir_name.trim_end_matches(path::MAIN_SEPARATOR));
            if dir_name.is_empty() && path.starts_with(path::MAIN_SEPARATOR) {
                dir_name = String::new();
                dir_name.push(path::MAIN_SEPARATOR);
            }
            (dir_name, String::from(tmp_base_name)) 
        },
        None => (String::from("."), String::from(path)),
    };
    let base_name = match suffix {
        Some(suffix) if base_name.ends_with(suffix) => String::from(&base_name[0..(base_name.len() - suffix.len())]),
        Some(_) | None => base_name,
    };
    (dir_name, base_name)
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
