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
use std::char;
use std::io::*;
use std::iter::Iterator;
use std::cmp::Ordering;
use std::ffi::*;
use std::fmt;
use std::fs;
use std::fs::*;
use std::mem::MaybeUninit;
use std::os::unix::ffi::OsStrExt;
use std::os::unix::fs::DirBuilderExt;
use std::os::unix::fs::FileTypeExt;
use std::os::unix::fs::MetadataExt;
use std::os::unix::fs::PermissionsExt;
use std::os::unix::fs::symlink;
use std::path;
use std::path::*;
use std::ptr::null;
use std::ptr::null_mut;
use std::result;
use std::str::*;
use libc;

pub use libc::{uid_t, gid_t};

#[derive(Copy, Clone)]
pub struct TimeValue
{
    pub sec: i64,
    pub usec: i64,
}

#[derive(Copy, Clone)]
pub struct Times
{
    pub atime: TimeValue,
    pub mtime: TimeValue,
}

#[derive(Clone)]
pub struct Tm
{
    pub sec: i32,
    pub min: i32,
    pub hour: i32,
    pub mday: i32,
    pub mon: i32,
    pub year: i32,
    pub wday: i32,
    pub yday: i32,
    pub isdst: i32,
    pub gmtoff: i64,
    pub zone: Option<CString>,
}

#[derive(Copy, Clone, PartialEq)]
pub enum DoFlag
{
    NoDereference,
    NonRecursiveDereference,
    RecursiveDereference,
}

#[derive(Copy, Clone, PartialEq)]
pub enum  DoAction
{
    DirActionBeforeList,
    FileAction,
    DirActionAfterList,
}

#[derive(Clone)]
pub struct DoEntry
{
    pub name: OsString,
    pub metadata: fs::Metadata,
    pub link: Option<PathBuf>,
}

pub trait PushbackIterator: Iterator
{
    fn undo(&mut self, item: Self::Item);
}

#[derive(Clone)]
pub struct PushbackIter<I: Iterator>
{
    iter: I,
    pushed_items: Vec<I::Item>,
}

impl<I: Iterator> PushbackIter<I>
{
    pub fn new(iter: I) -> PushbackIter<I>
    { PushbackIter { iter, pushed_items: Vec::new(), } }
}

impl<I: Iterator> Iterator for PushbackIter<I>
{
    type Item = I::Item;
    
    fn next(&mut self) -> Option<I::Item>
    {
        match self.pushed_items.pop() {
            Some(item) => Some(item),
            None       => self.iter.next(),
        }
    }
}

impl<I: Iterator> PushbackIterator for PushbackIter<I>
{
    fn undo(&mut self, item: Self::Item)
    { self.pushed_items.push(item); }
}

pub trait CharByteRead: BufRead
{
    fn read_char(&mut self, c: &mut char) -> Result<usize>
    {
        let mut char_buf: Vec<u8> = Vec::new();
        for i in 0..6 {
            let mut buf: [u8; 1] = [0; 1];
            let mut is_eof = false;
            loop {
                match self.read(&mut buf) {
                    Ok(0) => {
                        is_eof = true;
                        break;
                    },
                    Ok(_) => break,
                    Err(err) if err.kind() == ErrorKind::Interrupted => (),
                    Err(err) => return Err(err),
                }
            }
            if !is_eof {
                char_buf.push(buf[0]);
                match String::from_utf8(char_buf.clone()) {
                    Ok(string) => {
                        *c = string.chars().next().unwrap();
                        return Ok(i + 1);
                    }
                    Err(_)     => ()
                }
            } else {
                if i == 0 {
                    return Ok(0);
                } else {
                    return Err(Error::new(ErrorKind::InvalidData, "stream did not contain valid UTF-8"));
                }
            }
        }
        Err(Error::new(ErrorKind::InvalidData, "stream did not contain valid UTF-8"))
    }
}

pub struct CharByteReader<R: BufRead>
{
    reader: R,
}

impl<R: BufRead> CharByteReader<R>
{
    pub fn new(reader: R) -> CharByteReader<R>
    { CharByteReader { reader, } }
}

impl<R: BufRead> Read for CharByteReader<R>
{
    fn read(&mut self, buf: &mut [u8]) -> Result<usize>
    { self.reader.read(buf) }
}

impl<R: BufRead> BufRead for CharByteReader<R>
{
    fn fill_buf(&mut self) -> Result<&[u8]>
    { self.reader.fill_buf() }
    
    fn consume(&mut self, amt: usize)
    { self.reader.consume(amt); }
}

impl<R: BufRead> CharByteRead for CharByteReader<R>
{}

pub trait ByteRead: BufRead
{
    fn read_byte(&mut self, b: &mut u8) -> Result<bool>
    {
        let mut byte_buf: [u8; 1] = [0];
        loop {
            match self.read(&mut byte_buf) {
                Ok(0) => return Ok(false),
                Ok(_) => {
                    *b = byte_buf[0];
                    return Ok(true)
                },
                Err(err) if err.kind() == ErrorKind::Interrupted => (),
                Err(err) => return Err(err),
            }
        }
    }
}

pub struct ByteReader<R: BufRead>
{
    reader: R,
}

impl<R: BufRead> ByteReader<R>
{
    pub fn new(reader: R) -> ByteReader<R>
    { ByteReader { reader, } }
}

impl<R: BufRead> Read for ByteReader<R>
{
    fn read(&mut self, buf: &mut [u8]) -> Result<usize>
    { self.reader.read(buf) }
}

impl<R: BufRead> BufRead for ByteReader<R>
{
    fn fill_buf(&mut self) -> Result<&[u8]>
    { self.reader.fill_buf() }
    
    fn consume(&mut self, amt: usize)
    { self.reader.consume(amt); }
}

impl<R: BufRead> ByteRead for ByteReader<R>
{}

pub struct Regex
{
    libc_regex: libc::regex_t,
}

impl Regex
{
    pub fn new<S: AsRef<OsStr>>(pattern: S, flags: i32) -> RegexResult
    {
        let mut regex: Regex = unsafe { MaybeUninit::uninit().assume_init() };
        let pattern_cstring = CString::new(pattern.as_ref().as_bytes()).unwrap();
        let libc_regex_err = unsafe { libc::regcomp(&mut regex.libc_regex as *mut libc::regex_t, pattern_cstring.as_ptr(), flags) };
        if libc_regex_err == 0 {
            Ok(regex)
        } else {
            let size = unsafe { libc::regerror(libc_regex_err, &regex.libc_regex as *const libc::regex_t, null_mut(), 0) };
            let mut err_buf: Vec<u8> = vec![0; size];
            unsafe { libc::regerror(libc_regex_err, &regex.libc_regex as *const libc::regex_t, err_buf.as_mut_ptr() as *mut libc::c_char, size); };
            Err(RegexError {
                    libc_regex_error: libc_regex_err,
                    message: CStr::from_bytes_with_nul(err_buf.as_slice()).unwrap().to_string_lossy().into_owned(),
            })
        }
    }
    
    pub fn is_match<S: AsRef<OsStr>>(&self, s: S, count_and_matches: Option<(usize, &mut Vec<RegexMatch>)>, flags: i32) -> bool
    {
        let s_cstring = CString::new(s.as_ref().as_bytes()).unwrap();
        match count_and_matches {
            Some((count, matches)) => {
                let mut match_buf: Vec<libc::regmatch_t> = vec![libc::regmatch_t {
                    rm_so: -1 as libc::regoff_t,
                    rm_eo: -1 as libc::regoff_t,
                }; count];
                let libc_regex_err = unsafe { libc::regexec(&self.libc_regex as *const libc::regex_t, s_cstring.as_ptr(), count, match_buf.as_mut_ptr(), flags) };
                if libc_regex_err == 0 {
                    for m in &match_buf {
                        if m.rm_so == -1 && m.rm_eo == -1 { break; }
                        matches.push(RegexMatch { start: m.rm_so as usize, end: m.rm_eo as usize, });
                    }
                    true
                } else {
                    false
                }
            },
            None => {
                let libc_regex_err = unsafe { libc::regexec(&self.libc_regex as *const libc::regex_t, s_cstring.as_ptr(), 0, null_mut(), flags) };
                libc_regex_err == 0
            },
        }
    }
}

impl Drop for Regex
{
    fn drop(&mut self)
    { unsafe { libc::regfree(&mut self.libc_regex as *mut libc::regex_t); }; }
}

#[derive(Copy, Clone)]
pub struct RegexMatch
{
    pub start: usize,
    pub end: usize,
}

pub type RegexResult = result::Result<Regex, RegexError>;

#[derive(Clone, Debug)]
pub struct RegexError
{
    libc_regex_error: i32,
    message: String,
}

impl RegexError
{
    pub fn regex_error(&self) -> i32
    { self.libc_regex_error }
}

impl fmt::Display for RegexError
{
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result
    { write!(f, "{}", self.message) }
}

#[derive(Clone)]
pub enum Mode
{
    Number(u32),
    Symbol(Vec<ModeClause>),
}

#[derive(Clone)]
pub struct ModeClause
{
    who_list: ModeWhoList,
    action_list: Vec<ModeAction>,
}

#[derive(Copy, Clone)]
struct ModeWhoList
{
    has_user: bool,
    has_group: bool,
    has_other: bool,
}

#[derive(Copy, Clone)]
struct ModeAction
{
    op: ModeOp,
    perm: ModePermListOrPermCopy,
}

#[derive(Copy, Clone)]
enum ModeOp
{
    Add,
    Delete,
    Set,
}

#[derive(Copy, Clone)]
enum ModePermListOrPermCopy
{
    List(ModePermList),
    Copy(ModePermCopy),
}

#[derive(Copy, Clone)]
struct ModePermList
{
    has_reading: bool,
    has_writing: bool,
    has_executing: bool,
    has_searching: bool,
    has_set_id: bool,
    has_sticky: bool,
}

#[derive(Copy, Clone)]
enum ModePermCopy
{
    User,
    Group,
    Other,
}

impl Mode
{
    pub fn parse(s: &str) -> Option<Mode>
    {
        match u32::from_str_radix(s, 8) {
            Ok(x)  => Some(Mode::Number(x & 0o7777)),
            Err(_) => {
                let mut clauses: Vec<ModeClause> = Vec::new();
                for clause_s in s.split(',') {
                    let mut clause_s_iter = PushbackIter::new(clause_s.chars());
                    let mut who_list = ModeWhoList {
                        has_user: false,
                        has_group: false,
                        has_other: false,
                    };
                    let mut action_list: Vec<ModeAction> = Vec::new();
                    loop {
                        match clause_s_iter.next() {
                            Some('a') => {
                                who_list.has_user = true;
                                who_list.has_group = true;
                                who_list.has_other = true;
                            },
                            Some('u') => who_list.has_user = true,
                            Some('g') => who_list.has_group = true,
                            Some('o') => who_list.has_other = true,
                            Some(c)   => {
                                clause_s_iter.undo(c);
                                break;
                            },
                            None      => break,
                        }
                    }
                    loop {
                        let op = match clause_s_iter.next() {
                            Some('+') => ModeOp::Add,
                            Some('-') => ModeOp::Delete,
                            Some('=') => ModeOp::Set,
                            Some(_)   => return None,
                            None      => break,
                        };
                        let perm_copy = match clause_s_iter.next() {
                            Some('u') => Some(ModePermCopy::User),
                            Some('g') => Some(ModePermCopy::Group),
                            Some('o') => Some(ModePermCopy::Other),
                            Some(c)   => {
                                clause_s_iter.undo(c);
                                None
                            },
                            None      => None,
                        };
                        let action = match perm_copy {
                            Some(perm_copy) => {
                                ModeAction {
                                    op,
                                    perm: ModePermListOrPermCopy::Copy(perm_copy),
                                }
                            },
                            None => {
                                let mut perm_list = ModePermList {
                                    has_reading: false,
                                    has_writing: false,
                                    has_executing: false,
                                    has_searching: false,
                                    has_set_id: false,
                                    has_sticky: false,
                                };
                                loop {
                                    match clause_s_iter.next() {
                                        Some('r') => perm_list.has_reading = true,
                                        Some('w') => perm_list.has_writing = true,
                                        Some('x') => perm_list.has_executing = true,
                                        Some('X') => perm_list.has_searching = true,
                                        Some('s') => perm_list.has_set_id = true,
                                        Some('t') => perm_list.has_sticky = true,
                                        Some(c)   => {
                                            clause_s_iter.undo(c);
                                            break;
                                        },
                                        None      => break,
                                    }
                                }
                                ModeAction {
                                    op,
                                    perm: ModePermListOrPermCopy::List(perm_list),
                                }
                            },
                        };
                        action_list.push(action);
                    }
                    if !action_list.is_empty() {
                        clauses.push(ModeClause {
                                who_list,
                                action_list,
                        });
                    } else {
                        return None
                    }
                }
                Some(Mode::Symbol(clauses))
            },
        }
    }

    pub fn change_mode(&self, mode: u32, is_dir: bool) -> u32
    {
        match self {
            Mode::Number(new_mode) => *new_mode,
            Mode::Symbol(clauses) => {
                let mut current_mode = mode;
                for clause in clauses {
                    let mut who_mode = 0;
                    if clause.who_list.has_user { who_mode |= 0o4700; }
                    if clause.who_list.has_group { who_mode |= 0o2070; }
                    if clause.who_list.has_other { who_mode |= 0o1007; }
                    if !clause.who_list.has_user && !clause.who_list.has_group && !clause.who_list.has_other {
                        let mask = umask(0);
                        umask(mask);
                        who_mode |= 0o7777 & !mask;
                    }
                    for action in &clause.action_list {
                        let mut perm_mode = 0;
                        match action.perm {
                            ModePermListOrPermCopy::List(perm_list) => {
                                if perm_list.has_reading { perm_mode |= 0o444; }
                                if perm_list.has_writing { perm_mode |= 0o222; }
                                if perm_list.has_executing { perm_mode |= 0o111; }
                                if perm_list.has_searching && (is_dir || (current_mode & 0o111) != 0)  { perm_mode |= 0o111; }
                                if perm_list.has_set_id { perm_mode |= 0o6000; }
                                if perm_list.has_sticky { perm_mode |= 0o1000; }
                            },
                            ModePermListOrPermCopy::Copy(ModePermCopy::User) => {
                                perm_mode |= current_mode & 0o700;
                                perm_mode |= (current_mode & 0o700) >> 3;
                                perm_mode |= (current_mode & 0o700) >> 6;
                            },
                            ModePermListOrPermCopy::Copy(ModePermCopy::Group) => {
                                perm_mode |= (current_mode & 0o70) << 3;
                                perm_mode |= current_mode & 0o70;
                                perm_mode |= (current_mode & 0o70) >> 3;
                            },
                            ModePermListOrPermCopy::Copy(ModePermCopy::Other) => {
                                perm_mode |= (current_mode & 0o7) << 6;
                                perm_mode |= (current_mode & 0o7) << 3;
                                perm_mode |= current_mode & 0o7;
                            },
                        }
                        match action.op {
                            ModeOp::Add    => current_mode |= who_mode & perm_mode,
                            ModeOp::Delete => current_mode &= !(who_mode & perm_mode),
                            ModeOp::Set    => current_mode = (current_mode & !who_mode) | (who_mode & perm_mode),
                        }
                    }
                }
                current_mode
            },
        }
    }
}

pub fn escape(chars: &mut PushbackIter<Chars>) -> String
{
    match chars.next() {
        Some('a')  => String::from("\x07"),
        Some('b')  => String::from("\x08"),
        Some('c')  => String::new(),
        Some('f')  => String::from("\x0c"),
        Some('n')  => String::from("\n"),
        Some('r')  => String::from("\r"),
        Some('t')  => String::from("\t"),
        Some('v')  => String::from("\x0b"),
        Some('\\') => String::from("\\"),
        Some('0')  => {
            let mut digits = String::from("0");
            for _ in 0..3 {
                match chars.next() {
                    Some(c @ ('0'..='7')) => {
                        digits.push(c);
                    }
                    Some(c) => {
                        chars.undo(c);
                        break;
                    },
                    None => (),
                }
            }
            match char::from_u32(u32::from_str_radix(digits.as_str(), 8).unwrap()) {
                Some(c) => format!("{}", c),
                None    => format!("{}", char::REPLACEMENT_CHARACTER),
            }
        },
        Some(c)    => format!("\\{}", c),
        None       => String::from("\\"),
    }
}

pub fn escape_for_printf(chars: &mut PushbackIter<Chars>) -> String
{
    match chars.next() {
        Some('a')  => String::from("\x07"),
        Some('b')  => String::from("\x08"),
        Some('f')  => String::from("\x0c"),
        Some('n')  => String::from("\n"),
        Some('r')  => String::from("\r"),
        Some('t')  => String::from("\t"),
        Some('v')  => String::from("\x0b"),
        Some('\\') => String::from("\\"),
        Some(c @ ('0'..='7'))  => {
            let mut digits = String::new();
            digits.push(c);
            for _ in 0..2 {
                match chars.next() {
                    Some(c @ ('0'..='7')) => {
                        digits.push(c);
                    }
                    Some(c) => {
                        chars.undo(c);
                        break;
                    },
                    None => (),
                }
            }
            match char::from_u32(u32::from_str_radix(digits.as_str(), 8).unwrap()) {
                Some(c) => format!("{}", c),
                None    => format!("{}", char::REPLACEMENT_CHARACTER),
            }
        },
        Some(c)    => format!("\\{}", c),
        None       => String::from("\\"),
    }
}

pub fn escape_for_tr(chars: &mut PushbackIter<Chars>) -> char
{
    match chars.next() {
        Some('a')  => '\x07',
        Some('b')  => '\x08',
        Some('f')  => '\x0c',
        Some('n')  => '\n',
        Some('r')  => '\r',
        Some('t')  => '\t',
        Some('v')  => '\x0b',
        Some('\\') => '\\',
        Some(c @ ('0'..='7'))  => {
            let mut digits = String::new();
            digits.push(c);
            for _ in 0..2 {
                match chars.next() {
                    Some(c @ ('0'..='7')) => {
                        digits.push(c);
                    }
                    Some(c) => {
                        chars.undo(c);
                        break;
                    },
                    None => (),
                }
            }
            match char::from_u32(u32::from_str_radix(digits.as_str(), 8).unwrap()) {
                Some(c) => c,
                None    => char::REPLACEMENT_CHARACTER,
            }
        },
        Some(c)    => c,
        None       => '\0',
    }
}

pub fn dir_name_and_base_name(path: &str, suffix: Option<&str>) -> (String, String)
{
    let (dir_name, base_name) = match path.trim_end_matches(path::MAIN_SEPARATOR).rsplit_once(path::MAIN_SEPARATOR) {
        Some((tmp_dir_name, tmp_base_name)) => {
            let mut dir_name = String::from(tmp_dir_name.trim_end_matches(path::MAIN_SEPARATOR));
            if dir_name.is_empty() && path.starts_with(path::MAIN_SEPARATOR) {
                dir_name = String::new();
                dir_name.push(path::MAIN_SEPARATOR);
            }
            (dir_name, String::from(tmp_base_name)) 
        },
        None => {
            let mut dir_name = String::new();
            if path.starts_with(path::MAIN_SEPARATOR) {
                dir_name.push(path::MAIN_SEPARATOR);
            } else {
                dir_name.push('.');
            }
            (dir_name, String::from(path))
        },
    };
    let base_name = match suffix {
        Some(suffix) if base_name.ends_with(suffix) => String::from(&base_name[0..(base_name.len() - suffix.len())]),
        Some(_) | None => base_name,
    };
    (dir_name, base_name)
}

pub fn copy_stream<R: Read, W: Write>(r: &mut R, w: &mut W, in_path: Option<&Path>, out_path: Option<&Path>) -> bool
{
    let mut buf: Vec<u8> = vec![0; 4096];
    let mut is_success = true;
    loop {
        match r.read(&mut buf) {
            Ok(0) => break,
            Ok(n) => {
                match w.write_all(&buf[0..n]) {
                    Ok(())   => (),
                    Err(err) => {
                        match out_path {
                            Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                            None           => eprintln!("{}", err),
                        }
                        is_success = false;
                        break;
                    },
                }
            },
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                match in_path {
                    Some(in_path) => eprintln!("{}: {}", in_path.to_string_lossy(), err),
                    None          => eprintln!("{}", err),
                }
                is_success = false;
                break;
            },
        }
    }
    if is_success {
        match w.flush() {
            Ok(())   => (),
            Err(err) => {
                match out_path {
                    Some(out_path) => eprintln!("{}: {}", out_path.to_string_lossy(), err),
                    None           => eprintln!("{}", err),
               }
               is_success = false;
            },
        }
    }
    is_success
}

fn create_file<P: AsRef<Path>>(path: P) -> Result<File>
{
    let res = match remove_file(path.as_ref()) {
        Ok(()) => Ok(()),
        Err(err) if err.kind() == ErrorKind::NotFound => Ok(()),
        Err(err) => Err(err),
    };
    match res {
        Ok(()) => {
            let mut opts = OpenOptions::new();
            opts.create_new(true).write(true);
            opts.open(path.as_ref())
        },
        Err(err) => Err(err),
    }
}

pub fn copy_file<P: AsRef<Path>, Q: AsRef<Path>>(src_path: P, dst_path: Q) -> bool
{
    match File::open(src_path.as_ref()) {
        Ok(mut src_file) => {
            match create_file(dst_path.as_ref()) {
                Ok(mut dst_file) => copy_stream(&mut src_file, &mut dst_file, Some(src_path.as_ref()), Some(dst_path.as_ref())),
                Err(err)     => {
                    eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
                    false
                },
            }
        },
        Err(err) => {
            eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
            false
        }
    }
}

fn remove_file_and_symlink<P: AsRef<Path>, Q: AsRef<Path>>(path1: P, path2: Q) -> Result<()>
{
    let res = match remove_file(path2.as_ref()) {
        Ok(()) => Ok(()),
        Err(err) if err.kind() == ErrorKind::NotFound => Ok(()),
        Err(err) => Err(err),
    };
    match res {
        Ok(()) => symlink(path1.as_ref(), path2.as_ref()),
        Err(err) => Err(err),
    }
}

pub fn copy_symlink<P: AsRef<Path>, Q: AsRef<Path>>(src_path: P, dst_path: Q) -> bool
{
    match read_link(src_path.as_ref()) {
        Ok(path_buf) => {
            match remove_file_and_symlink(path_buf.as_path(), dst_path.as_ref()) {
                Ok(())   => true,
                Err(err) => {
                    eprintln!("{}: {}", dst_path.as_ref().to_string_lossy(), err);
                    false
                }
            }
        },
        Err(err) => {
            eprintln!("{}: {}", src_path.as_ref().to_string_lossy(), err);
            false
        }
    }
}

pub fn mkdir_for_copy<P: AsRef<Path>>(path: P, metadata: &fs::Metadata) -> bool
{
    let saved_mask = umask(0);
    let mut dir_builder = DirBuilder::new();
    dir_builder.mode((metadata.permissions().mode() & !saved_mask) | 0o700);
    let res = dir_builder.create(path.as_ref());
    umask(saved_mask);
    match res {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    }
}

fn remove_file_and_mknod<P: AsRef<Path>>(path: P, mode: u32, dev: u64) -> Result<()>
{
    let res = match remove_file(path.as_ref()) {
        Ok(()) => Ok(()),
        Err(err) if err.kind() == ErrorKind::NotFound => Ok(()),
        Err(err) => Err(err),
    };
    match res {
        Ok(()) => mknod(path.as_ref(), mode, dev),
        Err(err) => Err(err),
    }
}

pub fn mknod_for_copy<P: AsRef<Path>>(path: P, metadata: &fs::Metadata) -> bool
{
    let mode = if metadata.file_type().is_block_device() {
        libc::S_IFBLK
    } else if metadata.file_type().is_char_device() {
        libc::S_IFCHR
    } else if metadata.file_type().is_fifo() {
        libc::S_IFIFO
    } else if metadata.file_type().is_socket() {
        libc::S_IFSOCK
    } else {
        0
    };
    if mode != 0 {
        match remove_file_and_mknod(path.as_ref(), mode | (metadata.permissions().mode() & 0o7777), metadata.rdev()) {
            Ok(())   => true,
            Err(err) => {
                eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                false
            }
        }
    } else {
        eprintln!("{}: Unknown special file type", path.as_ref().to_string_lossy());
        false
    }
}

pub fn access_for_remove<P: AsRef<Path>>(path: P, is_success: &mut bool) -> bool
{
    match access(path.as_ref(), libc::W_OK) {
        Ok(is_access) => is_access,
        Err(err)      => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            *is_success = false;
            true
        },
    }
}

fn metadata_and_set_permissions<P: AsRef<Path>>(path: P, mode: u32) -> Result<()>
{
    let metadata = fs::metadata(path.as_ref())?;
    let mut perms = metadata.permissions();
    perms.set_mode(mode);
    set_permissions(path.as_ref(), perms)
}

pub fn set_mode<P: AsRef<Path>>(path: P, mode: u32) -> bool
{
    match metadata_and_set_permissions(path.as_ref(), mode) {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    }
}

pub fn access<P: AsRef<Path>>(path: P, mode: i32) -> Result<bool>
{
    let path_cstring = CString::new(path.as_ref().as_os_str().as_bytes()).unwrap();
    let res = unsafe { libc::access(path_cstring.as_ptr(), mode) };
    if res != -1 {
        Ok(true)
    } else {
        let err = Error::last_os_error();
        match err.raw_os_error() {
            Some(os_err) if os_err == libc::EACCES => Ok(false),
            _ => Err(err),
        }
    }
}

pub fn mknod<P: AsRef<Path>>(path: P, mode: u32, dev: u64) -> Result<()>
{
    let path_cstring = CString::new(path.as_ref().as_os_str().as_bytes()).unwrap();
    let res = unsafe { libc::mknod(path_cstring.as_ptr(), mode as libc::mode_t, dev as libc::dev_t) };
    if res != -1 {
        Ok(())
    } else {
        Err(Error::last_os_error())
    }
}

pub fn mkfifo<P: AsRef<Path>>(path: P, mode: u32) -> Result<()>
{
    let path_cstring = CString::new(path.as_ref().as_os_str().as_bytes()).unwrap();
    let res = unsafe { libc::mkfifo(path_cstring.as_ptr(), mode as libc::mode_t) };
    if res != -1 {
        Ok(())
    } else {
        Err(Error::last_os_error())
    }
}


pub fn chown<P: AsRef<Path>>(path: P, uid: uid_t, gid: gid_t) -> Result<()>
{
    let path_cstring = CString::new(path.as_ref().as_os_str().as_bytes()).unwrap();
    let res = unsafe { libc::chown(path_cstring.as_ptr(), uid, gid) };
    if res != -1 {
        Ok(())
    } else {
        Err(Error::last_os_error())
    }
}

pub fn lchown<P: AsRef<Path>>(path: P, uid: uid_t, gid: gid_t) -> Result<()>
{
    let path_cstring = CString::new(path.as_ref().as_os_str().as_bytes()).unwrap();
    let res = unsafe { libc::lchown(path_cstring.as_ptr(), uid, gid) };
    if res != -1 {
        Ok(())
    } else {
        Err(Error::last_os_error())
    }
}

pub fn utimes<P: AsRef<Path>>(path: P, times: &Times) -> Result<()>
{
    let path_cstring = CString::new(path.as_ref().as_os_str().as_bytes()).unwrap();
    let tmp_times = [
       libc::timeval {
           tv_sec: times.atime.sec as libc::time_t,
           tv_usec: times.atime.usec as libc::suseconds_t,
       },
       libc::timeval {
           tv_sec: times.mtime.sec as libc::time_t,
           tv_usec: times.mtime.usec as libc::suseconds_t,
       }
    ];
    let res = unsafe { libc::utimes(path_cstring.as_ptr(), &tmp_times as *const libc::timeval) };
    if res != -1 {
        Ok(())
    } else {
        Err(Error::last_os_error())
    }    
}

pub fn umask(mask: u32) -> u32 
{ unsafe { libc::umask(mask as libc::mode_t) as u32 } }

pub fn dup2(old_fd: i32, new_fd: i32) -> Result<()>
{
    let res = unsafe { libc::dup2(old_fd, new_fd) };
    if res != -1 {
        Ok(())
    } else {
        Err(Error::last_os_error())
    }
}

pub fn close(fd: i32) -> Result<()>
{
    let res = unsafe { libc::close(fd) };
    if res != -1 {
        Ok(())
    } else {
        Err(Error::last_os_error())
    }
}

pub fn isatty(fd: i32) -> Result<bool>
{
    let res = unsafe { libc::isatty(fd) };
    if res != -1 {
        Ok(res != 0)
    } else {
        Err(Error::last_os_error())
    }    
}

pub fn kill(pid: i32, sig: i32) -> Result<()>
{
    let res = unsafe { libc::kill(pid, sig) };
    if res != -1 {
        Ok(())
    } else {
        Err(Error::last_os_error())
    }
}

pub fn getgroups() -> Result<Vec<gid_t>>
{
    let mut groups = vec![0; 1024];
    let mut res = unsafe { libc::getgroups(1024, groups.as_mut_ptr()) };
    if res == -1 {
        let err = Error::last_os_error();
        if err.kind() == ErrorKind::InvalidInput {
            res = unsafe { libc::getgroups(0, groups.as_mut_ptr()) };
            if res == -1 {
                return Err(Error::last_os_error());
            }
            let size = res;
            groups.resize(size as usize, 0 as gid_t);
            res = unsafe { libc::getgroups(size, groups.as_mut_ptr()) };
            if res == -1 {
                return Err(Error::last_os_error());
            }
        } else {
            return Err(err);
        }
    }
    groups.resize(res as usize, 0 as gid_t);
    Ok(groups)
}

pub fn getgrouplist<S: AsRef<OsStr>>(user: S, group: gid_t) -> Option<Vec<gid_t>>
{
    let mut groups = vec![0; 1024];
    let mut size = 1024;
    let user_cstring = CString::new(user.as_ref().as_bytes()).unwrap();
    let mut res = unsafe { libc::getgrouplist(user_cstring.as_ptr(), group, groups.as_mut_ptr(), &mut size as *mut i32) };
    if res == -1 {
        groups.resize(size as usize, 0 as gid_t); 
        res = unsafe { libc::getgrouplist(user_cstring.as_ptr(), group, groups.as_mut_ptr(), &mut size as *mut i32) };
        if res == -1 {
            return None;
        }
    }
    groups.resize(size as usize, 0 as gid_t);
    Some(groups)
}

fn libc_tm_to_tm(libc_tm: &libc::tm) -> Tm
{
    let zone = if !libc_tm.tm_zone.is_null() {
        let zone_cstr = unsafe { CStr::from_ptr(libc_tm.tm_zone) };
        Some(CString::new(zone_cstr.to_bytes()).unwrap())
    } else {
        None
    };
    Tm {
        sec: libc_tm.tm_sec,
        min: libc_tm.tm_min,
        hour: libc_tm.tm_hour,
        mday: libc_tm.tm_mday,
        mon: libc_tm.tm_mon,
        year: libc_tm.tm_year,
        wday: libc_tm.tm_wday,
        yday: libc_tm.tm_yday,
        isdst: libc_tm.tm_isdst,
        gmtoff: libc_tm.tm_gmtoff as i64,
        zone,
    }
}

fn tm_to_libc_tm(tm: &Tm) -> libc::tm
{
    let zone = tm.zone.as_ref().map_or(null(), |z| z.as_ptr());
    libc::tm {
        tm_sec: tm.sec,
        tm_min: tm.min,
        tm_hour: tm.hour,
        tm_mday: tm.mday,
        tm_mon: tm.mon,
        tm_year: tm.year,
        tm_wday: tm.wday,
        tm_yday: tm.yday,
        tm_isdst: tm.isdst,
        tm_gmtoff: tm.gmtoff as libc::c_long,
        tm_zone: zone,
    }
}

pub fn gmtime(time: i64) -> Result<Tm>
{
    let mut libc_tm: libc::tm = unsafe { MaybeUninit::uninit().assume_init() };
    let libc_time = time as libc::time_t;
    let res = unsafe { libc::gmtime_r(&libc_time as *const libc::time_t, &mut libc_tm as *mut libc::tm) };
    if !res.is_null() {
        Ok(libc_tm_to_tm(&libc_tm))
    } else {
        Err(Error::last_os_error())
    }
}

pub fn localtime(time: i64) -> Result<Tm>
{
    let mut libc_tm: libc::tm = unsafe { MaybeUninit::uninit().assume_init() };
    let libc_time = time as libc::time_t;
    let res = unsafe { libc::localtime_r(&libc_time as *const libc::time_t, &mut libc_tm as *mut libc::tm) };
    if !res.is_null() {
        Ok(libc_tm_to_tm(&libc_tm))
    } else {
        Err(Error::last_os_error())
    }
}

pub fn mktime(tm: &mut Tm) -> Result<i64>
{
    let mut libc_tm = tm_to_libc_tm(tm);
    let res = unsafe { libc::mktime(&mut libc_tm as *mut libc::tm) };
    *tm = libc_tm_to_tm(&mut libc_tm);
    if res != -1 {
        Ok(res as i64)
    } else {
        Err(Error::last_os_error())
    }
}

pub fn month_name(month: i32) -> Option<&'static str>
{
    match month {
        0  => Some("January"),
        1  => Some("February"),
        2  => Some("March"),
        3  => Some("April"),
        4  => Some("May"),
        5  => Some("June"),
        6  => Some("July"),
        7  => Some("August"),
        8  => Some("September"),
        9  => Some("October"),
        10 => Some("November"),
        11 => Some("December"),
        _  => None,
    }
}

pub fn abbreviated_month_name(month: i32) -> Option<&'static str>
{
    match month {
        0  => Some("Jan"),
        1  => Some("Feb"),
        2  => Some("Mar"),
        3  => Some("Apr"),
        4  => Some("May"),
        5  => Some("Jun"),
        6  => Some("Jul"),
        7  => Some("Aug"),
        8  => Some("Sep"),
        9  => Some("Oct"),
        10 => Some("Nov"),
        11 => Some("Dec"),
        _  => None,
    }
}

pub fn week_day_name(week_day: i32) -> Option<&'static str>
{
    match week_day {
        0 => Some("Sunday"),
        1 => Some("Monday"),
        2 => Some("Tuesday"),
        3 => Some("Wednesday"),
        4 => Some("Thursday"),
        5 => Some("Friday"),
        6 => Some("Saturday"),
        _ => None,
    }
}

pub fn abbreviated_week_day_name(week_day: i32) -> Option<&'static str>
{
    match week_day {
        0 => Some("Sun"),
        1 => Some("Mon"),
        2 => Some("Tue"),
        3 => Some("Wed"),
        4 => Some("Thu"),
        5 => Some("Fri"),
        6 => Some("Sat"),
        _ => None,
    }
}

pub fn non_recursively_do<P: AsRef<Path>, F>(path: P, flag: DoFlag, is_err_for_not_found: bool, is_action_for_dir: bool, mut f: F) -> bool
    where F: FnMut(&Path, &fs::Metadata) -> bool
{
    let metadata = match flag {
        DoFlag::NoDereference => fs::symlink_metadata(path.as_ref()),
        DoFlag::NonRecursiveDereference | DoFlag::RecursiveDereference => fs::metadata(path.as_ref()),
    };
    match metadata {
        Ok(metadata) => {
            if is_action_for_dir || !metadata.file_type().is_dir() {
                f(path.as_ref(), &metadata)
            } else {
                eprintln!("{} is a directory", path.as_ref().to_string_lossy());
                false
            }
        },
        Err(err) => {
            if !is_err_for_not_found && err.kind() == ErrorKind::NotFound {
                true
            } else {
                eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
                false
            }
        },
    }
}

fn recursively_do_from_path_buf<F>(path_buf: &mut PathBuf, flag: DoFlag, is_err_for_not_found: bool, name: Option<&OsStr>, f: &mut F) -> bool
    where F: FnMut(&Path, &fs::Metadata, Option<&OsStr>, DoAction) -> (bool, bool)
{
    let metadata = match (flag, name) {
        (DoFlag::NoDereference, _) => fs::symlink_metadata(path_buf.as_path()),
        (DoFlag::NonRecursiveDereference, None) => fs::metadata(path_buf.as_path()),
        (DoFlag::NonRecursiveDereference, Some(_)) => fs::symlink_metadata(path_buf.as_path()),
        (DoFlag::RecursiveDereference, _) => fs::metadata(path_buf.as_path()),
    };
    match metadata {
        Ok(metadata) => {
            if !metadata.file_type().is_dir() {
                f(path_buf.as_path(), &metadata, name, DoAction::FileAction).0
            } else {
                let (mut is_success, is_descent) = f(path_buf.as_path(), &metadata, name, DoAction::DirActionBeforeList);
                if is_success && is_descent {
                    match read_dir(path_buf.as_path()) {
                        Ok(entries) => {
                            for entry in entries {
                                match entry {
                                    Ok(entry) => {
                                        path_buf.push(entry.file_name());
                                        is_success &= recursively_do_from_path_buf(path_buf, flag, true, Some(entry.file_name().as_os_str()), f);
                                        path_buf.pop();
                                    },
                                    Err(err) => {
                                        eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                                        is_success = false;
                                        break;
                                    },
                                }
                            }
                        },
                        Err(err) => {
                            eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                            is_success = false;
                        },
                    }
                    is_success &= f(path_buf, &metadata, name, DoAction::DirActionAfterList).0;
                    is_success
                } else {
                    is_success
                }
            }
        },
        Err(err) => {
            if !is_err_for_not_found && err.kind() == ErrorKind::NotFound {
                true
            } else {
                eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                false
            }
        },
    }
}

pub fn recursively_do<P: AsRef<Path>, F>(path: P, flag: DoFlag, is_err_for_not_found: bool, mut f: F) -> bool
    where F: FnMut(&Path, &fs::Metadata, Option<&OsStr>, DoAction) -> (bool, bool)
{
    let mut path_buf = path.as_ref().to_path_buf();
    recursively_do_from_path_buf(&mut path_buf, flag, is_err_for_not_found, None, &mut f)
}

fn is_dir_for_ls<P: AsRef<Path>>(path: P, flag: DoFlag, is_parent_from_dir: bool, is_success: &mut bool) -> bool
{
    let (metadata, is_symlink) = match (flag, is_parent_from_dir) {
        (DoFlag::NoDereference, _) => (fs::symlink_metadata(path.as_ref()), true),
        (DoFlag::NonRecursiveDereference, false) => (fs::metadata(path.as_ref()), false),
        (DoFlag::NonRecursiveDereference, true) => (fs::symlink_metadata(path.as_ref()), true),
        (DoFlag::RecursiveDereference, _) => (fs::metadata(path.as_ref()), false),
    };
    match metadata {
        Ok(metadata) => metadata.file_type().is_dir(),
        Err(err) if !is_symlink && (err.kind() == ErrorKind::NotFound || err.raw_os_error().map(|e| e == libc::ELOOP).unwrap_or(false)) => false,
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            *is_success = false;
            false
        },
    }
}

fn names_to_do_entries<F>(path_buf: &mut PathBuf, names: &mut [OsString], flag: DoFlag, are_sorted: bool, are_reversed: bool, are_names_from_dir: bool, f: &mut F) -> Option<Vec<DoEntry>>
    where F: FnMut(&DoEntry, &DoEntry) -> Ordering
{
    let mut entries: Vec<DoEntry> = Vec::new();
    for name in names.iter() {
        if name != &OsString::from(".") || !are_names_from_dir { path_buf.push(name); }
        let (mut metadata, is_symlink) = match (flag, are_names_from_dir) {
            (DoFlag::NoDereference, _) => (fs::symlink_metadata(path_buf.as_path()), true),
            (DoFlag::NonRecursiveDereference, false) => (fs::metadata(path_buf.as_path()), false),
            (DoFlag::NonRecursiveDereference, true) => (fs::symlink_metadata(path_buf.as_path()), true),
            (DoFlag::RecursiveDereference, _) => (fs::metadata(path_buf.as_path()), false),
        };
        metadata = match metadata {
            Ok(metadata) => Ok(metadata),
            Err(err) if !is_symlink && (err.kind() == ErrorKind::NotFound || err.raw_os_error().map(|e| e == libc::ELOOP).unwrap_or(false)) => fs::symlink_metadata(path_buf.as_path()),
            Err(err) => Err(err),
        };
        let is_success = match metadata {
            Ok(metadata) => {
                let (link, is_success) = if metadata.file_type().is_symlink() {
                    match read_link(path_buf.as_path()) {
                        Ok(path_buf) => (Some(path_buf), true),
                        Err(err)     => {
                            eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                            (None, false)
                        },
                    }
                } else {
                    (None, true)
                };
                if is_success {
                    entries.push(DoEntry { name: name.clone(), metadata, link });
                    true
                } else {
                    false
                }
            },
            Err(err) => {
                eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                false
            },
        };
        if are_names_from_dir {
            if name != &OsString::from(".")  || !are_names_from_dir { path_buf.pop(); }
        } else {
            path_buf.clear();
        }
        if !is_success {
            return None;
        }
    }
    if are_sorted { entries.sort_by(|e1, e2| f(e1, e2)); }
    if are_reversed { entries.reverse(); }
    Some(entries)
}

fn do_from_path_buf_for_ls<F, G, H>(path_buf: &mut PathBuf, file_names: &mut [OsString], dir_names: &mut [OsString], flag: DoFlag, is_recursive: bool, are_sorted: bool, are_reversed: bool, is_preceded_dir_path: bool, are_names_from_dir: bool, f: &mut F, g: &mut G, h: &mut H) -> bool
    where F: FnMut(&OsString) -> bool,
          G: FnMut(&DoEntry, &DoEntry) -> Ordering,
          H: FnMut(Option<&Path>, bool, &[DoEntry])
{
    match names_to_do_entries(path_buf, file_names, flag, are_sorted, are_reversed, are_names_from_dir, g) {
        Some(file_entries) => {
            let dir_path = if are_names_from_dir {
                Some(path_buf.as_path())
            } else {
                None
            };
            h(dir_path, is_preceded_dir_path, &file_entries);
            if is_recursive || !are_names_from_dir {
                match names_to_do_entries(path_buf, dir_names, flag, are_sorted, are_reversed, are_names_from_dir, g) {
                    Some(dir_entries) => {
                        let mut is_success = true;
                        for dir_entry in &dir_entries {
                            path_buf.push(dir_entry.name.as_os_str());
                            let mut file_names: Vec<OsString> = Vec::new();
                            let mut dir_names: Vec<OsString> = Vec::new();
                            file_names.push(OsString::from("."));
                            file_names.push(OsString::from(".."));
                            match read_dir(path_buf.as_path()) {
                                Ok(entries) => {
                                    for entry in entries {
                                        match entry {
                                            Ok(entry) => {
                                                file_names.push(entry.file_name());
                                                path_buf.push(entry.file_name());
                                                if is_dir_for_ls(path_buf.as_path(), flag, true, &mut is_success) {
                                                    dir_names.push(entry.file_name());
                                                }
                                                path_buf.pop();
                                                if !is_success { break; }
                                            },
                                            Err(err) => {
                                                eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                                                is_success = false;
                                                break;
                                            },
                                        }
                                    }
                                },
                                Err(err) => {
                                    eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                                    is_success = false;
                                },
                            }
                            if is_success {
                                let mut file_names: Vec<OsString> = file_names.iter().filter(|n| f(n)).map(|n| n.clone()).collect();
                                let mut dir_names: Vec<OsString> = dir_names.iter().filter(|n| f(n)).map(|n| n.clone()).collect();
                                let is_preceded_dir_path = is_recursive || dir_entries.len() > 1 || !file_entries.is_empty();
                                is_success = do_from_path_buf_for_ls(path_buf, &mut file_names, &mut dir_names, flag, is_recursive, are_sorted, are_reversed, is_preceded_dir_path, true, f, g, h);
                            }
                            if are_names_from_dir {
                                path_buf.pop();
                            } else {
                                path_buf.clear();
                            }
                        }
                        is_success
                    },
                    None => false,
                }
            } else {
                true
            }
        },
        None => false,
    }
}

pub fn do_for_ls<F, G, H>(names: &[OsString], flag: DoFlag, is_recursive: bool, are_sorted: bool, are_reversed: bool, are_dirs_as_files: bool, mut f: F, mut g: G, mut h: H) -> bool
    where F: FnMut(&OsString) -> bool,
          G: FnMut(&DoEntry, &DoEntry) -> Ordering,
          H: FnMut(Option<&Path>, bool, &[DoEntry])
{
    let mut file_names: Vec<OsString> = Vec::new();
    let mut dir_names: Vec<OsString> = Vec::new();
    let mut is_success = true;
    for name in names.iter() {
        if !are_dirs_as_files {
            if is_dir_for_ls(name, flag, false, &mut is_success) {
                dir_names.push(name.clone());
            } else {
                if is_success {
                    file_names.push(name.clone());
                } else {
                    break;
                }
            }
        } else {
            file_names.push(name.clone());
        }
    }
    if is_success {
        let mut path_buf = PathBuf::new();
        is_success = do_from_path_buf_for_ls(&mut path_buf, &mut file_names, &mut dir_names, flag, is_recursive, are_sorted, are_reversed, false, false, &mut f, &mut g, &mut h);
    }
    is_success
}

pub fn get_dest_path_and_dir_flag<'a>(paths: &mut Vec<&'a String>) -> Option<(&'a String, bool)>
{
    if paths.len() >= 2 {
         match paths.pop() {
             Some(dst_path) => {
                 let metadata = fs::metadata(dst_path);
                 match metadata {
                     Ok(metadata) => {
                         if paths.len() == 1 {
                             Some((dst_path, metadata.file_type().is_dir()))
                         } else {
                             if metadata.file_type().is_dir() {
                                 Some((dst_path, true))
                             } else {
                                 eprintln!("{} isn't a directory", dst_path);
                                 None
                             }
                         }
                     },
                     Err(err) if err.kind() == ErrorKind::NotFound => {
                         if paths.len() == 1 {
                             Some((dst_path, false))
                         } else {
                             eprintln!("{} isn't a directory", dst_path);
                             None
                         }
                     },
                     Err(err) => {
                        eprintln!("{}: {}", dst_path, err);
                        None
                     },
                 }
             },
             None => {
                 eprintln!("Too few arguments");
                 None
             },
         }
    } else {
        eprintln!("Too few arguments");
        None
    }
}

pub fn ask_for_path<P: AsRef<Path>>(s: &str, path: P) -> bool
{
    loop {
        eprint!("{} {}? ", s, path.as_ref().to_string_lossy());
        match stderr().flush() {
            Ok(()) => {
                let mut line = String::new();
                match stdin().read_line(&mut line) {
                    Ok(_)    => {
                        break line.trim().to_lowercase() == String::from("yes") || line.trim().to_lowercase() == String::from("y");
                    },
                    Err(err) => eprintln!("{}", err),
                }
            },
            Err(err) => eprintln!("{}", err),
        }
    }
}

pub fn str_without_newline(s: &str) -> &str
{
    if s.ends_with('\n') {
        &s[0..(s.len() - 1)]
    } else {
        s
    }
}
