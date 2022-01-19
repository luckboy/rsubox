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
use crate::utils::*;

fn echo(arg: &String)
{
    let mut chars = arg.chars();
    loop {
        match chars.next() {
            Some('\\') => print!("{}", escape(&mut chars)),
            Some(c)    => print!("{}", c),
            None       => break,
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut is_first = true;
    let mut arg_iter = args.iter().skip(1);
    let is_newline = if let Some("-n") = arg_iter.next().map(|a| a.as_str()) {
        false
    } else {
        arg_iter = args.iter().skip(1);
        true
    };
    for arg in arg_iter {
      if !is_first { print!(" "); }
      echo(arg);
      is_first = false;
    }
    if is_newline { println!(""); }
    0
}
