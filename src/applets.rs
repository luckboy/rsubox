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
pub mod cp;
pub mod dirname;
pub mod echo;
pub mod expr;
pub mod r#false;
pub mod mv;
pub mod rm;
pub mod test;
pub mod r#true;
pub mod wc;

type AppletFunction = fn(&[String]) -> i32;

pub fn initialize_applet_funs(applet_funs: &mut HashMap<String, AppletFunction>)
{
    applet_funs.insert(String::from("["), test::main);
    applet_funs.insert(String::from("basename"), basename::main);
    applet_funs.insert(String::from("cat"), cat::main);
    applet_funs.insert(String::from("cp"), cp::main);
    applet_funs.insert(String::from("dirname"), dirname::main);
    applet_funs.insert(String::from("echo"), echo::main);
    applet_funs.insert(String::from("expr"), expr::main);
    applet_funs.insert(String::from("false"), r#false::main);
    applet_funs.insert(String::from("mv"), mv::main);
    applet_funs.insert(String::from("rm"), rm::main);
    applet_funs.insert(String::from("test"), test::main);
    applet_funs.insert(String::from("true"), r#true::main);
    applet_funs.insert(String::from("wc"), wc::main);
}
