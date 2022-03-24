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
use std::io::*;
use std::cmp::min;
use std::str::*;
use getopt::Opt;
use crate::utils::*;

#[derive(Copy, Clone, PartialEq)]
enum CharClass
{
    Alnum,
    Alpha,
    Blank,
    Cntrl,
    Digit,
    Graph,
    Lower,
    Print,
    Punct,
    Space,
    Upper,
    Xdigit,
}

#[derive(Copy, Clone)]
enum Element
{
    CharClass(CharClass),
    RepetitionToUnknown(char),
    Char(char),
}

struct KeySet
{
    is_complement: bool,
    char_class_pairs: Vec<(CharClass, usize)>,
    indices: HashMap<char, usize>,
}

struct Options
{
    complement_flag: bool,
    deleting_flag: bool,
    squeezing_flag: bool,
}

enum Command
{
    Replace(KeySet, Vec<Element>),
    ReplaceAndSqueeze(KeySet, Vec<Element>, KeySet),
    Squeeze(KeySet),
    Delete(KeySet),
    DeleteAndSqueeze(KeySet, KeySet),
}

fn is_char_class(c: char, class: CharClass) -> bool
{
    match class {
        CharClass::Alnum  => c.is_alphanumeric(),
        CharClass::Alpha  => c.is_alphabetic(),
        CharClass::Blank  => c == ' ' || c == '\t',
        CharClass::Cntrl  => c.is_control(),
        CharClass::Digit  => c.is_numeric(),
        CharClass::Graph  => !c.is_control() && !c.is_whitespace(),
        CharClass::Lower  => c.is_lowercase(),
        CharClass::Print  => !c.is_control(),
        CharClass::Punct  => !c.is_alphanumeric() && !c.is_control()  && !c.is_whitespace(),
        CharClass::Space  => c.is_whitespace(),
        CharClass::Upper  => c.is_uppercase(),
        CharClass::Xdigit => c.is_digit(16),
    }
}

fn set_to_key_set(set: &[Element]) -> KeySet
{
    let mut key_set = KeySet {
        is_complement: false,
        char_class_pairs: Vec::new(),
        indices: HashMap::new(),
    };
    let mut i = 0;
    for elem in set.iter() {
        match elem {
            Element::CharClass(class)       => key_set.char_class_pairs.push((*class, i)),
            Element::RepetitionToUnknown(c) => { key_set.indices.insert(*c, i); () },
            Element::Char(c)                => { key_set.indices.insert(*c, i); () },
        }
        i += 1;
    }
    key_set
}

fn find_char(key_set: &KeySet, c: char) -> Option<(usize, Option<CharClass>)>
{
    let mut res: Option<(usize, Option<CharClass>)> = None; 
    for (class, i) in &key_set.char_class_pairs {
        if is_char_class(c, *class) {
            res = Some((*i, Some(*class)));
        }
    }
    if res.is_none() {
        res = match key_set.indices.get(&c) {
            Some(i) => Some((*i, None)),
            None    => None,
        };
    }
    if !key_set.is_complement {
        res
    } else {
        match res {
            Some(_) => None,
            None    => Some((0, None)),
        }
    }
}

fn contain_char(key_set: &KeySet, c: char) -> bool
{ find_char(key_set, c).is_some() }

fn replace_char(set: &[Element], c: char, i: usize, class: Option<CharClass>) -> String
{
    match set.get(i) {
        Some(elem) => {
            match (class, elem) {
                (Some(class1), Element::CharClass(class2)) if class1 == *class2 => format!("{}", c),
                (Some(CharClass::Lower), Element::CharClass(CharClass::Upper)) => format!("{}", c.to_uppercase()),
                (Some(CharClass::Upper), Element::CharClass(CharClass::Lower)) => format!("{}", c.to_lowercase()),
                (_, Element::RepetitionToUnknown(c2)) => format!("{}", c2),
                (_, Element::Char(c2)) => format!("{}", c2),
                (_, _) => format!("{}", c),
            }
        },
        None => format!("{}", c),
    }
}

fn translate_char(cmd: &Command, c: char, prev_c: &mut Option<char>) -> String
{
    match cmd {
        Command::Replace(key_set, set) => {
            match find_char(key_set, c) {
                Some((i, class)) => replace_char(&set, c, i, class),
                None => format!("{}", c),
            }
        },
        Command::ReplaceAndSqueeze(key_set1, set, key_set2) => {
            let s = match find_char(key_set1, c) {
                Some((i, class)) => replace_char(&set, c, i, class),
                None             => format!("{}", c),
            };
            let mut chars = s.chars();
            match chars.next() {
                Some(c2) => {
                    match chars.next() {
                        Some(_) => {
                            *prev_c = None;
                            s
                        },
                        None => {
                            let s = if contain_char(key_set2, c2) {
                                match prev_c {
                                    Some(prev_c) if *prev_c == c2 => String::new(),
                                    _ => s,
                                }
                            } else {
                                s
                            };
                            *prev_c = Some(c2);
                            s
                        },
                    }
                },
                None => {
                    *prev_c = None;
                    s
                },
            }
        },
        Command::Squeeze(key_set) => {
            let s = if contain_char(key_set, c) {
                match prev_c {
                    Some(prev_c) if *prev_c == c => String::new(),
                    _ => format!("{}", c),
                }
            } else {
                format!("{}", c)
            };
            *prev_c = Some(c);
            s
        },
        Command::Delete(key_set) => {
            if contain_char(key_set, c) {
                String::new()
            } else {
                format!("{}", c)
            }
        },
        Command::DeleteAndSqueeze(key_set1, key_set2) => {
            if contain_char(key_set1, c) {
                String::new()
            } else {
                let s = if contain_char(key_set2, c) {
                    match prev_c {
                        Some(prev_c) if *prev_c == c => String::new(),
                        _ => format!("{}", c),
                    }
                } else {
                    format!("{}", c)
                };
                *prev_c = Some(c);
                s
            }
        },
    }
}

fn tr(cmd: &Command) -> bool
{
    let mut r = CharByteReader::new(BufReader::new(stdin()));
    let mut w = BufWriter::new(stdout());
    let mut prev_c: Option<char> = None;
    loop {
        let mut c = '\0';
        match r.read_char(&mut c) {
            Ok(0) => break,
            Ok(_) => {
                let s = translate_char(cmd, c, &mut prev_c);
                match write!(w, "{}", s) {
                    Ok(())   => (),
                    Err(err) => {
                        eprintln!("{}", err);
                        return false;
                    },
                }
            },
            Err(err) => {
                eprintln!("{}", err);
                return false;
            },
        }
    }
    true
}

fn parse_char(chars: &mut PushbackIter<Chars>) -> Option<char>
{
    match chars.next() {
        Some('\\') => Some(escape_for_tr(chars)),
        Some(c)    => Some(c),
        None       => None,
    }
}

fn parse_char_class(chars: &mut PushbackIter<Chars>) -> Option<CharClass>
{
    let mut class_name = String::new();
    loop {
        match chars.next() {
            Some(c @ ':') => {
                match chars.next() {
                    Some(']') => {
                        break;
                    },
                    Some(c2) => {
                        class_name.push(c);
                        class_name.push(c2);
                    },
                    None => {
                        eprintln!("Unclosed character class");
                        return None;
                    },
                }
            }
            Some(c) => class_name.push(c),
            None => {
                eprintln!("Unclosed character class");
                return None;
            },
        }
    }
    match class_name.as_str() {
        "alnum"  => Some(CharClass::Alnum),
        "alpha"  => Some(CharClass::Alpha),
        "blank"  => Some(CharClass::Blank),
        "cntrl"  => Some(CharClass::Cntrl),
        "digit"  => Some(CharClass::Digit),
        "graph"  => Some(CharClass::Graph),
        "lower"  => Some(CharClass::Lower),
        "print"  => Some(CharClass::Print),
        "punct"  => Some(CharClass::Punct),
        "space"  => Some(CharClass::Space),
        "upper"  => Some(CharClass::Upper),
        "xdigit" => Some(CharClass::Xdigit),
        _        => {
            eprintln!("Invalid character class");
            None
        },
    }
}

fn parse_equiv_char(chars: &mut PushbackIter<Chars>) -> Option<char>
{
    match parse_char(chars) {
        Some(c) => {
            match chars.next() {
                Some('=') => {
                    match chars.next() {
                        Some(']') => Some(c),
                        _ => {
                            eprintln!("Unclosed equivalent character");
                            None
                        },
                    }
                },
                _ => {
                    eprintln!("Unclosed equivalent character");
                    None
                },
            }
        },
        None => {
            eprintln!("No equivalent character");
            None
        }
    }
}

fn parse_number(chars: &mut PushbackIter<Chars>) -> Option<Option<usize>>
{
    match chars.next() {
        Some('0') => {
            let mut digits = String::new();
            digits.push('0');
            loop {
                match chars.next() {
                    Some(c @ ('0'..='7')) => digits.push(c),
                    Some(c) => {
                        chars.undo(c);
                        break;
                    },
                    None => break,
                }
            }
            match usize::from_str_radix(digits.as_str(), 8) {
                Ok(n)    => Some(Some(n)),
                Err(err) => {
                    eprintln!("{}", err);
                    None
                }
            }
        }
        Some(c @ ('1'..='9')) => {
            let mut digits = String::new();
            digits.push(c);
            loop {
                match chars.next() {
                    Some(c @ ('0'..='9')) => digits.push(c),
                    Some(c) => {
                        chars.undo(c);
                        break;
                    },
                    None => break,
                }
            }
            match digits.parse::<usize>() {
                Ok(n)    => Some(Some(n)),
                Err(err) => {
                    eprintln!("{}", err);
                    None
                }
            }
        },
        Some(c) => {
            chars.undo(c);
            Some(None)
        },
        None => Some(None),
    }
}

fn parse_set(s: &String, is_key_set: bool) -> Option<Vec<Element>>
{
    let mut chars = PushbackIter::new(s.chars());
    let mut elems: Vec<Element> = Vec::new();
    loop {
        match chars.next() {
            Some('[') => {
                match chars.next() {
                    Some(':') => {
                        match parse_char_class(&mut chars) {
                            Some(class) => elems.push(Element::CharClass(class)),
                            None        => return None,
                        }
                    },
                    Some('=') => {
                        if is_key_set {
                            match parse_equiv_char(&mut chars) {
                                Some(c) => elems.push(Element::Char(c)),
                                None    => return None,
                            }
                        } else {
                            eprintln!("Equivalent character can't be in value set");
                            return None;
                        }
                    },
                    Some(c) => {
                        chars.undo(c);
                        match parse_char(&mut chars) {
                            Some(c2) => {
                                match chars.next() {
                                    Some('*') => {
                                        let n = match parse_number(&mut chars) {
                                            Some(Some(n)) => Some(n),
                                            Some(None)    => None,
                                            None          => return None,
                                        };
                                        match chars.next() {
                                            Some(']') => {
                                                match n {
                                                    Some(n) => {
                                                        for _ in 0..n {
                                                            elems.push(Element::Char(c2));
                                                        }
                                                    },
                                                    None    => {
                                                        elems.push(Element::RepetitionToUnknown(c2));
                                                    },
                                                }
                                            },
                                            Some(_)   => {
                                                eprintln!("Invalid expression in bracket");
                                                return None;
                                            },
                                            None      => {
                                                eprintln!("Unclosed bracket");
                                                return None;
                                            },
                                        }
                                    },
                                    _ => {
                                        eprintln!("Invalid expression in bracket");
                                        return None;
                                    },
                                }
                            },
                            None => {
                                eprintln!("No character in bracket");
                                return None;
                            },
                        }
                    },
                    None => {
                        eprintln!("Unclosed bracket");
                        return None;
                    },
                }
            },
            Some(c) => {
                chars.undo(c);
                match parse_char(&mut chars) {
                    Some(c) => {
                        match chars.next() {
                            Some('-') => {
                                match parse_char(&mut chars) {
                                    Some(c2) => {
                                        let n1 = c as u32;
                                        let n2 = c2 as u32;
                                        if n1 < n2 {
                                            for i in n1..(n2.saturating_add(1)) {
                                                elems.push(Element::Char(char::from_u32(i).unwrap()));
                                            }
                                        } else {
                                            eprintln!("Invalid character range");
                                            return None;
                                        }
                                    },
                                    None => {
                                        chars.undo('-');
                                        elems.push(Element::Char(c));
                                    },
                                }
                            },
                            Some(c2) => {
                                chars.undo(c2);
                                elems.push(Element::Char(c));
                            },
                            None => elems.push(Element::Char(c)),
                        }
                    },
                    None    => break,
                }
            },
            None => break,
        }
    }
    Some(elems)
}

fn match_sets(is_complement: bool, set1: &[Element], set2: &mut Vec<Element>) -> bool
{
    if !is_complement {
        let mut c_and_i: Option<(char, usize)> = None;  
        for i in 0..min(set1.len(), set2.len()) {
            match (set1[i], set2[i]) {
                (Element::CharClass(_), Element::RepetitionToUnknown(_)) => (),
                (Element::RepetitionToUnknown(_), Element::RepetitionToUnknown(_)) => (),
                (_, Element::RepetitionToUnknown(c)) => {
                    match c_and_i {
                        Some(_) => {
                            eprintln!("Too many repetitions to unknown");
                            return false;
                        },
                        None => c_and_i = Some((c, i)),
                    }
                },
                (_, _) => (),
            }
        }
        match c_and_i {
            Some((c, i)) => {
                if set1.len() > set2.len() {
                    set2.remove(i);
                    for j in i..(i + set1.len() - set2.len()) {
                        set2.insert(j, Element::Char(c));
                    }
                }
            },
            None => (),
        }
        match (set1.is_empty(), set2.is_empty()) {
            (true, _)      => set2.clear(),
            (false, true)  => {
                eprintln!("Value set must be non-empty");
                return false;
            },
            (false, false) => {
                if set1.len() > set2.len() {
                    let elem = set2[set2.len() - 1];
                    for _ in set2.len()..set1.len() {
                        set2.push(elem);
                    }
                }
                set2.resize(set1.len(), set2[set2.len() - 1]);                
            },
        }
        for i in 0..min(set1.len(), set2.len()) {
            match (set1[i], set2[i]) {
                (Element::CharClass(class1), Element::CharClass(class2)) if class1 == class2 => (),
                (Element::CharClass(CharClass::Lower), Element::CharClass(CharClass::Upper)) => (),
                (Element::CharClass(CharClass::Upper), Element::CharClass(CharClass::Lower)) => (),
                (Element::CharClass(_), Element::CharClass(_)) => {
                    eprintln!("Can't match character classes");
                    return false;
                },
                (_, Element::CharClass(_)) => {
                    eprintln!("Can't match character to character class");
                    return false;
                },
                (_, _) => (),
            }
        }

    } else {
        if set2.is_empty() {
            eprintln!("Value set must be non-empty");
            return false;
        }
        set2.resize(1, set2[set2.len() - 1]);
    }
    true
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "Ccds");
    let mut opts = Options {
        complement_flag: false,
        deleting_flag: false,
        squeezing_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('C' | 'c', _))) => opts.complement_flag = true,
            Some(Ok(Opt('d', _))) => opts.deleting_flag = true,
            Some(Ok(Opt('s', _))) => opts.squeezing_flag = true,
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
    let sets: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    let cmd = match (opts.deleting_flag, opts.squeezing_flag) {
        (false, false) => {
            match (sets.get(0), sets.get(1)) {
                (Some(s1), Some(s2)) => {
                    if sets.len() > 2 {
                        eprintln!("Too many arguments");
                        return 1;
                    }
                    match parse_set(s1, true) {
                        Some(set1) => {
                            match parse_set(s2, false) {
                                Some(mut set2) => {
                                    if !match_sets(opts.complement_flag, &set1, &mut set2) { return 1; }
                                    let mut key_set = set_to_key_set(&set1);
                                    key_set.is_complement = opts.complement_flag;
                                    Command::Replace(key_set, set2)
                                },
                                None => return 1,
                            }
                        },
                        None => return 1,
                    }
                },
                (_, _) => {
                    eprintln!("Too few arguments");
                    return 1;
                },
            }
        },
        (false, true) => {
            match (sets.get(0), sets.get(1)) {
                (Some(s1), Some(s2)) => {
                    if sets.len() > 2 {
                        eprintln!("Too many arguments");
                        return 1;
                    }
                    match parse_set(s1, true) {
                        Some(set1) => {
                            match parse_set(s2, false) {
                                Some(mut set2) => {
                                    if !match_sets(opts.complement_flag, &set1, &mut set2) { return 1; }
                                    let mut key_set1 = set_to_key_set(&set1);
                                    key_set1.is_complement = opts.complement_flag;
                                    let key_set2 = set_to_key_set(&set2);
                                    Command::ReplaceAndSqueeze(key_set1, set2, key_set2)
                                },
                                None => return 1,
                            }
                        },
                        None => return 1,
                    }
                },
                (Some(s), None) => {
                    match parse_set(s, true) {
                        Some(set) => {
                            let mut key_set = set_to_key_set(&set);
                            key_set.is_complement = opts.complement_flag;
                            Command::Squeeze(key_set)
                        },
                        None => return 1,
                    }
                },
                (_, _) => {
                    eprintln!("Too few arguments");
                    return 1;
                },
            }
        },
        (true, false) => {
            match sets.get(0) {
                Some(s) => {
                    match parse_set(s, true) {
                        Some(set) => {
                            if sets.len() > 1 {
                                eprintln!("Too many arguments");
                                return 1;
                            }
                            let mut key_set = set_to_key_set(&set);
                            key_set.is_complement = opts.complement_flag;
                            Command::Delete(key_set)
                        },
                        None => return 1,
                    }
                },
                None => {
                    eprintln!("Too few arguments");
                    return 1;
                },
            }
        },
        (true, true) => {
            match (sets.get(0), sets.get(1)) {
                (Some(s1), Some(s2)) => {
                    if sets.len() > 2 {
                        eprintln!("Too many arguments");
                        return 1;
                    }
                    match parse_set(s1, true) {
                        Some(set1) => {
                            match parse_set(s2, false) {
                                Some(set2) => {
                                    let mut key_set1 = set_to_key_set(&set1);
                                    key_set1.is_complement = opts.complement_flag;
                                    let key_set2 = set_to_key_set(&set2);
                                    Command::DeleteAndSqueeze(key_set1, key_set2)
                                },
                                None => return 1,
                            }
                        },
                        None => return 1,
                    }
                },
                (_, _) => {
                    eprintln!("Too few arguments");
                    return 1;
                },
            }
        },
    };
    if tr(&cmd) { 0 } else { 1 }
}
