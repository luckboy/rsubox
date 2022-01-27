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
use std::ffi::*;
use std::fs;
use std::fs::*;
use std::os::unix::ffi::OsStrExt;
use std::os::unix::fs::DirBuilderExt;
use std::os::unix::fs::FileTypeExt;
use std::os::unix::fs::MetadataExt;
use std::os::unix::fs::PermissionsExt;
use std::os::unix::fs::symlink;
use std::path;
use std::path::*;
use std::str::*;
use libc;

pub use libc::{dev_t, uid_t, gid_t};

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

#[derive(Copy, Clone)]
pub enum DoFlag
{
    NoDereference,
    NonRecursiveDereference,
    RecursiveDereference,
}

#[derive(Copy, Clone)]
pub enum  DoAction
{
    DirActionBeforeList,
    FileAction,
    DirActionAfterList,
}

pub trait PushbackIterator: Iterator
{
    fn undo(&mut self, item: Self::Item);
}

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
            }
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
    dir_builder.mode((metadata.permissions().mode() & !saved_mask) | 0700);
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

fn remove_file_and_mknod<P: AsRef<Path>>(path: P, mode: u32, dev: dev_t) -> Result<()>
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

pub fn mknod<P: AsRef<Path>>(path: P, mode: u32, dev: dev_t) -> Result<()>
{
    let path_cstring = CString::new(path.as_ref().as_os_str().as_bytes()).unwrap();
    let res = unsafe { libc::mknod(path_cstring.as_ptr(), mode, dev) };
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
    let res = unsafe { libc::chown(path_cstring.as_ptr(), uid, gid) };
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
{ unsafe { libc::umask(mask) } }

pub fn non_recursively_do<P: AsRef<Path>, F>(path: P, flag: DoFlag, f: &mut F) -> bool
  where F: FnMut(&Path, &fs::Metadata) -> bool
{
    let metadata = match flag {
        DoFlag::NoDereference => fs::symlink_metadata(path.as_ref()),
        DoFlag::NonRecursiveDereference | DoFlag::RecursiveDereference => fs::metadata(path.as_ref()),
    };
    match metadata {
        Ok(metadata) => {
            if !metadata.file_type().is_dir() {
                f(path.as_ref(), &metadata)
            } else {
                eprintln!("{} is a directory", path.as_ref().to_string_lossy());
                false
            }
        },
        Err(err) => {
            eprintln!("{}: {}", path.as_ref().to_string_lossy(), err);
            false
        },
    }
}

fn recursively_do_from_path_buf<F>(path_buf: &mut PathBuf, flag: DoFlag, name: Option<&OsStr>, f: &mut F) -> bool
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
                                        is_success &= recursively_do_from_path_buf(path_buf, flag, Some(entry.file_name().as_os_str()), f);
                                        path_buf.pop();
                                    },
                                    Err(err) => {
                                        eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
                                        is_success = false;
                                        break;
                                    }
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
            eprintln!("{}: {}", path_buf.as_path().to_string_lossy(), err);
            false
        },
    }
}

pub fn recursively_do<P: AsRef<Path>, F>(path: P, flag: DoFlag, f: &mut F) -> bool
  where F: FnMut(&Path, &fs::Metadata, Option<&OsStr>, DoAction) -> (bool, bool)
{
    let mut path_buf = path.as_ref().to_path_buf();
    recursively_do_from_path_buf(&mut path_buf, flag, None, f)
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
