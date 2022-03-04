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
use libc;

struct Options
{
    appending_flag: bool,
    ignored_interrupt_flag: bool,
}

fn tee_files(path_bufs: &[PathBuf], opts: &Options) -> bool
{
    let mut files: Vec<File> = Vec::new();
    for path_buf in path_bufs {
        let mut open_opts = OpenOptions::new();
        open_opts.write(true).create(true);
        if opts.appending_flag {
            open_opts.append(true);
        } else {
            open_opts.truncate(true);
        }
        match open_opts.open(path_buf.as_path()) {
            Ok(file) => files.push(file),
            Err(err) => {
                eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                return false
            },
        }
    }
    let mut r = stdin();
    let mut w = stdout();
    let mut buf: Vec<u8> = vec![0; 4096];
    loop {
        match r.read(&mut buf) {
            Ok(0) => break,
            Ok(n) => {
                match w.write_all(&buf[0..n]) {
                    Ok(())   => (),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
                }
                for (file, path_buf) in files.iter_mut().zip(path_bufs.iter()) {
                    match file.write_all(&buf[0..n]) {
                        Ok(())   => (),
                        Err(err) => {
                            eprintln!("{}, {}", path_buf.as_path().to_string_lossy(), err);
                            return false;
                        },
                    }
                }
            },
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                eprintln!("{}", err);
                return false;
            },
        }
    }
    match w.flush() {
        Ok(())   => (),
        Err(err) => {
            eprintln!("{}", err);
            return false;
        },
    }
    for (file, path_buf) in files.iter_mut().zip(path_bufs.iter()) {
        match file.flush() {
            Ok(())   => (),
            Err(err) => {
                eprintln!("{}, {}", path_buf.as_path().to_string_lossy(), err);
                return false;
            },
        }
    }
    true
}

fn set_ignored_interrupt()
{ unsafe { libc::signal(libc::SIGINT, libc::SIG_IGN); } }

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "ai");
    let mut opts = Options {
        appending_flag: false,
        ignored_interrupt_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('a', _))) => opts.appending_flag = true,
            Some(Ok(Opt('i', _))) => opts.ignored_interrupt_flag = true,
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
    if opts.ignored_interrupt_flag {
        set_ignored_interrupt();
    }
    let paths: Vec<PathBuf> = args.iter().skip(opt_parser.index()).map(|a| PathBuf::from(a)).collect();
    if tee_files(&paths, &opts) { 0 } else { 1 }
}
