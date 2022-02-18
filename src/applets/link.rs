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

pub fn main(args: &[String]) -> i32
{
    match args.get(1) {
        Some(src_path) => {
            match args.get(2) {
                Some(dst_path) => {
                    if args.len() > 3 {
                        eprintln!("Too many arguments");
                        return 1
                    }
                    match hard_link(src_path, dst_path) {
                        Ok(())   => 0,
                        Err(err) => {
                            if err.kind() == ErrorKind::AlreadyExists {
                                eprintln!("{}: {}", dst_path, err);
                            } else {
                                eprintln!("{}: {}", src_path, err);
                            }
                            1
                        },
                    }
                },
                None => {
                    eprintln!("Too few arguments");
                    1
                },
            }
        },
        None => {
            eprintln!("Too few arguments");
            1
        },
    }
}