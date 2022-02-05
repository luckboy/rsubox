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
use std::iter::*;
use std::ffi::*;
use std::os::unix::ffi::OsStrExt;
use std::slice::*;
use crate::utils::*;

enum Value
{
    Integer(i64),
    String(String),
}

fn get_string_from_value(value: &Value) -> String
{
    match value {
        Value::Integer(x) => format!("{}", *x),
        Value::String(s)  => s.clone(),
    }
}

fn get_value_from_string(s: &String) -> Value
{
    if !s.starts_with('+') {
        match s.parse::<i64>() {
            Ok(x)  => Value::Integer(x),
            Err(_) => Value::String(s.clone()),
        }
    } else {
        Value::String(s.clone())
    }
}

fn next_arg<'a>(arg_iter: &mut PushbackIter<Skip<Iter<'a, String>>>) -> Option<(&'a str, &'a String)>
{ arg_iter.next().map(|s| (s.as_str(), s)) }

fn parse_and_evaluate7(arg_iter: &mut PushbackIter<Skip<Iter<'_, String>>>) -> Option<Value>
{
    match next_arg(arg_iter) {
        Some(("(", _)) => { 
            let res = parse_and_evaluate1(arg_iter, true)?;
            match next_arg(arg_iter) {
                Some((")", _)) => Some(res),
                Some((_, _))   => {
                    eprintln!("Syntax error");
                    None
                },
                None           => {
                    eprintln!("Unclosed parentheses");
                    None
                },
            }
        },
        Some((_, s)) => Some(get_value_from_string(s)),
        None => {
            eprintln!("No argument");
            None
        },
    }
}

fn parse_and_evaluate6(arg_iter: &mut PushbackIter<Skip<Iter<'_, String>>>, in_paren: bool) -> Option<Value>
{
    let mut res = parse_and_evaluate7(arg_iter)?;
    loop {
        match next_arg(arg_iter) {
            Some((":", _)) => {
                let arg2 = parse_and_evaluate7(arg_iter)?;
                let arg_s1 = get_string_from_value(&res);
                let arg_s2 = get_string_from_value(&arg2);
                match Regex::new(arg_s2, 0) {
                    Ok(regex) => {
                        let mut matches: Vec<RegexMatch> = Vec::new();
                        res = if regex.is_match(&arg_s1, Some((2, &mut matches)), 0) {
                            match matches.get(0) {
                                Some(m) => {
                                    if m.start == 0 {
                                        match matches.get(1) {
                                            Some(m2) => {
                                                let s = OsStr::from_bytes(&arg_s1.as_bytes()[0..m2.end]).to_string_lossy().into_owned();
                                                get_value_from_string(&s)
                                            },
                                            None     => Value::Integer(m.end as i64),
                                        }
                                    } else {
                                        Value::Integer(0)
                                    }
                                },
                                None    => Value::Integer(0),
                            }
                        } else {
                            Value::Integer(0)
                        };
                    },
                    Err(err) => {
                        eprintln!("{}", err);
                        break None
                    },
                }
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, s)) => {
                arg_iter.undo(s);
                break Some(res)
            },
            None => break Some(res),
        }
    }
}

fn parse_and_evaluate5(arg_iter: &mut PushbackIter<Skip<Iter<'_, String>>>, in_paren: bool) -> Option<Value>
{
    let mut res = parse_and_evaluate6(arg_iter, in_paren)?;
    loop {
        match next_arg(arg_iter) {
            Some(("*", _)) => {
                let arg2 = parse_and_evaluate6(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => {
                        match x.checked_mul(*y) {
                            Some(z) => res = Value::Integer(z),
                            None    => { eprintln!("Overflow"); break None },
                        }
                    },
                    (_, _) => { eprintln!("Non-integer argument"); break None },
                }
            },
            Some(("/", _)) => {
                let arg2 = parse_and_evaluate6(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(_), Value::Integer(0)) => { eprintln!("Division by zero"); break None },
                    (Value::Integer(x), Value::Integer(y)) => {
                        match x.checked_div(*y) {
                            Some(z) => res = Value::Integer(z),
                            None    => { eprintln!("Overflow"); break None },
                        }
                    },
                    (_, _) => { eprintln!("Non-integer argument"); break None },
                }
            },
            Some(("%", _)) => {
                let arg2 = parse_and_evaluate6(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(_), Value::Integer(0)) => { eprintln!("Division by zero"); break None },
                    (Value::Integer(x), Value::Integer(y)) => {
                        match x.checked_rem(*y) {
                            Some(z) => res = Value::Integer(z),
                            None    => { eprintln!("Overflow"); break None },
                        }
                    },
                    (_, _) => { eprintln!("Non-integer argument"); break None },
                }
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, s)) => {
                arg_iter.undo(s);
                break Some(res)
            },
            None => break Some(res),
        }
    }
}

fn parse_and_evaluate4(arg_iter: &mut PushbackIter<Skip<Iter<'_, String>>>, in_paren: bool) -> Option<Value>
{
    let mut res = parse_and_evaluate5(arg_iter, in_paren)?;
    loop {
        match next_arg(arg_iter) {
            Some(("+", _)) => {
                let arg2 = parse_and_evaluate5(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => {
                        match x.checked_add(*y) {
                            Some(z) => res = Value::Integer(z),
                            None    => { eprintln!("Overflow"); break None },
                        }
                    },
                    (_, _) => { eprintln!("Non-integer argument"); break None },
                }
            },
            Some(("-", _)) => {
                let arg2 = parse_and_evaluate5(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => {
                        match x.checked_sub(*y) {
                            Some(z) => res = Value::Integer(z),
                            None    => { eprintln!("Overflow"); break None },
                        }
                    },
                    (_, _) => { eprintln!("Non-integer argument"); break None },
                }
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, s)) => {
                arg_iter.undo(s);
                break Some(res)
            },
            None => break Some(res),
        }
    }
}

fn parse_and_evaluate3(arg_iter: &mut PushbackIter<Skip<Iter<'_, String>>>, in_paren: bool) -> Option<Value>
{
    let mut res = parse_and_evaluate4(arg_iter, in_paren)?;
    loop {
        match next_arg(arg_iter) {
            Some(("=", _)) => {
                let arg2 = parse_and_evaluate4(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => res = Value::Integer(if x == y { 1 } else { 0 }),
                    (Value::String(s), Value::String(t)) => res = Value::Integer(if s == t { 1 } else { 0 }),
                    (_, _) => res = Value::Integer(0),
                }
            },
            Some(("!=", _)) => {
                let arg2 = parse_and_evaluate4(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => res = Value::Integer(if x != y { 1 } else { 0 }),
                    (Value::String(s), Value::String(t)) => res = Value::Integer(if s != t { 1 } else { 0 }),
                    (_, _) => res = Value::Integer(0),
                }
            },
            Some(("<", _)) => {
                let arg2 = parse_and_evaluate4(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => res = Value::Integer(if x < y { 1 } else { 0 }),
                    (_, _) => res = Value::Integer(0),
                }
            },
            Some((">=", _)) => {
                let arg2 = parse_and_evaluate4(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => res = Value::Integer(if x >= y { 1 } else { 0 }),
                    (_, _) => res = Value::Integer(0),
                }
            },
            Some((">", _)) => {
                let arg2 = parse_and_evaluate4(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => res = Value::Integer(if x > y { 1 } else { 0 }),
                    (_, _) => res = Value::Integer(0),
                }
            },
            Some(("<=", _)) => {
                let arg2 = parse_and_evaluate4(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(x), Value::Integer(y)) => res = Value::Integer(if x <= y { 1 } else { 0 }),
                    (_, _) => res = Value::Integer(0),
                }
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, s)) => {
                arg_iter.undo(s);
                break Some(res)
            },
            None => break Some(res),
        }
    }
}

fn parse_and_evaluate2(arg_iter: &mut PushbackIter<Skip<Iter<'_, String>>>, in_paren: bool) -> Option<Value>
{
    let mut res = parse_and_evaluate3(arg_iter, in_paren)?;
    loop {
        match next_arg(arg_iter) {
            Some(("&", _)) => {
                let arg2 = parse_and_evaluate3(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(0), _) => res = Value::Integer(0),
                    (Value::String(s), _) if s.is_empty() => res = Value::Integer(0),
                    (_, Value::Integer(0)) => res = Value::Integer(0),
                    (_, Value::String(s)) if s.is_empty() => res = Value::Integer(0),
                    (_, _) => (),
                }
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, s)) => {
                arg_iter.undo(s);
                break Some(res)
            },
            None => break Some(res),
        }
    }
}
fn parse_and_evaluate1(arg_iter: &mut PushbackIter<Skip<Iter<'_, String>>>, in_paren: bool) -> Option<Value>
{
    let mut res = parse_and_evaluate2(arg_iter, in_paren)?;
    loop {
        match next_arg(arg_iter) {
            Some(("|", _)) => {
                let arg2 = parse_and_evaluate2(arg_iter, in_paren)?;
                match (&res, &arg2) {
                    (Value::Integer(0), Value::Integer(0)) => res = Value::Integer(0),
                    (Value::String(s), Value::Integer(0)) if s.is_empty() => res = Value::Integer(0),
                    (Value::Integer(0), Value::String(s)) if s.is_empty() => res = Value::Integer(0),
                    (Value::String(s), Value::String(t)) if s.is_empty() && t.is_empty() => res = Value::Integer(0),
                    (Value::Integer(0), _) => res = arg2,
                    (Value::String(s), _) if s.is_empty() => res = arg2,
                    (_, _) => (),
                }
            },
            Some((")", s)) => {
                if in_paren {
                    arg_iter.undo(s);
                    break Some(res)
                } else {
                    eprintln!("Syntax error");
                    break None
                }
            },
            Some((_, _)) => {
                eprintln!("Syntax error");
                break None
            },
            None => break Some(res),
        }
    }
}

fn parse_and_evaluate(args: &[String]) -> Option<Value>
{
    let mut arg_iter = PushbackIter::new(args.iter().skip(1));
    parse_and_evaluate1(&mut arg_iter, false)
}

pub fn main(args: &[String]) -> i32
{
    match parse_and_evaluate(args) {
        Some(Value::Integer(x)) => {
            println!("{}", x);
            0
        },
        Some(Value::String(s)) => {
            println!("{}", s);
            0
        },
        None => 1,
    }
}
