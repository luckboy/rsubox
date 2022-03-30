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
use std::collections::HashSet;
use std::fs;
use std::os::unix::fs::MetadataExt;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

#[derive(PartialEq)]
enum ReportFlag
{
    None,
    All,
    Summarize,
}

struct Options
{
    report_flag: ReportFlag,
    kilo_flag: bool,
    one_fs_flag: bool,
    do_flag: DoFlag,
}

fn can_sum_file(metadata: &fs::Metadata, is_name: bool, opts: &Options, dev_ino_pairs: &mut HashSet<(u64, u64)>, fs_dev: &mut Option<u64>) -> bool
{
    if opts.one_fs_flag {
        match fs_dev {
            Some(fs_dev) => {
                if metadata.dev() != *fs_dev { return false; }
            },
            None         => {
                if !is_name { *fs_dev = Some(metadata.dev()); }
            },
        }
    }
    if dev_ino_pairs.contains(&(metadata.dev(), metadata.ino())) {
        false
    } else {
        dev_ino_pairs.insert((metadata.dev(), metadata.ino()));
        true
    }
}

fn blocks_to_size(blocks: u64, opts: &Options) -> u64
{ if opts.kilo_flag { (blocks + 1) / 2 } else { blocks } }

fn descend_into_dir(metadata: &fs::Metadata, is_name: bool, opts: &Options, dev_ino_pairs: &mut HashSet<(u64, u64)>, fs_dev: &mut Option<u64>, stack: &mut Vec<u64>) -> bool
{
    if can_sum_file(metadata, is_name, opts, dev_ino_pairs, fs_dev) {
        stack.push(0);
        true
    } else {
        false
    }
}

fn du_file<P: AsRef<Path>>(path: P, metadata: &fs::Metadata, is_name: bool, opts: &Options, dev_ino_pairs: &mut HashSet<(u64, u64)>, fs_dev: &mut Option<u64>, stack: &mut Vec<u64>)
{
    if can_sum_file(metadata, is_name, opts, dev_ino_pairs, fs_dev) {
        let blocks = metadata.blocks();
        if !is_name || opts.report_flag == ReportFlag::All {
            println!("{} {}", blocks_to_size(blocks, opts), path.as_ref().to_string_lossy());
        }
        if !stack.is_empty() {
            let i = stack.len() - 1;
            stack[i] += blocks;
        }
    }
}

fn du_dir<P: AsRef<Path>>(path: P, metadata: &fs::Metadata, is_name: bool, opts: &Options, stack: &mut Vec<u64>)
{
    let blocks = metadata.blocks() + stack.pop().unwrap_or(0);
    if !is_name || opts.report_flag != ReportFlag::Summarize {
        println!("{} {}", blocks_to_size(blocks, opts), path.as_ref().to_string_lossy());
    }
    if !stack.is_empty() {
        let i = stack.len() - 1;
        stack[i] += blocks;
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "aHkLsx");
    let mut opts = Options {
        report_flag: ReportFlag::None,
        kilo_flag: false,
        one_fs_flag: false,
        do_flag: DoFlag::NoDereference,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('a', _))) => opts.report_flag = ReportFlag::All,
            Some(Ok(Opt('H', _))) => opts.do_flag = DoFlag::NonRecursiveDereference,
            Some(Ok(Opt('k', _))) => opts.kilo_flag = true,
            Some(Ok(Opt('L', _))) => opts.do_flag = DoFlag::RecursiveDereference,
            Some(Ok(Opt('s', _))) => opts.report_flag = ReportFlag::Summarize,
            Some(Ok(Opt('x', _))) => opts.one_fs_flag = true,
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
    let mut paths: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    let dot = String::from(".");
    if paths.is_empty() {
        paths.push(&dot);
    }
    let mut dev_ino_pairs: HashSet<(u64, u64)> = HashSet::new();
    for path in &paths {
        let dev_ino_pairs_r = &mut dev_ino_pairs;
        let mut fs_dev: Option<u64> = None;
        let fs_dev_r = &mut fs_dev;
        let mut stack: Vec<u64> = Vec::new();
        let stack_r = &mut stack;
        let is_success = recursively_do(path, opts.do_flag, true, |path, metadata, name, action| {
                match action {
                    DoAction::DirActionBeforeList => (true, descend_into_dir(metadata, name.is_some(), &opts, dev_ino_pairs_r, fs_dev_r, stack_r)),
                    DoAction::FileAction => {
                        du_file(path, metadata, name.is_some(), &opts, dev_ino_pairs_r, fs_dev_r, stack_r);
                        (true, true)
                    },
                    DoAction::DirActionAfterList => {
                        du_dir(path, metadata, name.is_some(), &opts, stack_r);
                        (true, true)
                    },
                }
        });
        if !is_success { status = 1; }
    }
    status
}
