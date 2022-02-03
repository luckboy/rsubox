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
use std::collections::HashMap;
use std::env;
use std::ffi::*;
use std::path::*;
use std::process::*;

mod applets;
#[allow(dead_code)]
mod utils;

use applets::initialize_applet_funs;

fn get_applet_name_and_args() -> Option<(String, Vec<String>)>
{
    let args: Vec<String> = env::args().collect();
    let prog_path = args.get(0)?;
    let prog_name = Path::new(&prog_path).file_name()?;
    let tuple = if prog_name == OsStr::new("rsubox") {
        let applet_name = args.get(1)?;
        (applet_name.clone(), args.into_iter().skip(1).collect())
    } else {
        (String::from(prog_name.to_str().unwrap()), args)
    };
    Some(tuple)
}

fn main()
{
    let mut applet_funs = HashMap::new();
    initialize_applet_funs(&mut applet_funs);
    match get_applet_name_and_args() {
        Some((applet_name, args)) => {
            if applet_name == String::from("applets") {
                let mut applet_names: Vec<&String> = applet_funs.iter().map(|a| a.0).collect();
                applet_names.sort();
                let mut is_first = true;
                for applet_name in &applet_names {
                    if !is_first { print!(" "); } 
                    print!("{}", applet_name);
                    is_first = false;
                }
                println!("");
                exit(0);
            }
            match applet_funs.get(&applet_name) {
                Some(applet_fun) => exit(applet_fun(&args)),
                None             => {
                    eprintln!("Unknown applet");
                    exit(1);
                },
            }
        },
        None => {
            eprintln!("No applet name");
            exit(1);
        },
    }
}
