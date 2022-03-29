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
use libc;
use crate::utils::*;

pub fn initialize_signals(sigs: &mut HashMap<String, i32>)
{
    sigs.insert(String::from("ABRT"), libc::SIGABRT);
    sigs.insert(String::from("ALRM"), libc::SIGALRM);
    sigs.insert(String::from("BUS"), libc::SIGBUS);
    sigs.insert(String::from("CHLD"), libc::SIGCHLD);
    sigs.insert(String::from("CONT"), libc::SIGCONT);
    sigs.insert(String::from("FPE"), libc::SIGFPE);
    sigs.insert(String::from("HUP"), libc::SIGHUP);
    sigs.insert(String::from("ILL"), libc::SIGILL);
    sigs.insert(String::from("INT"), libc::SIGINT);
    sigs.insert(String::from("KILL"), libc::SIGKILL);
    sigs.insert(String::from("PIPE"), libc::SIGPIPE);
    sigs.insert(String::from("QUIT"), libc::SIGQUIT);
    sigs.insert(String::from("SEGV"), libc::SIGSEGV);
    sigs.insert(String::from("STOP"), libc::SIGSTOP);
    sigs.insert(String::from("TERM"), libc::SIGTERM);
    sigs.insert(String::from("TSTP"), libc::SIGTSTP);
    sigs.insert(String::from("TTIN"), libc::SIGTTIN);
    sigs.insert(String::from("TTOU"), libc::SIGTTOU);
    sigs.insert(String::from("USR1"), libc::SIGUSR1);
    sigs.insert(String::from("USR2"), libc::SIGUSR2);
    //sigs.insert(String::from("POLL"), libc::SIGPOLL); // SIGPOLL doesn't appear in FreeBSD.
    sigs.insert(String::from("PROF"), libc::SIGPROF);
    sigs.insert(String::from("SYS"), libc::SIGSYS);
    sigs.insert(String::from("TRAP"), libc::SIGTRAP);
    sigs.insert(String::from("URG"), libc::SIGURG);
    sigs.insert(String::from("VTALRM"), libc::SIGVTALRM);
    sigs.insert(String::from("XCPU"), libc::SIGXCPU);
    sigs.insert(String::from("XFSZ"), libc::SIGXFSZ);
}

fn print_signals(sigs: &HashMap<String, i32>)
{
    let mut sig_pairs: Vec<(&String, &i32)> = sigs.iter().collect();
    sig_pairs.sort_by(|p1, p2| p1.1.cmp(p2.1));
    for (sig_name, sig) in sig_pairs {
        println!("{:2}) {}", sig, sig_name);
    }
}

fn get_signal(sigs: &HashMap<String, i32>, sig_name: &String) -> Option<i32>
{
    match sigs.get(sig_name) {
        Some(sig) => Some(*sig),
        None      => {
            eprintln!("Invalid signal");
            None
        },
    }
}

fn kill_process(proc: &String, sig: i32) -> bool
{
    match proc.parse::<i32>() {
        Ok(pid) => {
            match kill(pid, sig) {
                Ok(())   => true,
                Err(err) => {
                    eprintln!("{}: {}", proc, err);
                    false
                },
            }
        },
        Err(err) => {
            eprintln!("{}: {}", proc, err);
            false
        },
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut sigs: HashMap<String, i32> = HashMap::new();
    initialize_signals(&mut sigs);
    let mut arg_iter = PushbackIter::new(args.iter().skip(1));
    let mut sig = libc::SIGTERM;
    match arg_iter.next() {
        Some(arg) if arg == &String::from("-l") => {
            print_signals(&sigs);
            return 0;
        },
        Some(arg) if arg.starts_with("-s") => {
            let sig_name = if arg.len() > 2 {
                String::from(&arg[2..])
            } else {
                match arg_iter.next() {
                    Some(arg2) => arg2.clone(),
                    None       => {
                        eprintln!("No option argument");
                        return 1;
                    },
                }
            };
            match get_signal(&sigs, &sig_name) {
                Some(sig2) => sig = sig2,
                None       => return 1,
            }
        },
        Some(arg) if arg == &String::from("--") => (),
        Some(arg) if arg.starts_with("-") => {
            match (&arg[1..]).parse::<i32>() {
                Ok(sig2) => sig = sig2,
                Err(_)   => {
                    let sig_name = String::from(&arg[1..]);
                    match get_signal(&sigs, &sig_name) {
                        Some(sig2) => sig = sig2,
                        None       => return 1,
                    }
                },
            }
        },
        Some(arg) => {
            arg_iter.undo(arg);
        },
        None => (),
    }
    let mut status = 0;
    let procs: Vec<&String> = arg_iter.collect();
    if !procs.is_empty() {
        for proc in &procs {
            if !kill_process(proc, sig) { status = 1; }
        }
    } else {
        eprintln!("Too few arguments");
        status = 1;
    }
    status
}
