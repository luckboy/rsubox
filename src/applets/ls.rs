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
use std::cmp::Ordering;
use std::cmp::max;
use std::ffi::*;
use std::fs;
use std::mem::MaybeUninit;
use std::os::unix::fs::FileTypeExt;
use std::os::unix::fs::MetadataExt;
use std::os::unix::fs::PermissionsExt;
use std::path::*;
use std::time::SystemTime;
use getopt::Opt;
use users::get_user_by_uid;
use users::get_group_by_gid;
use libc;
use crate::utils::*;

#[derive(PartialEq)]
enum MultiColumnFlag
{
    None,
    UpToDown,
    LeftToRight,
}

enum TimeFlag
{
    LastAccess,
    LastDataModification,
    LastModification,
}

enum IndicatorFlag
{
    None,
    All,
    OnlyDirectory,
}

enum FormatFlag
{
    Short,
    Long,
    Comma,
}

struct Options
{
    multi_column_flag: MultiColumnFlag,
    all_flag: bool,
    time_flag: TimeFlag,
    directory_flag: bool,
    indicator_flag: IndicatorFlag,
    force_flag: bool,
    no_owner_flag: bool,
    inode_flag: bool,
    format_flag: FormatFlag,
    numeric_id_flag: bool,
    no_group_flag: bool,
    control_char_flag: bool,
    recursive_flag: bool,
    reverse_flag: bool,
    size_flag: bool,
    sorting_by_time_flag: bool,
    do_flag: DoFlag,
}

struct ShortFormatEntry
{
    inode: Option<String>,
    blocks: Option<String>,
    name: String,
}

struct ShortFormatMaxLengths
{
    max_inode_len: Option<usize>,
    max_blocks_len: Option<usize>,
    max_name_len: usize,
}

struct LongFormatEntry
{
    inode: Option<String>,
    blocks: Option<String>,
    mode: String,
    nlink: String,
    owner: Option<String>,
    group: Option<String>,
    size: String,
    time: String,
    name: String,
    link: Option<String>,
}

struct LongFormatMaxLengths
{
    max_inode_len: Option<usize>,
    max_blocks_len: Option<usize>,
    max_mode_len: usize,
    max_nlink_len: usize,
    max_owner_len: Option<usize>,
    max_group_len: Option<usize>,
    max_size_len: usize,
    max_time_len: usize,
    max_name_len: usize,
    max_link_len: Option<usize>,
}

fn replace_control_chars_for_flag(s: &String, opts: &Options) -> String
{
    if opts.control_char_flag {
        s.replace(|c: char| { c.is_control() || c == '\t' }, "?")
    } else {
        s.clone()
    }
}

fn path_to_string<P: AsRef<Path>>(path: P, opts: &Options) -> String
{ replace_control_chars_for_flag(&path.as_ref().to_string_lossy().into_owned(), opts) }

fn name_to_string<S: AsRef<OsStr>>(name: S, opts: &Options) -> String
{ replace_control_chars_for_flag(&name.as_ref().to_string_lossy().into_owned(), opts) }

fn all_filter(_name: &OsString) -> bool
{ true }

fn filter(name: &OsString) -> bool
{ !name.to_string_lossy().starts_with('.') }

fn compare_names(entry1: &DoEntry, entry2: &DoEntry) -> Ordering
{ entry1.name.cmp(&entry2.name) }

fn compare_last_access_times(entry1: &DoEntry, entry2: &DoEntry) -> Ordering
{
    match entry1.metadata.atime().cmp(&entry2.metadata.atime()) {
        Ordering::Less    => Ordering::Greater,
        Ordering::Equal   => {
            match entry1.metadata.atime_nsec().cmp(&entry2.metadata.atime_nsec()) {
                Ordering::Less    => Ordering::Greater,
                Ordering::Equal   => Ordering::Equal,
                Ordering::Greater => Ordering::Less,
            }
        },
        Ordering::Greater => Ordering::Less,
    }
}

fn compare_last_data_modification_times(entry1: &DoEntry, entry2: &DoEntry) -> Ordering
{
    match entry1.metadata.mtime().cmp(&entry2.metadata.mtime()) {
        Ordering::Less    => Ordering::Greater,
        Ordering::Equal   => {
            match entry1.metadata.mtime_nsec().cmp(&entry2.metadata.mtime_nsec()) {
                Ordering::Less    => Ordering::Greater,
                Ordering::Equal   => Ordering::Equal,
                Ordering::Greater => Ordering::Less,
            }
        },
        Ordering::Greater => Ordering::Less,
    }
}

fn compare_last_modification_times(entry1: &DoEntry, entry2: &DoEntry) -> Ordering
{
    match entry1.metadata.ctime().cmp(&entry2.metadata.ctime()) {
        Ordering::Less    => Ordering::Greater,
        Ordering::Equal   => {
            match entry1.metadata.ctime_nsec().cmp(&entry2.metadata.ctime_nsec()) {
                Ordering::Less    => Ordering::Greater,
                Ordering::Equal   => Ordering::Equal,
                Ordering::Greater => Ordering::Less,
            }
        },
        Ordering::Greater => Ordering::Less,
    }
}

fn calculate_blocks(entries: &[DoEntry]) -> u64
{ entries.iter().map(|e| e.metadata.blocks()).sum() }

fn print_left_aligned_string(s: &String, width: usize)
{ print!("{:<1$}", s, width); }

fn print_right_aligned_string(s: &String, width: usize)
{ print!("{:>1$}", s, width); }

fn print_left_aligned_string_opt(s: &Option<String>, width: Option<usize>)
{ 
    match s {
        Some(s) => print!("{:<1$}", s, width.unwrap_or(0)),
        None    => print!("{:<1$}", "", width.unwrap_or(0)),
    }
}

fn print_right_aligned_string_opt(s: &Option<String>, width: Option<usize>)
{ 
    match s {
        Some(s) => print!("{:>1$}", s, width.unwrap_or(0)),
        None    => print!("{:>1$}", "", width.unwrap_or(0)),
    }
}

fn format_name(entry: &DoEntry, opts: &Options) -> String
{
    let mut s = name_to_string(&entry.name, &opts);
    match opts.indicator_flag {
        IndicatorFlag::None => (),
        IndicatorFlag::All => {
            if entry.metadata.file_type().is_dir() {
                s.push('/');
            } else if entry.metadata.file_type().is_fifo() {
                s.push('|');
            } else if entry.metadata.file_type().is_symlink() {
                s.push('@');
            } else if (entry.metadata.permissions().mode() & 0o111) != 0 {
                s.push('*');
            }
        },
        IndicatorFlag::OnlyDirectory => {
            if entry.metadata.file_type().is_dir() {
                s.push('/');
            }
        },
    }
    s
}

fn format_mode(metadata: &fs::Metadata) -> String
{
    let mut s = String::new();
    if metadata.file_type().is_file() {
        s.push('-');
    } else if metadata.file_type().is_dir() {
        s.push('d');
    } else if metadata.file_type().is_symlink() {
        s.push('l');
    } else if metadata.file_type().is_block_device() {
        s.push('b');
    } else if metadata.file_type().is_char_device() {
        s.push('c');
    } else if metadata.file_type().is_fifo() {
        s.push('p');
    } else if metadata.file_type().is_socket() {
        s.push('s');
    } else {
        s.push('?');
    }
    if (metadata.permissions().mode() & 0o400) != 0 {
        s.push('r');
    } else {
        s.push('-');
    }
    if (metadata.permissions().mode() & 0o200) != 0 {
        s.push('w');
    } else {
        s.push('-');
    }
    if (metadata.permissions().mode() & 0o100) != 0 {
        if (metadata.permissions().mode() & 0o4000) != 0 {
            s.push('s');
        } else {
            s.push('x');
        }
    } else {
        if (metadata.permissions().mode() & 0o4000) != 0 {
            s.push('S');
        } else {
            s.push('-');
        }
    }
    if (metadata.permissions().mode() & 0o40) != 0 {
        s.push('r');
    } else {
        s.push('-');
    }
    if (metadata.permissions().mode() & 0o20) != 0 {
        s.push('w');
    } else {
        s.push('-');
    }
    if (metadata.permissions().mode() & 0o10) != 0 {
        if (metadata.permissions().mode() & 0o2000) != 0 {
            s.push('s');
        } else {
            s.push('x');
        }
    } else {
        if (metadata.permissions().mode() & 0o2000) != 0 {
            s.push('S');
        } else {
            s.push('-');
        }
    }
    if (metadata.permissions().mode() & 0o4) != 0 {
        s.push('r');
    } else {
        s.push('-');
    }
    if (metadata.permissions().mode() & 0o2) != 0 {
        s.push('w');
    } else {
        s.push('-');
    }
    if (metadata.permissions().mode() & 0o1) != 0 {
        if (metadata.permissions().mode() & 0o1000) != 0 {
            s.push('t');
        } else {
            s.push('x');
        }
    } else {
        if (metadata.permissions().mode() & 0o1000) != 0 {
            s.push('T');
        } else {
            s.push('-');
        }
    }
    s
}

fn format_owner(uid: uid_t, opts: &Options) -> String
{
   if !opts.numeric_id_flag {
       match get_user_by_uid(uid) {
           Some(user) => user.name().to_string_lossy().into_owned(),
           None       => format!("{}", uid),
       }
   } else {
       format!("{}", uid)
   }
}

fn format_group(gid: gid_t, opts: &Options) -> String
{
   if !opts.numeric_id_flag {
       match get_group_by_gid(gid) {
           Some(group) => group.name().to_string_lossy().into_owned(),
           None        => format!("{}", gid),
       }
   } else {
       format!("{}", gid)
   }
}

fn format_time(time: i64, current_tm: &Tm) -> String
{
    match localtime(time) {
        Ok(tm) => {
            let mut s = String::new();
            s.push_str(format!("{} {:2} ", abbreviated_month_name(tm.mon).unwrap_or("Unk"), tm.mday).as_str());
            let diff = (current_tm.year - tm.year) * 12 + current_tm.mon - tm.mon;
            if  diff > 6 || diff < -6 {
                s.push_str(format!("{:5}", tm.year + 1900).as_str());
            } else {
                s.push_str(format!("{:02}:{:02}", tm.hour, tm.min).as_str());
            }
            s
        },
        Err(_) => {
            format!("{}", time)
        },
    }
}

fn format_link(link: &Option<PathBuf>, opts: &Options) -> Option<String>
{
    match link {
        Some(path_buf) => Some(path_to_string(path_buf.as_path(), opts)),
        None           => None,
    }
}

fn entries_to_short_format_entries(entries: &[DoEntry], opts: &Options) -> Vec<ShortFormatEntry>
{
    entries.iter().map(|entry| {
            let inode = if opts.inode_flag {
                Some(format!("{}", entry.metadata.ino()))
            } else {
                None
            };
            let blocks = if opts.size_flag {
                Some(format!("{}", entry.metadata.blocks()))
            } else {
                None
            };
            let name = format_name(entry, opts);
            ShortFormatEntry {
                inode,
                blocks,
                name,
            }
    }).collect()
}

fn calculate_short_format_max_lens(format_entries: &[ShortFormatEntry]) -> ShortFormatMaxLengths
{
    let mut max_lens = ShortFormatMaxLengths {
        max_inode_len: None,
        max_blocks_len: None,
        max_name_len: 0,
    };
    for format_entry in format_entries.iter() {
        match &format_entry.inode {
            Some(s) => max_lens.max_inode_len = Some(max(max_lens.max_inode_len.unwrap_or(0), s.as_str().chars().fold(0, |x, _| x + 1))),
            None    => (),
        }
        match &format_entry.blocks {
            Some(s) => max_lens.max_blocks_len = Some(max(max_lens.max_blocks_len.unwrap_or(0), s.as_str().chars().fold(0, |x, _| x + 1))),
            None    => (),
        }
        max_lens.max_name_len = max(max_lens.max_name_len, format_entry.name.as_str().chars().fold(0, |x, _| x + 1 ));
    }
    max_lens
}

fn calculate_short_format_max_all_len(max_lens: &ShortFormatMaxLengths) -> usize
{ max_lens.max_inode_len.map(|n| n + 1).unwrap_or(0) + max_lens.max_blocks_len.map(|n| n + 1).unwrap_or(0) + max_lens.max_name_len }

fn calculate_short_format_column_count(max_all_len: usize, column_count: usize) -> usize
{
    let format_column_count = column_count / (max_all_len + 1);
    if format_column_count > 0 {
        format_column_count
    } else {
        1
    }
}

fn print_short_format_entry(format_entry: &ShortFormatEntry, max_lens: &ShortFormatMaxLengths)
{
    print_right_aligned_string_opt(&format_entry.inode, max_lens.max_inode_len);
    if max_lens.max_inode_len.is_some() { print!(" "); }
    print_right_aligned_string_opt(&format_entry.blocks, max_lens.max_blocks_len);
    if max_lens.max_blocks_len.is_some() { print!(" "); }
    print!("{}", format_entry.name);
}

fn print_short_format_entry_for_multi_columns(format_entry: &ShortFormatEntry, max_lens: &ShortFormatMaxLengths, max_all_len: usize, are_spaces: bool)
{
    print_short_format_entry(format_entry, max_lens);
    if are_spaces {
        let mut all_len = 0;
        all_len += max_lens.max_inode_len.map(|l| l + 1).unwrap_or(0);
        all_len += max_lens.max_blocks_len.map(|l| l + 1).unwrap_or(0);
        all_len += format_entry.name.as_str().chars().fold(0, |x, _| x + 1);
        let filled_space_count = (max_all_len + 1) - all_len;
        if filled_space_count > 0 {
            for _ in 0..filled_space_count {
                print!(" ");
            }
        }
    }
}

fn print_short_format_entries_for_none(format_entries: &[ShortFormatEntry], max_lens: &ShortFormatMaxLengths)
{
    for format_entry in format_entries.iter() {
        print_short_format_entry(format_entry, max_lens);
        println!("");
    }
}

fn print_short_format_entries_for_up_to_down(format_entries: &[ShortFormatEntry], max_lens: &ShortFormatMaxLengths, max_all_len: usize, format_column_count: usize)
{
    let format_row_count = (format_entries.len() + (format_column_count - 1)) / format_column_count;
    let mut space_tab = vec![false; format_column_count * format_row_count];
    for i in 0..format_row_count {
        for j in 0..format_column_count {
            match format_entries.get(j * format_row_count + i) {
                Some(_) => {
                    if j > 0 {
                        space_tab[(j - 1) * format_row_count + i] = true;
                    }
                },
                None => (),
            }
        }
    }    
    for i in 0..format_row_count {
        for j in 0..format_column_count {
            match format_entries.get(j * format_row_count + i) {
                Some(format_entry) => print_short_format_entry_for_multi_columns(&format_entry, max_lens, max_all_len, j + 1 < format_column_count && space_tab[j * format_row_count + i]),
                None => (),
            }
        }
        println!("");
    }
}

fn print_short_format_entries_for_left_to_right(format_entries: &[ShortFormatEntry], max_lens: &ShortFormatMaxLengths, max_all_len: usize, format_column_count: usize)
{
    let format_row_count = (format_entries.len() + (format_column_count - 1)) / format_column_count;
    let mut space_tab = vec![false; format_column_count * format_row_count];
    for i in 0..format_row_count {
        for j in 0..format_column_count {
            match format_entries.get(i * format_column_count + j) {
                Some(_) => {
                    if j > 0 {
                        space_tab[i * format_column_count + (j - 1)] = true;
                    }
                },
                None => (),
            }
        }
    }    
    for i in 0..format_row_count {
        for j in 0..format_column_count {
            match format_entries.get(i * format_column_count + j) {
                Some(format_entry) => print_short_format_entry_for_multi_columns(&format_entry, max_lens, max_all_len, j + 1 < format_column_count  && space_tab[i * format_column_count + j]),
                None => (),
            }
        }
        println!("");
    }
}

fn print_short_format_entries(format_entries: &[ShortFormatEntry], max_lens: &ShortFormatMaxLengths, opts: &Options, column_count: usize)
{
    match opts.multi_column_flag {
        MultiColumnFlag::None => print_short_format_entries_for_none(format_entries, max_lens),
        MultiColumnFlag::UpToDown => {
            let max_all_len = calculate_short_format_max_all_len(max_lens);
            let format_column_count = calculate_short_format_column_count(max_all_len, column_count);
            print_short_format_entries_for_up_to_down(format_entries, max_lens, max_all_len, format_column_count);
        },
        MultiColumnFlag::LeftToRight => {
            let max_all_len = calculate_short_format_max_all_len(max_lens);
            let format_column_count = calculate_short_format_column_count(max_all_len, column_count);
            print_short_format_entries_for_left_to_right(format_entries, max_lens, max_all_len, format_column_count);
        },
    }
}

fn entries_to_long_format_entries(entries: &[DoEntry], opts: &Options, current_tm: &Tm) -> Vec<LongFormatEntry>
{
    entries.iter().map(|entry| {
            let inode = if opts.inode_flag {
                Some(format!("{}", entry.metadata.ino()))
            } else {
                None
            };
            let blocks = if opts.size_flag {
                Some(format!("{}", entry.metadata.blocks()))
            } else {
                None
            };
            let mode = format_mode(&entry.metadata);
            let nlink = format!("{}", entry.metadata.nlink());
            let owner = if !opts.no_owner_flag {
                Some(format_owner(entry.metadata.uid() as uid_t, opts))
            } else {
                None
            };
            let group = if !opts.no_group_flag {
                Some(format_group(entry.metadata.gid() as gid_t, opts))
            } else {
                None
            };
            let size = if entry.metadata.file_type().is_block_device() || entry.metadata.file_type().is_char_device() {
               format!("{}, {}", major(entry.metadata.rdev()), minor(entry.metadata.rdev()))
            }  else {
               format!("{}", entry.metadata.size())
            };
            let time_sec = match opts.time_flag {
                TimeFlag::LastAccess           => entry.metadata.atime(),
                TimeFlag::LastDataModification => entry.metadata.mtime(),
                TimeFlag::LastModification     => entry.metadata.ctime(),
            };
            let time = format_time(time_sec, current_tm);
            let name = format_name(entry, opts);
            let link = format_link(&entry.link, opts); 
            LongFormatEntry {
                inode,
                blocks,
                mode,
                nlink,
                owner,
                group,
                size,
                time,
                name,
                link,
            }
    }).collect()
}

fn calculate_long_format_max_lens(format_entries: &[LongFormatEntry]) -> LongFormatMaxLengths
{
    let mut max_lens = LongFormatMaxLengths {
        max_inode_len: None,
        max_blocks_len: None,
        max_mode_len: 0,
        max_nlink_len: 0,
        max_owner_len: None,
        max_group_len: None,
        max_size_len: 0,
        max_time_len: 0,
        max_name_len: 0,
        max_link_len: None,
    };
    for format_entry in format_entries.iter() {
        match &format_entry.inode {
            Some(s) => max_lens.max_inode_len = Some(max(max_lens.max_inode_len.unwrap_or(0), s.as_str().chars().fold(0, |x, _| x + 1))),
            None    => (),
        }
        match &format_entry.blocks {
            Some(s) => max_lens.max_blocks_len = Some(max(max_lens.max_blocks_len.unwrap_or(0), s.as_str().chars().fold(0, |x, _| x + 1))),
            None    => (),
        }
        max_lens.max_mode_len = max(max_lens.max_mode_len, format_entry.mode.as_str().chars().fold(0, |x, _| x + 1 ));
        max_lens.max_nlink_len = max(max_lens.max_nlink_len, format_entry.nlink.as_str().chars().fold(0, |x, _| x + 1 ));
        match &format_entry.owner {
            Some(s) => max_lens.max_owner_len = Some(max(max_lens.max_owner_len.unwrap_or(0), s.as_str().chars().fold(0, |x, _| x + 1))),
            None    => (),
        }
        match &format_entry.group {
            Some(s) => max_lens.max_group_len = Some(max(max_lens.max_group_len.unwrap_or(0), s.as_str().chars().fold(0, |x, _| x + 1))),
            None    => (),
        }
        max_lens.max_size_len = max(max_lens.max_size_len, format_entry.size.as_str().chars().fold(0, |x, _| x + 1 ));
        max_lens.max_time_len = max(max_lens.max_time_len, format_entry.time.as_str().chars().fold(0, |x, _| x + 1 ));
        max_lens.max_name_len = max(max_lens.max_name_len, format_entry.name.as_str().chars().fold(0, |x, _| x + 1 ));
        match &format_entry.link {
            Some(s) => max_lens.max_link_len = Some(max(max_lens.max_link_len.unwrap_or(0), s.as_str().chars().fold(0, |x, _| x + 1 ))),
            None    => (),
        }
    }
    max_lens
}

fn print_long_format_entries(format_entries: &[LongFormatEntry], max_lens: &LongFormatMaxLengths)
{
    for format_entry in format_entries.iter() {
        print_right_aligned_string_opt(&format_entry.inode, max_lens.max_inode_len);
        if max_lens.max_inode_len.is_some() { print!(" "); }
        print_right_aligned_string_opt(&format_entry.blocks, max_lens.max_blocks_len);
        if max_lens.max_blocks_len.is_some() { print!(" "); }
        print_left_aligned_string(&format_entry.mode, max_lens.max_mode_len);
        print!(" ");
        print_right_aligned_string(&format_entry.nlink, max_lens.max_nlink_len);
        print!(" ");
        print_left_aligned_string_opt(&format_entry.owner, max_lens.max_owner_len);
        if max_lens.max_owner_len.is_some() { print!(" "); }
        print_left_aligned_string_opt(&format_entry.group, max_lens.max_group_len);
        if max_lens.max_group_len.is_some() { print!(" "); }
        print_right_aligned_string(&format_entry.size, max_lens.max_size_len);
        print!(" ");
        print_right_aligned_string(&format_entry.time, max_lens.max_time_len);
        print!(" ");
        print!("{}", format_entry.name);
        match &format_entry.link {
            Some(link) => print!(" -> {}", link),
            None       => (),
        }
        println!("");
    }
}

fn print_short_format_entries_for_comma_format(format_entries: &[ShortFormatEntry], column_count: usize)
{
    let mut line_len = 0;
    let mut is_first_in_line = true;
    for (i, format_entry) in format_entries.iter().enumerate() {
        let mut all_len = 0;
        match &format_entry.inode {
            Some(s) => all_len += s.as_str().chars().fold(0, |x, _| x + 1) + 1,
            None    => (),
        }
        match &format_entry.blocks {
            Some(s) => all_len += s.as_str().chars().fold(0, |x, _| x + 1) + 1,
            None    => (),
        }
        all_len += format_entry.name.as_str().chars().fold(0, |x, _| x + 1);
        if !is_first_in_line && line_len + (all_len + 1 + (if !is_first_in_line { 1 } else { 0 })) > column_count {
            println!("");
            line_len = all_len + 1;
            is_first_in_line = false;
        } else {
            if !is_first_in_line { print!(" "); }
            line_len += all_len + 1 + (if !is_first_in_line { 1 } else { 0 });
            is_first_in_line = false;
        }
        match &format_entry.inode {
            Some(s) => print!("{} ", s),
            None    => (),
        }
        match &format_entry.blocks {
            Some(s) => print!("{} ", s),
            None    => (),
        }
        print!("{}", format_entry.name);
        if i + 1 < format_entries.len() {
            print!(",");
        }
    }
    println!("");
}

fn ls_files(is_dir_path: bool, entries: &[DoEntry], opts: &Options, current_tm: &Tm, column_count: usize)
{
    match opts.format_flag {
        FormatFlag::Short => {
            let format_entries = entries_to_short_format_entries(entries, opts);
            let max_lens = calculate_short_format_max_lens(&format_entries);
            print_short_format_entries(&format_entries, &max_lens, opts, column_count);
        },
        FormatFlag::Long => {
            if is_dir_path {
                println!("total {}", calculate_blocks(entries));
            }
            let format_entries = entries_to_long_format_entries(entries, opts, current_tm);
            let max_lens = calculate_long_format_max_lens(&format_entries);
            print_long_format_entries(&format_entries, &max_lens);
        },
        FormatFlag::Comma => {
            let format_entries = entries_to_short_format_entries(entries, opts);
            print_short_format_entries_for_comma_format(&format_entries, column_count);
        },
    }
}

fn get_column_count() -> usize
{
    let mut size: libc::winsize = unsafe { MaybeUninit::uninit().assume_init() };
    let res = unsafe { libc::ioctl(1, libc::TIOCGWINSZ, &mut size as *mut libc::winsize) };
    if res != -1 {
        size.ws_col as usize
    } else {
        80
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "1aCcdFfgHiLlmnopqRrstux");
    let mut opts = Options {
        multi_column_flag: MultiColumnFlag::None,
        all_flag: false,
        time_flag: TimeFlag::LastDataModification,
        directory_flag: false,
        indicator_flag: IndicatorFlag::None,
        force_flag: false,
        no_owner_flag: false,
        inode_flag: false,
        format_flag: FormatFlag::Short,
        numeric_id_flag: false,
        no_group_flag: false,
        control_char_flag: false,
        recursive_flag: false,
        reverse_flag: false,
        size_flag: false,
        sorting_by_time_flag: false,
        do_flag: DoFlag::NoDereference,
    };
    let mut is_default_multi_column_flag = true;
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('1', _))) => {
                opts.multi_column_flag = MultiColumnFlag::None;
                is_default_multi_column_flag = false;
            },
            Some(Ok(Opt('a', _))) => opts.all_flag = true,
            Some(Ok(Opt('C', _))) => {
                opts.multi_column_flag = MultiColumnFlag::UpToDown;
                is_default_multi_column_flag = false;
            },
            Some(Ok(Opt('c', _))) => opts.time_flag = TimeFlag::LastModification,
            Some(Ok(Opt('d', _))) => opts.directory_flag = true,
            Some(Ok(Opt('F', _))) => opts.indicator_flag = IndicatorFlag::All,
            Some(Ok(Opt('f', _))) => opts.force_flag = true,
            Some(Ok(Opt('g', _))) => {
                opts.format_flag = FormatFlag::Long;
                opts.no_owner_flag = true;
            },
            Some(Ok(Opt('H', _))) => opts.do_flag = DoFlag::NonRecursiveDereference,
            Some(Ok(Opt('i', _))) => opts.inode_flag = true,
            Some(Ok(Opt('L', _))) => opts.do_flag = DoFlag::RecursiveDereference,
            Some(Ok(Opt('l', _))) => opts.format_flag = FormatFlag::Long,
            Some(Ok(Opt('m', _))) => opts.format_flag = FormatFlag::Comma,
            Some(Ok(Opt('n', _))) => opts.numeric_id_flag = true,
            Some(Ok(Opt('o', _))) => {
                opts.format_flag = FormatFlag::Long;
                opts.no_group_flag = true;
            },
            Some(Ok(Opt('p', _))) => opts.indicator_flag = IndicatorFlag::OnlyDirectory,
            Some(Ok(Opt('q', _))) => opts.control_char_flag = true,
            Some(Ok(Opt('R', _))) => opts.recursive_flag = true,
            Some(Ok(Opt('r', _))) => opts.reverse_flag = true,
            Some(Ok(Opt('s', _))) => opts.size_flag = true,
            Some(Ok(Opt('t', _))) => opts.sorting_by_time_flag = true,
            Some(Ok(Opt('u', _))) => opts.time_flag = TimeFlag::LastAccess,
            Some(Ok(Opt('x', _))) => {
                opts.multi_column_flag = MultiColumnFlag::LeftToRight;
                is_default_multi_column_flag = false;
            },
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
    if opts.force_flag {
        opts.all_flag = true;
        opts.format_flag = FormatFlag::Short;
        opts.sorting_by_time_flag = false;
        opts.reverse_flag = false;
        opts.size_flag = false;
    }
    if opts.multi_column_flag == MultiColumnFlag::None && is_default_multi_column_flag {
        match isatty(1) {
            Ok(true) => opts.multi_column_flag = MultiColumnFlag::UpToDown,
            _        => (),
        }
    }
    let column_count = get_column_count();
    let now = match SystemTime::now().duration_since(SystemTime::UNIX_EPOCH) {
        Ok(duration) => duration.as_secs() as i64,
        Err(_)       => 0,
    };
    let current_tm = localtime(now).unwrap();
    let mut names: Vec<OsString> = args.iter().skip(opt_parser.index()).map(|a| OsString::from(a)).collect();
    if names.is_empty() {
        names.push(OsString::from("."))
    }
    let mut is_preceded_newline = false;
    let is_preceded_newline_r = &mut is_preceded_newline;
    let mut f: fn(&OsString) -> bool = filter;
    if opts.all_flag {
        f = all_filter;
    }
    let mut g: fn(&DoEntry, &DoEntry) -> Ordering = compare_names;
    if opts.sorting_by_time_flag {
        g = match opts.time_flag {
            TimeFlag::LastAccess           => compare_last_access_times,
            TimeFlag::LastDataModification => compare_last_data_modification_times,
            TimeFlag::LastModification     => compare_last_modification_times,
        };
    }
    let is_success = do_for_ls(&names, opts.do_flag, opts.recursive_flag, !opts.force_flag, opts.reverse_flag, opts.directory_flag, f, g, |dir_path, is_preceded_dir_path, entries| {
            match (dir_path, is_preceded_dir_path) {
                (Some(dir_path), true) => {
                    if *is_preceded_newline_r { println!(""); }
                    println!("{}:", path_to_string(dir_path, &opts));
                },
                (_, _) => (),
            }
            if dir_path.is_some() || !entries.is_empty() {
                ls_files(dir_path.is_some(), entries, &opts, &current_tm, column_count);
                *is_preceded_newline_r = true;
            }
    });
    if is_success { 0 } else { 1 }
}
