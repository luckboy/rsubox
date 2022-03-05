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

fn cat<R: Read>(r: &mut R, path: Option<&Path>) -> bool
{ copy_stream(r, &mut stdout(), path, None) }

fn cat_file(path: &String) -> bool
{
    if path == &String::from("-") {
        cat(&mut stdin(), None)
    } else {
        match File::open(path) {
            Ok(mut file) => cat(&mut file, Some(path.as_ref())),
            Err(err)     => {
                eprintln!("{}: {}", path, err);
                false
            }
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "u");
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('u', _))) => (),
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
        for path in &paths {
            if !cat_file(path) { status = 1; }
        }
    } else {
        if !cat(&mut stdin(), None) { status = 1; }
    }
    status
}
