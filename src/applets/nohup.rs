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
use std::fs::*;
use std::io::*;
use std::os::unix::fs::OpenOptionsExt;
use std::os::unix::io::AsRawFd;
use std::os::unix::io::FromRawFd;
use std::os::unix::process::CommandExt;
use std::path;
use std::path::*;
use std::process::*;
use libc;
use crate::utils::*;

pub fn main(args: &[String]) -> i32
{
    match args.get(1) {
        Some(prog) => {
            let mut stdin_file: Option<File> = None;
            let mut stderr_file: Option<File> = None;
            let mut stdout_file: Option<File> = None;
            let mut stderr_file2 = match dup_with_cloexec(2) {
                Ok(fd)   => unsafe { File::from_raw_fd(fd) },
                Err(err) => {
                    eprintln!("{}", err);
                    return 127;
                },
            };
            match isatty(0) {
                Ok(true) => {
                    match File::open("/dev/null") {
                        Ok(file) => stdin_file = Some(file),
                        Err(err) => {
                            eprintln!("/dev/null: {}", err);
                            return 127;
                        },
                    }
                },
                _ => (),
            }
            match isatty(1) {
                Ok(true) => {
                    let mut open_opts = OpenOptions::new();
                    open_opts.write(true);
                    open_opts.create(true);
                    open_opts.append(true);
                    open_opts.mode(0o600);
                    match open_opts.open("nohup.out") {
                        Ok(file) => stdout_file = Some(file),
                        Err(_)   => {
                            let mut path_buf = PathBuf::new();
                            match env::var("HOME") {
                                Ok(home) => path_buf.push(home),
                                Err(_)   => {
                                    let mut s = String::new();
                                    s.push(path::MAIN_SEPARATOR);
                                    path_buf.push(s);
                                },
                            }
                            path_buf.push("nohup.out");
                            match open_opts.open(path_buf.as_path()) {
                                Ok(file) => stdout_file = Some(file),
                                Err(err) => {
                                    eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                                    return 127;
                                },
                            }
                        },
                    }
                },
                _ => (),
            }
            match isatty(2) {
                Ok(true) => {
                    let fd = match &stdout_file {
                        Some(file) => file.as_raw_fd(),
                        None       => 1,
                    };
                    match dup_with_cloexec(fd) {
                        Ok(fd)   => stderr_file = Some(unsafe { File::from_raw_fd(fd) }),
                        Err(err) => {
                            eprintln!("{}", err);
                            return 127;
                        },
                    }
                },
                _ => (),
            }
            unsafe { libc::signal(libc::SIGHUP, libc::SIG_IGN); }
            let prog_args: Vec<OsString> = args.iter().skip(2).map(|a| OsString::from(a)).collect();
            let mut cmd = Command::new(prog);
            match stdin_file {
                Some(file) => { cmd.stdin(file); },
                None       => (),
            }
            match stdout_file {
                Some(file) => { cmd.stdout(file); },
                None       => (),
            }
            match stderr_file {
                Some(file) => { cmd.stderr(file); },
                None       => (),
            }
            cmd.args(prog_args);
            let err = cmd.exec();
            let _res = write!(stderr_file2, "{}: {}\n", prog, err);
            if err.kind() == ErrorKind::NotFound { 127 } else { 126 }
        },
        None => {
            eprintln!("No program");
            125
        },
    }
}
