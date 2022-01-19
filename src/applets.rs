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

pub mod cat;
pub mod echo;

type AppletFunction = fn(&[String]) -> i32;

pub fn init_applet_funs(applet_funs: &mut HashMap<String, AppletFunction>)
{
    applet_funs.insert(String::from("cat"), cat::main);
    applet_funs.insert(String::from("echo"), echo::main);
}
