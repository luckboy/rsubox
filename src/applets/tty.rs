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
use libc;
use crate::utils::*;

pub fn main(_args: &[String]) -> i32
{
    match ttyname(0) {
        Ok(path_buf) => {
            println!("{}", path_buf.as_path().to_string_lossy());
            0
        },
        Err(err) if err.raw_os_error().map(|e| e == libc::ENOTTY).unwrap_or(false) => {
            println!("not a tty");
            1
        },
        Err(err) => {
            eprintln!("{}", err);
            2
        },
    }
}
