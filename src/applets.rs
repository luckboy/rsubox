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

pub mod basename;
pub mod cat;
pub mod chgrp;
pub mod chmod;
pub mod chown;
pub mod cksum;
pub mod cmp;
pub mod cp;
pub mod cut;
pub mod date;
pub mod dd;
pub mod dirname;
pub mod du;
pub mod echo;
pub mod env;
pub mod expr;
pub mod r#false;
pub mod fold;
pub mod grep;
pub mod head;
pub mod id;
pub mod kill;
pub mod link;
pub mod ln;
pub mod ls;
pub mod mkdir;
pub mod mkfifo;
pub mod mv;
pub mod nice;
pub mod nl;
pub mod paste;
pub mod printf;
pub mod pwd;
pub mod rm;
pub mod rmdir;
pub mod sort;
pub mod tail;
pub mod tee;
pub mod test;
pub mod touch;
pub mod tr;
pub mod r#true;
pub mod uname;
pub mod unlink;
pub mod wc;

type AppletFunction = fn(&[String]) -> i32;

pub fn initialize_applet_funs(applet_funs: &mut HashMap<String, AppletFunction>)
{
    applet_funs.insert(String::from("["), test::main);
    applet_funs.insert(String::from("basename"), basename::main);
    applet_funs.insert(String::from("cat"), cat::main);
    applet_funs.insert(String::from("chgrp"), chgrp::main);
    applet_funs.insert(String::from("chmod"), chmod::main);
    applet_funs.insert(String::from("chown"), chown::main);
    applet_funs.insert(String::from("cksum"), cksum::main);
    applet_funs.insert(String::from("cmp"), cmp::main);
    applet_funs.insert(String::from("cp"), cp::main);
    applet_funs.insert(String::from("cut"), cut::main);
    applet_funs.insert(String::from("date"), date::main);
    applet_funs.insert(String::from("dd"), dd::main);
    applet_funs.insert(String::from("dirname"), dirname::main);
    applet_funs.insert(String::from("du"), du::main);
    applet_funs.insert(String::from("echo"), echo::main);
    applet_funs.insert(String::from("env"), env::main);
    applet_funs.insert(String::from("expr"), expr::main);
    applet_funs.insert(String::from("false"), r#false::main);
    applet_funs.insert(String::from("fold"), fold::main);
    applet_funs.insert(String::from("grep"), grep::main);
    applet_funs.insert(String::from("head"), head::main);
    applet_funs.insert(String::from("id"), id::main);
    applet_funs.insert(String::from("kill"), kill::main);
    applet_funs.insert(String::from("link"), link::main);
    applet_funs.insert(String::from("ln"), ln::main);
    applet_funs.insert(String::from("ls"), ls::main);
    applet_funs.insert(String::from("mkdir"), mkdir::main);
    applet_funs.insert(String::from("mkfifo"), mkfifo::main);
    applet_funs.insert(String::from("mv"), mv::main);
    applet_funs.insert(String::from("nice"), nice::main);
    applet_funs.insert(String::from("nl"), nl::main);
    applet_funs.insert(String::from("paste"), paste::main);
    applet_funs.insert(String::from("printf"), printf::main);
    applet_funs.insert(String::from("pwd"), pwd::main);
    applet_funs.insert(String::from("rm"), rm::main);
    applet_funs.insert(String::from("rmdir"), rmdir::main);
    applet_funs.insert(String::from("sort"), sort::main);
    applet_funs.insert(String::from("tail"), tail::main);
    applet_funs.insert(String::from("tee"), tee::main);
    applet_funs.insert(String::from("test"), test::main);
    applet_funs.insert(String::from("touch"), touch::main);
    applet_funs.insert(String::from("tr"), tr::main);
    applet_funs.insert(String::from("true"), r#true::main);
    applet_funs.insert(String::from("uname"), uname::main);
    applet_funs.insert(String::from("unlink"), unlink::main);
    applet_funs.insert(String::from("wc"), wc::main);
}
