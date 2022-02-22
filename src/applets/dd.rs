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
use std::io::*;
use std::fs::*;
use std::os::unix::io::FromRawFd;
use std::os::unix::io::IntoRawFd;
use std::os::unix::io::RawFd;
use std::os::unix::fs::FileTypeExt;
use std::path::*;
use libc;
use crate::utils::*;

enum FirstConversion
{
    None,
    Ascii,
}

enum SecondConversion
{
    None,
    LowerCase,
    UpperCase,
}

enum ThirdConversion
{
    None,
    Ebcdic,
    Ibm,
}

#[derive(PartialEq)]
enum BlockConversion
{
    None,
    Block,
    Unblock,
}

struct Options
{
    input_path: Option<PathBuf>,
    output_path: Option<PathBuf>,
    input_block_size: usize,
    output_block_size: usize,
    conversion_block_size: Option<usize>,
    skip: Option<u64>,
    seek: Option<u64>,
    count: Option<u64>,
    first_conversion: FirstConversion,
    second_conversion: SecondConversion,
    third_conversion: ThirdConversion,
    block_conversion: BlockConversion,
    swab_conversion: bool,
    no_error_conversion: bool,
    no_trunc_conversion: bool,
    sync_conversion: bool,
    skip_reading_conversion: bool,
    second_buffer_flag: bool,
}

struct Data
{
    first_buffer: Vec<u8>,
    second_buffer: Vec<u8>,
    full_input_block_count: u64,
    full_output_block_count: u64,
    partial_input_block_count: u64,
    partial_output_block_count: u64,
    truncated_block_count: u64,
    input_count: usize,
    output_count: usize,
    conversion_count: u64,
    newline_char: u8,
    space_char: u8,
}

static mut INTERRUPT_FLAG: bool = false;

fn check_interrupt_flag() -> bool
{ unsafe { INTERRUPT_FLAG } }

fn move_to_fd_file(file: File, new_fd: RawFd) -> Option<File>
{
    let old_fd: RawFd = file.into_raw_fd();
    let mut is_success = loop {
        match dup2(old_fd, new_fd) {
            Ok(()) => break true,
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                eprintln!("{}", err);
                break false;
            }
        }
    };
    if is_success {
        is_success = loop {
            match close(old_fd) {
                Ok(()) => break true,
                Err(err) if err.kind() == ErrorKind::Interrupted => (),
                Err(err) => {
                    eprintln!("{}", err);
                    break false;
                }
            }
        };
    }
    if is_success {
        Some(unsafe { File::from_raw_fd(new_fd) })
    } else {
        None
    }
}

fn open_file_for_dd(path: Option<&Path>) -> Option<File>
{
    match path {
        Some(path) => {
            let mut opts = OpenOptions::new();
            opts.read(true);
            let file = loop {
                if check_interrupt_flag() { break None; }
                match opts.open(path) {
                    Ok(file) => break Some(file),
                    Err(err) if err.kind() == ErrorKind::Interrupted => (),
                    Err(err) => {
                        eprintln!("{}: {}", path.to_string_lossy(), err);
                        break None;
                    },
                }
            };
            match file {
                Some(file) => move_to_fd_file(file, 0),
                None       => None,
            }
        },
        None => Some(unsafe { File::from_raw_fd(0) }),
    }
}

fn create_file_for_dd(path: Option<&Path>) -> Option<File>
{
    match path {
        Some(path) => {
            let mut opts = OpenOptions::new();
            opts.read(true).write(true).create(true);
            let file = loop {
                if check_interrupt_flag() { break None; }
                match opts.open(path) {
                    Ok(file) => break Some(file),
                    Err(err) if err.kind() == ErrorKind::Interrupted => (),
                    Err(err) => {
                        eprintln!("{}: {}", path.to_string_lossy(), err);
                        break None;
                    },
                }
            };
            match file {
                Some(file) => move_to_fd_file(file, 1),
                None       => None,
            }
        },
        None => Some(unsafe { File::from_raw_fd(1) }),
    }
}

fn read_for_dd(file: &mut File, buf: &mut [u8], path: Option<&Path>) -> (usize, bool)
{
    loop {
        if check_interrupt_flag() { break (0, false); }
        match file.read(buf) {
            Ok(0) => break (0, true),
            Ok(n) => break (n, true),
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                match path {
                    Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                    None       => eprintln!("{}", err),
                }
                break (0, false);
            },
        }
    }
}

fn write_for_dd(file: &mut File, buf: &[u8], path: Option<&Path>) -> (usize, bool)
{
    let mut count = 0;
    loop {
        if check_interrupt_flag() { break (count, false); }
        match file.write(&buf[count..]) {
            Ok(n) => {
                if n >= buf.len() - count {
                    break (buf.len(), true);
                } else {
                    count += n;
                }
            },
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                match path {
                    Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                    None       => eprintln!("{}", err),
                }
                break (0, false);
            },
        }
    }
}

fn set_file_len_for_dd(file: &mut File, size: u64, path: Option<&Path>) -> bool
{
    loop {
        match file.set_len(size) {
            Ok(()) => break true,
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                match path {
                    Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                    None       => eprintln!("{}", err),
                }
                break false;
            }
        }
    }
}

fn sync_all_file_for_dd(file: &mut File, path: Option<&Path>) -> bool
{
    loop {
        match file.sync_all() {
            Ok(()) => break true,
            Err(err) if err.kind() == ErrorKind::Interrupted => (),
            Err(err) => {
                match path {
                    Some(path) => eprintln!("{}: {}", path.to_string_lossy(), err),
                    None       => eprintln!("{}", err),
                }
                break false;
            }
        }
    }
}

fn skip(file: &mut File, buf: &mut [u8], count: u64, path: Option<&Path>, opts: &Options) -> bool
{
    let offset = match (buf.len() as u64).checked_mul(count) {
        Some(x) => x,
        None    => {
            eprintln!("Overflow");
            return false;
        },
    };
    let mut is_success = if !opts.skip_reading_conversion {
        loop {
            match file.seek(SeekFrom::Current(offset as i64)) {
                Ok(_) => break true,
                Err(err) if err.kind() == ErrorKind::Interrupted => (),
                Err(_) => break false,
            }
        }
    } else {
        false
    };
    if !is_success {
        is_success = true;
        for _ in 0..count {
            match read_for_dd(file, buf, path) {
                (_, true)  => (),
                (_, false) => {
                    is_success = false;
                    break;
                },
            }
        }
    }
    is_success
}

fn print_records(data: &Data)
{
    eprintln!("{}+{} records in", data.full_input_block_count, data.partial_input_block_count);
    eprintln!("{}+{} records out", data.full_output_block_count, data.partial_output_block_count);
    if data.truncated_block_count > 0 {
        if data.truncated_block_count == 1 {
            eprintln!("{} truncated record", data.truncated_block_count);
        } else {
            eprintln!("{} truncated records", data.truncated_block_count);
        }
    }
}

fn convert<F>(opts: &Options, data: &mut Data, f: F)
    where F: Fn(u8, bool) -> u8
{
    for i in 0..data.input_count {
        data.first_buffer[i] = f(data.first_buffer[i], true);
    }
    if opts.swab_conversion {
        for i in 0..(data.input_count >> 1) {
            let tmp = data.first_buffer[i << 1];
            data.first_buffer[i << 1] = data.first_buffer[(i << 1) + 1];
            data.first_buffer[(i << 1) + 1] = tmp;
        }
    }
}

fn dd_stream_for_one_buffer<F>(input_file: &mut File, output_file: &mut File, input_path: Option<&Path>, output_path: Option<&Path>, opts: &Options, data: &mut Data, f: F) -> bool
    where F: Fn(u8, bool) -> u8 + Copy
{
    let mut is_success = match opts.skip {
        Some(count) => skip(input_file, &mut data.first_buffer, count, input_path, opts),
        None        => true,
    };
    if is_success {
        is_success = match opts.seek {
            Some(count) => skip(output_file, &mut data.first_buffer, count, output_path, opts),
            None        => true,
        };
    }
    if is_success {
        loop {
            match opts.count {
                Some(count) => {
                    if data.full_input_block_count + data.full_input_block_count >= count {
                        break;
                    }
                },
                None => (),
            }
            let (n, tmp_is_success) = read_for_dd(input_file, &mut data.first_buffer, input_path);
            data.input_count = n;
            if n > 0 {
                if n >= opts.input_block_size {
                    data.full_input_block_count += 1;
                } else {
                    data.partial_input_block_count += 1;
                }
            }
            if !opts.no_error_conversion && !tmp_is_success {
                is_success = false;
                break;
            }
            if n == 0 && tmp_is_success { break; }
            convert(opts, data, f);
            let (n, tmp_is_success) = write_for_dd(output_file, &data.first_buffer[0..data.input_count], output_path);
            if n > 0 {
                if n >= opts.output_block_size{
                    data.full_output_block_count += 1;
                } else {
                    data.partial_output_block_count += 1;
                }
            }
            if !tmp_is_success {
                is_success = false;
                break;
            }
        }
    }
    is_success
}

fn write_byte(output_file: &mut File, byte: u8, output_path: Option<&Path>, opts: &Options, data: &mut Data) -> bool
{
    data.second_buffer[data.output_count] = byte;
    data.output_count += 1;
    if data.output_count >= data.second_buffer.len() {
        let (n, is_success) = write_for_dd(output_file, &data.second_buffer, output_path);
        if n > 0 {
            if n >= opts.output_block_size {
                data.full_output_block_count += 1;
            } else {
                data.partial_output_block_count += 1;
            }
        }
        data.output_count = 0;
        is_success
    } else {
        true
    }
}

fn write_first_buffer_for_none(output_file: &mut File, output_path: Option<&Path>, opts: &Options, data: &mut Data) -> bool
{
    for i in 0..data.input_count {
        if !write_byte(output_file, data.first_buffer[i], output_path, opts, data) {
            return false;
        }
    }
    true
}

fn write_first_buffer_for_block(output_file: &mut File, output_path: Option<&Path>, opts: &Options, data: &mut Data) -> bool
{
    match opts.conversion_block_size {
        Some(conv_block_size) => {
            for i in 0..data.input_count {
                let b = data.first_buffer[i];
                if b == data.newline_char {
                    if data.conversion_count < conv_block_size as u64 {
                        for _ in data.conversion_count..(conv_block_size as u64) {
                            if !write_byte(output_file, data.space_char, output_path, opts, data) {
                                return false;
                            }
                        }
                    }
                    data.conversion_count = 0;
                } else {
                    if data.conversion_count < conv_block_size as u64 {
                        if !write_byte(output_file, b, output_path, opts, data) {
                            return false;
                        }
                    } else if data.conversion_count == conv_block_size as u64 {
                        data.truncated_block_count += 1;
                    }
                    data.conversion_count += 1;
                }
            }
            true
        },
        None => write_first_buffer_for_none(output_file, output_path, opts, data),
    }
}

fn write_first_buffer_for_unblock(output_file: &mut File, output_path: Option<&Path>, opts: &Options, data: &mut Data) -> bool
{
    match opts.conversion_block_size {
        Some(conv_block_size) => {
            let mut space_count = 0;
            for i in 0..data.input_count {
                let b = data.first_buffer[i];
                if data.conversion_count >= conv_block_size as u64 {
                    data.conversion_count = 0;
                    space_count = 0;
                    if !write_byte(output_file, data.newline_char, output_path, opts, data) {
                        return false;
                    }
                }
                data.conversion_count += 1;
                if b == data.space_char {
                    space_count += 1;
                } else {
                    for _ in 0..space_count {
                        if !write_byte(output_file, data.space_char, output_path, opts, data) {
                            return false;
                        }
                    }
                    space_count = 0;
                    if !write_byte(output_file, b, output_path, opts, data) {
                        return false;
                    }
                }
            }
            true
        },
        None => write_first_buffer_for_none(output_file, output_path, opts, data),
    }
}

fn write_end_of_file_for_block(output_file: &mut File, output_path: Option<&Path>, opts: &Options, data: &mut Data) -> bool
{
    match opts.conversion_block_size {
        Some(conv_block_size) => {
            if data.conversion_count > 0 && data.conversion_count < conv_block_size as u64 {
                for _ in data.conversion_count..(conv_block_size as u64) {
                    if !write_byte(output_file, data.space_char, output_path, opts, data) {
                        return false;
                    }
                }
            }
            true
        },
        None => true,
    }
}

fn write_end_of_file_for_unblock(output_file: &mut File, output_path: Option<&Path>, opts: &Options, data: &mut Data) -> bool
{
    match opts.conversion_block_size {
        Some(_) => write_byte(output_file, data.newline_char, output_path, opts, data),
        None => true,
    }
}

fn dd_stream_for_two_buffers<F>(input_file: &mut File, output_file: &mut File, input_path: Option<&Path>, output_path: Option<&Path>, opts: &Options, data: &mut Data, f: F) -> bool
    where F: Fn(u8, bool) -> u8 + Copy
{
    let mut is_success = match opts.skip {
        Some(count) => skip(input_file, &mut data.first_buffer, count, input_path, opts),
        None        => true,
    };
    if is_success {
        is_success = match opts.seek {
            Some(count) => skip(output_file, &mut data.second_buffer, count, output_path, opts),
            None        => true,
        };
    }
    if is_success {
        loop {
            match opts.count {
                Some(count) => {
                    if data.full_input_block_count + data.full_input_block_count >= count {
                        break;
                    }
                },
                None => (),
            }
            let (n, tmp_is_success) = read_for_dd(input_file, &mut data.first_buffer, input_path);
            data.input_count = n;
            if n > 0 {
                if n >= opts.input_block_size {
                    data.full_input_block_count += 1;
                } else {
                    data.partial_input_block_count += 1;
                }
            }
            if !opts.no_error_conversion && !tmp_is_success {
                is_success = false;
                break;
            }
            if n == 0 && tmp_is_success { break; }
            convert(opts, data, f);
            let tmp_is_success = match opts.block_conversion {
                BlockConversion::None    => write_first_buffer_for_none(output_file, output_path, opts, data),
                BlockConversion::Block   => write_first_buffer_for_block(output_file, output_path, opts, data),
                BlockConversion::Unblock => write_first_buffer_for_unblock(output_file, output_path, opts, data),
            };
            if !tmp_is_success {
                is_success = false;
                break;
            }
        }
    }
    if is_success {
        is_success = match opts.block_conversion {
            BlockConversion::None    => false,
            BlockConversion::Block   => write_end_of_file_for_block(output_file, output_path, opts, data),
            BlockConversion::Unblock => write_end_of_file_for_unblock(output_file, output_path, opts, data),
        };
    }
    if is_success && data.output_count > 0 {
        let (n, tmp_is_success) = write_for_dd(output_file, &data.second_buffer[0..data.output_count], output_path);
        if n > 0 {
            if n >= opts.output_block_size {
                data.full_output_block_count += 1;
            } else {
                data.partial_output_block_count += 1;
            }
        }
        if !tmp_is_success {
            is_success = false;
        }
    }
    is_success
}

fn dd_stream<F>(input_file: &mut File, output_file: &mut File, input_path: Option<&Path>, output_path: Option<&Path>, opts: &Options, data: &mut Data, f: F) -> bool
    where F: Fn(u8, bool) -> u8 + Copy
{
    if !opts.second_buffer_flag {
        dd_stream_for_one_buffer(input_file, output_file, input_path, output_path, opts, data, f)
    } else {
        dd_stream_for_two_buffers(input_file, output_file, input_path, output_path, opts, data, f)
    }
}

fn dd_file<F>(opts: &Options, f: F) -> bool
    where F: Fn(u8, bool) -> u8 + Copy
{
    let input_path = match &opts.input_path {
        Some(path_buf) => Some(path_buf.as_path()),
        None           => None,
    };
    let output_path = match &opts.output_path {
        Some(path_buf) => Some(path_buf.as_path()),
        None           => None,
    };
    match open_file_for_dd(input_path) {
        Some(mut input_file) => {
            match create_file_for_dd(output_path) {
                Some(mut output_file) => {
                    let first_buf: Vec<u8> = vec![0; opts.input_block_size];
                    let second_buf: Vec<u8> = if opts.second_buffer_flag {
                        vec![0; opts.output_block_size]
                    } else {
                        Vec::new()
                    };
                    let mut data = Data {
                        first_buffer: first_buf,
                        second_buffer: second_buf,
                        full_input_block_count: 0,
                        full_output_block_count: 0,
                        partial_input_block_count: 0,
                        partial_output_block_count: 0,
                        truncated_block_count: 0,
                        input_count: 0,
                        output_count: 0,
                        conversion_count: 0,
                        newline_char: b'\n',
                        space_char: b' ',
                    };
                    data.newline_char = f(data.newline_char, false);
                    data.space_char = f(data.space_char, false);
                    let size = match (opts.output_block_size as u64).checked_mul(opts.seek.unwrap_or(0)) {
                        Some(x) => x,
                        None    => {
                            eprintln!("Overflow");
                            return false;
                        },
                    };
                    let is_file_or_block_device = match output_file.metadata() {
                        Ok(metadata) => metadata.file_type().is_file() || metadata.file_type().is_block_device(),
                        Err(_)       => false,
                    };
                    let mut is_success = if is_file_or_block_device && !opts.no_trunc_conversion {
                        set_file_len_for_dd(&mut output_file, size, output_path)
                    } else {
                        true
                    };
                    if is_success {
                        is_success = dd_stream(&mut input_file, &mut output_file, input_path, output_path, opts, &mut data, f);
                    }
                    if is_success && opts.sync_conversion {
                        is_success = sync_all_file_for_dd(&mut output_file, output_path);
                    }
                    print_records(&data);
                    is_success
                },
                None => false,
            }
        },
        None => false,
    }
}

fn parse_operand(operand: &String) -> Option<(&str, &str)>
{
    match operand.split_once('=') {
        Some(tuple) => Some(tuple),
        None        => {
            eprintln!("No operand argument");
            None
        },
    }
}

fn parse_arg_expr(arg: &str) -> Option<usize>
{
    let mut res: usize = 1;
    for s in arg.split('x') {
        let x = if s.ends_with('b') {
            match s[0..s.len() - 1].parse::<usize>() {
                Ok(x)    => x.checked_mul(512),
                Err(err) => {
                    eprintln!("{}", err);
                    return None;
                },
            }
        } else if s.ends_with('k') {
            match s[0..s.len() - 1].parse::<usize>() {
                Ok(x)    => x.checked_mul(1024),
                Err(err) => {
                    eprintln!("{}", err);
                    return None;
                },
            }
        } else {
            match s.parse::<usize>() {
                Ok(x)    => Some(x),
                Err(err) => {
                    eprintln!("{}", err);
                    return None;
                },
            }
        };
        match x {
            Some(x) => {
                match res.checked_mul(x) {
                    Some(y) => res = y,
                    None    => {
                        eprintln!("Overflow");
                        return None;
                    }
                };
            },
            None => {
                eprintln!("Overflow");
                return None;
            },
        }
    }
    Some(res)
}

fn parse_arg_count(arg: &str) -> Option<u64>
{
    match arg.parse::<u64>() {
        Ok(x)    => Some(x),
        Err(err) => {
            eprintln!("{}", err);
            None
        }
    }
}

fn parse_operands(args: &[String], opts: &mut Options) -> bool
{
    for operand in args.iter().skip(1) {
        match parse_operand(operand) {
            Some(("if", arg)) => opts.input_path = Some(PathBuf::from(arg)),
            Some(("of", arg)) => opts.output_path = Some(PathBuf::from(arg)),
            Some(("ibs", arg)) => {
                match parse_arg_expr(arg) {
                    Some(x) => opts.input_block_size = x,
                    None    => {
                        return false;
                    },
                }
            },
            Some(("obs", arg)) => {
                match parse_arg_expr(arg) {
                    Some(x) => opts.output_block_size = x,
                    None    => {
                        return false;
                    },
                }
            },
            Some(("bs", arg)) => {
                match parse_arg_expr(arg) {
                    Some(x) => {
                        opts.input_block_size = x;
                        opts.output_block_size = x;
                    },
                    None    => {
                        return false;
                    },
                }
            },
            Some(("cbs", arg)) => {
                match parse_arg_expr(arg) {
                    Some(x) => opts.conversion_block_size = Some(x),
                    None    => {
                        return false;
                    },
                }
            },
            Some(("skip", arg)) => {
                match parse_arg_count(arg) {
                    Some(x) => opts.skip = Some(x),
                    None    => {
                        return false;
                    },
                }
            },
            Some(("seek", arg)) => {
                match parse_arg_count(arg) {
                    Some(x) => opts.seek = Some(x),
                    None    => {
                        return false;
                    },
                }
            },
            Some(("count", arg)) => {
                match parse_arg_count(arg) {
                    Some(x) => opts.count = Some(x),
                    None    => {
                        return false;
                    },
                }
            },
            Some(("conv", arg)) => {
                for value in arg.split(',') {
                    match value {
                        "ascii"    => opts.first_conversion = FirstConversion::Ascii,
                        "ebcdic"   => opts.third_conversion = ThirdConversion::Ebcdic,
                        "ibm"      => opts.third_conversion = ThirdConversion::Ibm,
                        "block"    => opts.block_conversion = BlockConversion::Block,
                        "unblock"  => opts.block_conversion = BlockConversion::Unblock,
                        "lcase"    => opts.second_conversion = SecondConversion::LowerCase,
                        "ucase"    => opts.second_conversion = SecondConversion::UpperCase,
                        "swab"     => opts.swab_conversion = true,
                        "noerror"  => opts.no_error_conversion = true,
                        "notrunc"  => opts.no_trunc_conversion = true,
                        "sync"     => opts.sync_conversion = true,
                        "readskip" => opts.skip_reading_conversion = true,
                        _          => {
                            eprintln!("Invalid conversion");
                            return false;
                        },
                    }
                }
            },
            Some((_, _)) => {
                eprintln!("Invalid operand");
                return false;
            },
            None => {
                return false;
            },
        }
    }
    true
}

extern "C" fn interrupt_handler(_sig: libc::c_int)
{ unsafe { INTERRUPT_FLAG = true; } }

fn set_interrupt_handler()
{ unsafe { libc::signal(libc::SIGINT, interrupt_handler as libc::sighandler_t); } }

pub fn main(args: &[String]) -> i32
{
    let tab_ascii_to_ebcdic: Vec<u8> = vec![
        0o000, 0o001, 0o002, 0o003, 0o067, 0o055, 0o056, 0o057,
        0o026, 0o005, 0o045, 0o013, 0o014, 0o015, 0o016, 0o017,
        0o020, 0o021, 0o022, 0o023, 0o074, 0o075, 0o062, 0o046,
        0o030, 0o031, 0o077, 0o047, 0o034, 0o035, 0o036, 0o037,
        0o100, 0o132, 0o177, 0o173, 0o133, 0o154, 0o120, 0o175,
        0o115, 0o135, 0o134, 0o116, 0o153, 0o140, 0o113, 0o141,
        0o360, 0o361, 0o362, 0o363, 0o364, 0o365, 0o366, 0o367,
        0o370, 0o371, 0o172, 0o136, 0o114, 0o176, 0o156, 0o157,
        0o174, 0o301, 0o302, 0o303, 0o304, 0o305, 0o306, 0o307,
        0o310, 0o311, 0o321, 0o322, 0o323, 0o324, 0o325, 0o326,
        0o327, 0o330, 0o331, 0o342, 0o343, 0o344, 0o345, 0o346,
        0o347, 0o350, 0o351, 0o255, 0o340, 0o275, 0o232, 0o155,
        0o171, 0o201, 0o202, 0o203, 0o204, 0o205, 0o206, 0o207,
        0o210, 0o211, 0o221, 0o222, 0o223, 0o224, 0o225, 0o226,
        0o227, 0o230, 0o231, 0o242, 0o243, 0o244, 0o245, 0o246,
        0o247, 0o250, 0o251, 0o300, 0o117, 0o320, 0o137, 0o007,
        0o040, 0o041, 0o042, 0o043, 0o044, 0o025, 0o006, 0o027,
        0o050, 0o051, 0o052, 0o053, 0o054, 0o011, 0o012, 0o033,
        0o060, 0o061, 0o032, 0o063, 0o064, 0o065, 0o066, 0o010,
        0o070, 0o071, 0o072, 0o073, 0o004, 0o024, 0o076, 0o341,
        0o101, 0o102, 0o103, 0o104, 0o105, 0o106, 0o107, 0o110,
        0o111, 0o121, 0o122, 0o123, 0o124, 0o125, 0o126, 0o127,
        0o130, 0o131, 0o142, 0o143, 0o144, 0o145, 0o146, 0o147,
        0o150, 0o151, 0o160, 0o161, 0o162, 0o163, 0o164, 0o165,
        0o166, 0o167, 0o170, 0o200, 0o212, 0o213, 0o214, 0o215,
        0o216, 0o217, 0o220, 0o152, 0o233, 0o234, 0o235, 0o236,
        0o237, 0o240, 0o252, 0o253, 0o254, 0o112, 0o256, 0o257,
        0o260, 0o261, 0o262, 0o263, 0o264, 0o265, 0o266, 0o267,
        0o270, 0o271, 0o272, 0o273, 0o274, 0o241, 0o276, 0o277,
        0o312, 0o313, 0o314, 0o315, 0o316, 0o317, 0o332, 0o333,
        0o334, 0o335, 0o336, 0o337, 0o352, 0o353, 0o354, 0o355,
        0o356, 0o357, 0o372, 0o373, 0o374, 0o375, 0o376, 0o377
    ];
    let tab_ascii_to_ibm: Vec<u8> = vec![
        0o000, 0o001, 0o002, 0o003, 0o067, 0o055, 0o056, 0o057,
        0o026, 0o005, 0o045, 0o013, 0o014, 0o015, 0o016, 0o017,
        0o020, 0o021, 0o022, 0o023, 0o074, 0o075, 0o062, 0o046,
        0o030, 0o031, 0o077, 0o047, 0o034, 0o035, 0o036, 0o037,
        0o100, 0o132, 0o177, 0o173, 0o133, 0o154, 0o120, 0o175,
        0o115, 0o135, 0o134, 0o116, 0o153, 0o140, 0o113, 0o141,
        0o360, 0o361, 0o362, 0o363, 0o364, 0o365, 0o366, 0o367,
        0o370, 0o371, 0o172, 0o136, 0o114, 0o176, 0o156, 0o157,
        0o174, 0o301, 0o302, 0o303, 0o304, 0o305, 0o306, 0o307,
        0o310, 0o311, 0o321, 0o322, 0o323, 0o324, 0o325, 0o326,
        0o327, 0o330, 0o331, 0o342, 0o343, 0o344, 0o345, 0o346,
        0o347, 0o350, 0o351, 0o255, 0o340, 0o275, 0o137, 0o155,
        0o171, 0o201, 0o202, 0o203, 0o204, 0o205, 0o206, 0o207,
        0o210, 0o211, 0o221, 0o222, 0o223, 0o224, 0o225, 0o226,
        0o227, 0o230, 0o231, 0o242, 0o243, 0o244, 0o245, 0o246,
        0o247, 0o250, 0o251, 0o300, 0o117, 0o320, 0o241, 0o007,
        0o040, 0o041, 0o042, 0o043, 0o044, 0o025, 0o006, 0o027,
        0o050, 0o051, 0o052, 0o053, 0o054, 0o011, 0o012, 0o033,
        0o060, 0o061, 0o032, 0o063, 0o064, 0o065, 0o066, 0o010,
        0o070, 0o071, 0o072, 0o073, 0o004, 0o024, 0o076, 0o341,
        0o101, 0o102, 0o103, 0o104, 0o105, 0o106, 0o107, 0o110,
        0o111, 0o121, 0o122, 0o123, 0o124, 0o125, 0o126, 0o127,
        0o130, 0o131, 0o142, 0o143, 0o144, 0o145, 0o146, 0o147,
        0o150, 0o151, 0o160, 0o161, 0o162, 0o163, 0o164, 0o165,
        0o166, 0o167, 0o170, 0o200, 0o212, 0o213, 0o214, 0o215,
        0o216, 0o217, 0o220, 0o232, 0o233, 0o234, 0o235, 0o236,
        0o237, 0o240, 0o252, 0o253, 0o254, 0o255, 0o256, 0o257,
        0o260, 0o261, 0o262, 0o263, 0o264, 0o265, 0o266, 0o267,
        0o270, 0o271, 0o272, 0o273, 0o274, 0o275, 0o276, 0o277,
        0o312, 0o313, 0o314, 0o315, 0o316, 0o317, 0o332, 0o333,
        0o334, 0o335, 0o336, 0o337, 0o352, 0o353, 0o354, 0o355,
        0o356, 0o357, 0o372, 0o373, 0o374, 0o375, 0o376, 0o377
    ];
    let mut tab_ebcdic_to_ascii: Vec<u8> = vec![0; 256];
    for i in 0..256 {
        tab_ebcdic_to_ascii[tab_ascii_to_ebcdic[i] as usize] = i as u8;
    }
    let mut opts = Options {
        input_path: None,
        output_path: None,
        input_block_size: 512,
        output_block_size: 512,
        conversion_block_size: None,
        skip: None,
        seek: None,
        count: None,
        first_conversion: FirstConversion::None,
        second_conversion: SecondConversion::None,
        third_conversion: ThirdConversion::None,
        block_conversion: BlockConversion::None,
        swab_conversion: false,
        no_error_conversion: false,
        no_trunc_conversion: false,
        sync_conversion: false,
        skip_reading_conversion: false,
        second_buffer_flag: false,
    };
    if !parse_operands(args, &mut opts) {
        return 1;
    }
    set_interrupt_handler();
    if opts.input_block_size == 0 {
        eprintln!("Input block size is zero");
        return 1;
    }
    if opts.output_block_size == 0 {
        eprintln!("Output block size is zero");
        return 1;
    }
    match opts.conversion_block_size {
        Some(size) => {
            if size == 0 {
                eprintln!("Conversion block size is zero");
                return 1;
            }
        },
        None => (),
    }
    if opts.conversion_block_size.is_none() {
        opts.block_conversion = BlockConversion::None;
    }
    if opts.input_block_size != opts.output_block_size || opts.block_conversion != BlockConversion::None {
        opts.second_buffer_flag = true;
    }
    let is_success = dd_file(&opts, |b, is_first_conversion| {
            let mut tmp_b = b;
            if is_first_conversion {
                match opts.first_conversion {
                    FirstConversion::None  => (),
                    FirstConversion::Ascii => tmp_b = tab_ebcdic_to_ascii[tmp_b as usize],
                };
            }
            match opts.second_conversion {
                SecondConversion::None => (),
                SecondConversion::LowerCase => {
                    match tmp_b {
                        b'A'..=b'Z' => tmp_b ^= 0x20,
                        _ => (),
                    }
                },
                SecondConversion::UpperCase => {
                    match tmp_b {
                        b'a'..=b'z' => tmp_b ^= 0x20,
                        _ => (),
                    }
                },
            }
            match opts.third_conversion {
                ThirdConversion::None   => (),
                ThirdConversion::Ebcdic => tmp_b = tab_ascii_to_ebcdic[tmp_b as usize],
                ThirdConversion::Ibm    => tmp_b = tab_ascii_to_ibm[tmp_b as usize],
            };
            tmp_b
    });
    if is_success { 0 } else { 1 }
}
