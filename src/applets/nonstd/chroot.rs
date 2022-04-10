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
use std::ffi::*;
use std::io::*;
use std::os::unix::fs::chroot;
use std::os::unix::process::CommandExt;
use std::path::*;
use std::process::*;

pub fn main(args: &[String]) -> i32
{
    let root_path_buf = match args.get(1) {
        Some(path) => PathBuf::from(path),
        None       => {
            eprintln!("Too few arguments");
            return 125;
        },
    };
    let (prog, prog_args) = match args.get(2) {
        Some(prog) => {
            (OsString::from(prog), args.iter().skip(3).map(|a| OsString::from(a)).collect::<Vec<OsString>>())
        },
        None       => {
            let shell = match env::var("SHELL") {
                Ok(value) => value,
                Err(_)    => String::from("/bin/sh"),
            };
            (OsString::from(shell), vec![OsString::from("-i")])
        },
    };
    match chroot(root_path_buf.as_path()) {
        Ok(())   => (),
        Err(err) => {
            eprintln!("{}: {}", root_path_buf.as_path().to_string_lossy(), err);
            return 125;
        },
    }
    match env::set_current_dir("/") {
        Ok(())   => (),
        Err(err) => {
            eprintln!("/: {}", err);
            return 125;
        },
    }
    let mut cmd = Command::new(prog.as_os_str());
    cmd.args(prog_args);
    let err = cmd.exec();
    eprintln!("{}: {}", prog.as_os_str().to_string_lossy(), err);
    if err.kind() == ErrorKind::NotFound { 127 } else { 126 }
}
