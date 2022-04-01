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
use crc::CRC_32_CKSUM;
use crc::Crc;
use getopt::Opt;

fn cksum<R: Read>(r: &mut R, path: Option<&Path>, crc: &Crc<u32>) -> bool
{
    let mut buf: Vec<u8> = vec![0; 4096];
    let mut digest = crc.digest();
    let mut count: u64 = 0;
    loop {
        match r.read(&mut buf) {
            Ok(0) => break,
            Ok(n) => {
                digest.update(&buf[0..n]);
                count += n as u64;
            },
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                match path {
                    Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                    None       => eprintln!("{}", err),
                }
                return false;
            },
        }
    }
    print!("{} {}", digest.finalize(), count);
    match path {
        Some(path) => println!(" {}", path.to_string_lossy()),
        None       => println!(""),
    }
    true
}

fn cksum_file<P: AsRef<Path>>(path: &P, crc: &Crc<u32>) -> bool
{
    match File::open(path.as_ref()) {
        Ok(mut file) => cksum(&mut file, Some(path.as_ref()), crc),
        Err(err)     => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        }
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "");
    loop {
        match opt_parser.next() {
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
    let crc = Crc::<u32>::new(&CRC_32_CKSUM);
    let mut status = 0;
    let paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    if !paths.is_empty() {
        for path in &paths {
            if !cksum_file(path, &crc) { status = 1; }
        }
    } else {
        if !cksum(&mut stdin(), None, &crc) { status = 1; }
    }
    status
}
