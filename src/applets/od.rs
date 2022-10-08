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
use std::cmp::max;
use std::collections::HashMap;
use std::convert::TryInto;
use std::fs::*;
use std::io::*;
use std::path::*;
use getopt::Opt;
use crate::utils::*;

enum AddressBase
{
    None,
    Decimal,
    Octal,
    Hexdecimal,
}

#[derive(Copy, Clone)]
enum Endian {
    Little,
    Big,
}

#[derive(Copy, Clone)]
enum IntFormat
{
    Decimal,
    Octal,
    Hexdecimal,
    Unsigned,
}

#[derive(Copy, Clone)]
enum IntSize
{
    Char,
    Short,
    Int,
    Long,
}

#[derive(Copy, Clone)]
enum FloatSize
{
    Single,
    Double,
}

#[derive(Copy, Clone)]
enum Type
{
    Ascii,
    Char,
    Int(IntFormat, IntSize),
    Float(FloatSize),
}

struct TypeAndWidth
{
    typ: Type,
    width: usize,
}

struct Options
{
    addr_base: AddressBase,
    skip: u64,
    count: Option<u64>,
    endian: Endian,
    types_and_widths: Vec<TypeAndWidth>,
    output_duplication_flag: bool,
}

struct Data
{
    path_bufs: Vec<PathBuf>,
    path_buf_index: usize,
    file_reader: Option<ByteReader<BufReader<File>>>,
    stdin_reader: Option<ByteReader<BufReader<Stdin>>>,
    addr: u64,
}

struct Counter
{
    count: u64,
    limit: Option<u64>,
}

fn type_to_default_width(typ: Type) -> usize
{
    match typ {
        Type::Ascii => 3,
        Type::Char => 3,
        Type::Int(IntFormat::Decimal, IntSize::Char) => 4,
        Type::Int(IntFormat::Decimal, IntSize::Short) => 6,
        Type::Int(IntFormat::Decimal, IntSize::Int) => 11,
        Type::Int(IntFormat::Decimal, IntSize::Long) => 20,
        Type::Int(IntFormat::Octal, IntSize::Char) => 3,
        Type::Int(IntFormat::Octal, IntSize::Short) => 6,
        Type::Int(IntFormat::Octal, IntSize::Int) => 11,
        Type::Int(IntFormat::Octal, IntSize::Long) => 22,
        Type::Int(IntFormat::Hexdecimal, IntSize::Char) => 2,
        Type::Int(IntFormat::Hexdecimal, IntSize::Short) => 4,
        Type::Int(IntFormat::Hexdecimal, IntSize::Int) => 8,
        Type::Int(IntFormat::Hexdecimal, IntSize::Long) => 16,
        Type::Int(IntFormat::Unsigned, IntSize::Char) => 3,
        Type::Int(IntFormat::Unsigned, IntSize::Short) => 5,
        Type::Int(IntFormat::Unsigned, IntSize::Int) => 10,
        Type::Int(IntFormat::Unsigned, IntSize::Long) => 20,
        Type::Float(FloatSize::Single) => 15,
        Type::Float(FloatSize::Double) => 24,
    }
}

fn type_to_byte_count(typ: Type) -> usize
{
    match typ {
        Type::Ascii => 1,
        Type::Char => 1,
        Type::Int(_, IntSize::Char) => 1,
        Type::Int(_, IntSize::Short) => 2,
        Type::Int(_, IntSize::Int) => 4,
        Type::Int(_, IntSize::Long) => 8,
        Type::Float(FloatSize::Single) => 4,
        Type::Float(FloatSize::Double) => 8,
    }
}

fn type_to_count_in_8_bytes(typ: Type) -> usize
{ 8 / type_to_byte_count(typ) }

fn type_and_width(typ: Type) -> TypeAndWidth
{ TypeAndWidth { typ, width: type_to_default_width(typ), } }

fn bytes_to_i8(bytes: &[u8], endian: Endian) -> i8
{
    match endian {
        Endian::Little => i8::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => i8::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_i16(bytes: &[u8], endian: Endian) -> i16
{
    match endian {
        Endian::Little => i16::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => i16::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_i32(bytes: &[u8], endian: Endian) -> i32
{
    match endian {
        Endian::Little => i32::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => i32::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_i64(bytes: &[u8], endian: Endian) -> i64
{
    match endian {
        Endian::Little => i64::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => i64::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_u8(bytes: &[u8], endian: Endian) -> u8
{
    match endian {
        Endian::Little => u8::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => u8::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_u16(bytes: &[u8], endian: Endian) -> u16
{
    match endian {
        Endian::Little => u16::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => u16::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_u32(bytes: &[u8], endian: Endian) -> u32
{
    match endian {
        Endian::Little => u32::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => u32::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_u64(bytes: &[u8], endian: Endian) -> u64
{
    match endian {
        Endian::Little => u64::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => u64::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_f32(bytes: &[u8], endian: Endian) -> f32
{
    match endian {
        Endian::Little => f32::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => f32::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn bytes_to_f64(bytes: &[u8], endian: Endian) -> f64
{
    match endian {
        Endian::Little => f64::from_le_bytes(bytes.try_into().unwrap()),
        Endian::Big    => f64::from_be_bytes(bytes.try_into().unwrap()),
    }
}

fn update_widths(opts: &mut Options)
{
    loop {
        let max = opts.types_and_widths.iter().fold(0usize, |tmp_max, p| {
                max(tmp_max, (p.width + 1) * type_to_count_in_8_bytes(p.typ))
        });
        let b = opts.types_and_widths.iter().all(|p| {
                (p.width + 1) * type_to_count_in_8_bytes(p.typ) == max
        });
        if b { break; }
        for type_and_width in &mut opts.types_and_widths {
            let count = type_to_count_in_8_bytes(type_and_width.typ);
            type_and_width.width += (max - (type_and_width.width + 1) * count + count - 1) / count;
        }
    }
}

fn read_byte_from_data(data: &mut Data) -> (Option<u8>, bool)
{
    if !data.path_bufs.is_empty() {
        let mut is_success = true;
        while data.path_buf_index < data.path_bufs.len() {
            if data.file_reader.is_none() {
                match File::open(data.path_bufs[data.path_buf_index].as_path()) {
                    Ok(file) => data.file_reader = Some(ByteReader::new(BufReader::new(file))),
                    Err(err) => {
                        eprintln!("{}: {}", data.path_bufs[data.path_buf_index].as_path().to_string_lossy(), err);
                        is_success = false;
                    },
                }
            }
            match &mut data.file_reader {
                Some(r) => {
                    let mut b: u8 = 0;
                    match r.read_byte(&mut b) {
                        Ok(false) => (),
                        Ok(true)  => {
                            data.addr += 1;
                            return (Some(b), is_success)
                        },
                        Err(err)  => {
                            eprintln!("{}: {}", data.path_bufs[data.path_buf_index].as_path().to_string_lossy(), err);
                            is_success = false;
                        },
                    }
                },
                None => (),
            }
            data.file_reader = None;
            data.path_buf_index += 1;
        }
        (None, is_success)
    } else {
        let mut is_success = true;
        if data.stdin_reader.is_none() {
            data.stdin_reader = Some(ByteReader::new(BufReader::new(stdin())));
        }
        match &mut data.stdin_reader {
            Some(r) => {
                let mut b: u8 = 0;
                match r.read_byte(&mut b) {
                    Ok(false) => (),
                    Ok(true)  => {
                        data.addr += 1;
                        return (Some(b), true)
                    },
                    Err(err)  => {
                        eprintln!("{}: {}", data.path_bufs[data.path_buf_index].as_path().to_string_lossy(), err);
                        is_success = false;
                    },
                }
            },
            None => (),
        }
        data.stdin_reader = None;
        (None, is_success)
    }
}

fn read_buf_from_data(data: &mut Data, buf: &mut [u8], counter: &mut Counter) -> (usize, bool)
{
    let mut count: usize = 0;
    let mut is_success = true;
    for i in 0..buf.len() {
        match counter.limit {
            Some(limit) => {
                if counter.count >= limit { break; }
            },
            None => (),
        }
        match read_byte_from_data(data) {
            (Some(b), tmp_is_success) => {
                buf[i] = b;
                counter.count += 1;
                count += 1;
                is_success &= tmp_is_success;
            },
            (None, tmp_is_success) => {
                is_success &= tmp_is_success;
                break;                
            }
        }
    }
    (count, is_success)
}

fn skip_data(data: &mut Data, opts: &Options) -> (bool, bool)
{
    let mut i: u64 = 0;
    let mut is_success = true;
    while i < opts.skip {
        match read_byte_from_data(data) {
            (Some(_), tmp_is_success) => {
                i += 1;
                is_success &= tmp_is_success;
            },
            (None, tmp_is_success) => {
                is_success &= tmp_is_success;
                eprintln!("Too few data");
                return (false, is_success);
            },
        }
    }
    (true, is_success)
}

fn print_addr<W: Write>(addr: u64, w: &mut W, opts: &Options) -> bool
{
    let res = match opts.addr_base {
        AddressBase::None => Ok(()),
        AddressBase::Decimal => write!(w, "{:0>7}", addr),
        AddressBase::Octal => write!(w, "{:0>7o}", addr),
        AddressBase::Hexdecimal => write!(w, "{:0>6x}", addr),
    };
    match res {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}", err);
            false
        }
    }
}

fn print_empty_addr<W: Write>(w: &mut W, opts: &Options) -> bool
{
    let res = match opts.addr_base {
        AddressBase::None => Ok(()),
        AddressBase::Decimal => write!(w, "{:>7}", ""),
        AddressBase::Octal => write!(w, "{:>7}", ""),
        AddressBase::Hexdecimal => write!(w, "{:>6}", ""),
    };
    match res {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}", err);
            false
        }
    }
}

fn print_bytes<W: Write>(w: &mut W, bytes: &[u8], type_and_width: &TypeAndWidth, opts: &Options, special_char_names: &HashMap<u8, &'static str>) -> bool
{
    let res = match type_and_width.typ {
        Type::Ascii => {
            match special_char_names.get(&(bytes[0] & 127)) {
                Some(name) => write!(w, " {:>width$}", name, width = type_and_width.width),
                None       => write!(w, " {:>width$}", char::from_u32((bytes[0] & 127) as u32).unwrap(), width = type_and_width.width),
            }
        },
        Type::Char => {
            match char::from_u32(bytes[0] as u32).unwrap() {
                '\0'   => write!(w, " {:>width$}", "\\0", width = type_and_width.width),
                '\x08' => write!(w, " {:>width$}", "\\b", width = type_and_width.width),
                '\x0c' => write!(w, " {:>width$}", "\\f", width = type_and_width.width),
                '\n'   => write!(w, " {:>width$}", "\\n", width = type_and_width.width),
                '\r'   => write!(w, " {:>width$}", "\\r", width = type_and_width.width),
                '\t'   => write!(w, " {:>width$}", "\\t", width = type_and_width.width),
                c      => {
                    if c.is_ascii_graphic() || c.is_ascii_whitespace() {
                        write!(w, " {:>width$}", c, width = type_and_width.width)
                    } else {
                        let s = format!("{:0>3o}", bytes[0]);
                        write!(w, " {:>width$}", s, width = type_and_width.width)
                    }
                },
            }
        },
        Type::Int(IntFormat::Decimal, IntSize::Char) => {
            let s = format!("{:>4}", bytes_to_i8(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Decimal, IntSize::Short) => {
            let s = format!("{:>6}", bytes_to_i16(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Decimal, IntSize::Int) => {
            let s = format!("{:>11}", bytes_to_i32(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Decimal, IntSize::Long) => {
            let s = format!("{:>20}", bytes_to_i64(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Octal, IntSize::Char) => {
            let s = format!("{:0>3o}", bytes_to_u8(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Octal, IntSize::Short) => {
            let s = format!("{:0>6o}", bytes_to_u16(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Octal, IntSize::Int) => {
            let s = format!("{:0>11o}", bytes_to_u32(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Octal, IntSize::Long) => {
            let s = format!("{:0>22o}", bytes_to_u64(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Hexdecimal, IntSize::Char) => {
            let s = format!("{:0>2x}", bytes_to_u8(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Hexdecimal, IntSize::Short) => {
            let s = format!("{:0>4x}", bytes_to_u16(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Hexdecimal, IntSize::Int) => {
            let s = format!("{:0>8x}", bytes_to_u32(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Hexdecimal, IntSize::Long) => {
            let s = format!("{:0>16x}", bytes_to_u64(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Unsigned, IntSize::Char) => {
            let s = format!("{:>3}", bytes_to_u8(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Unsigned, IntSize::Short) => {
            let s = format!("{:>5}", bytes_to_u16(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Unsigned, IntSize::Int) => {
            let s = format!("{:>10}", bytes_to_u32(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Int(IntFormat::Unsigned, IntSize::Long) => {
            let s = format!("{:>20}", bytes_to_u64(bytes, opts.endian));
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Float(FloatSize::Single) => {
            let n = bytes_to_f32(bytes, opts.endian);
            let s = if n <= 1.0e13 && n >= 0.0001 {
                format!("{:>15}", n)
            } else {
                format!("{:>15e}", n)
            };
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
        Type::Float(FloatSize::Double) => {
            let n = bytes_to_f64(bytes, opts.endian);
            let s = if n <= 1.0e22 && n >= 1.0e-4 {
                format!("{:>24}", n)
            } else {
                format!("{:>24e}", n)
            };
            write!(w, " {:>width$}", s, width = type_and_width.width)
        },
    };
    match res {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}", err);
            false
        }
    }
}

fn print_newline<W: Write>(w: &mut W) -> bool
{
    match write!(w, "\n") {
        Ok(())   => true,
        Err(err) => {
            eprintln!("{}", err);
            false
        }
    }
}

fn print_data(data: &mut Data, opts: &Options, special_char_names: &HashMap<u8, &'static str>) -> bool
{
    let mut w = BufWriter::new(stdout());
    let mut counter = Counter {
        count: 0,
        limit: opts.count,
    };
    let mut prev_buf: Option<Vec<u8>> = None;
    let mut is_first_duplication = true;
    let mut is_success = true;
    loop {
        let addr = data.addr;
        let mut buf: Vec<u8> = vec![0; 16];
        let (count, tmp_is_success) = read_buf_from_data(data, buf.as_mut_slice(), &mut counter);
        if count == 0 { break; }
        let is_duplication = if !opts.output_duplication_flag && count == 16 {
            match &prev_buf {
                Some(prev_buf) => &buf == prev_buf,
                None           => false,
            }
        } else {
            false
        };
        if !is_duplication {
            let mut is_first = true;
            for type_and_width in &opts.types_and_widths {
                if is_first {
                    if !print_addr(addr, &mut w, opts) { return false; }
                } else {
                    if !print_empty_addr(&mut w, opts) { return false; }
                }
                let mut i: usize = 0;
                while i < count {
                    if !print_bytes(&mut w, &buf[i..(i + type_to_byte_count(type_and_width.typ))], &type_and_width, opts, special_char_names) {
                        return false;
                    }
                    i += type_to_byte_count(type_and_width.typ);
                }
                if !print_newline(&mut w) { return false; }
                is_first = false;
            }
            is_first_duplication = true;
        } else {
            if is_first_duplication {
                let _res = write!(&mut w, "*\n");
            }
            is_first_duplication = false;
        }
        is_success = tmp_is_success;
        prev_buf = Some(buf);
    }
    if !print_addr(data.addr, &mut w, opts) { return false; }
    if !print_newline(&mut w) { return false; }
    match w.flush() {
        Ok(())   => (),
        Err(err) => {
            eprintln!("{}", err);
            return false;
        },
    }
    is_success
}

fn parse_addr_base(s: &String) -> Option<AddressBase>
{
    if s == &String::from("n") {
        Some(AddressBase::None)
    } else if s == &String::from("d") {
        Some(AddressBase::Decimal)
    } else if s == &String::from("o") {
        Some(AddressBase::Octal)
    } else if s == &String::from("x") {
        Some(AddressBase::Hexdecimal)
    } else {
        eprintln!("Invalid address base");
        None
    }
}

fn parse_number_for_str(s: &str) -> Option<u64>
{
    if s.starts_with("0x") || s.starts_with("0X") {
        match u64::from_str_radix(&s[2..], 16) {
            Ok(n)    => Some(n),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    } else if s.starts_with("0") {
        match u64::from_str_radix(s, 8) {
            Ok(n)    => Some(n),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    } else {
        match s.parse::<u64>() {
            Ok(n)    => Some(n),
            Err(err) => {
                eprintln!("{}", err);
                None
            },
        }
    }
}

fn parse_count(s: &String) -> Option<u64>
{
    let t = if s.starts_with("+") {
        &s[1..]
    } else {
        s.as_str()
    };
    if t.ends_with("b") {
        match parse_number_for_str(&t[0..t.len() - 1]) {
            Some(n) => {
                match n.checked_mul(512) {
                    Some(m) => Some(m),
                    None    => {
                        eprintln!("Overflow");
                        None
                    },
                }
            },
            None    => None,
        }
    } else if t.ends_with("k") {
        match parse_number_for_str(&t[0..t.len() - 1]) {
            Some(n) => {
                match n.checked_mul(1024) {
                    Some(m) => Some(m),
                    None    => {
                        eprintln!("Overflow");
                        None
                    },
                }
            },
            None    => None,
        }
    } else if t.ends_with("m") {
        match parse_number_for_str(&t[0..t.len() - 1]) {
            Some(n) => {
                match n.checked_mul(1024 * 1024) {
                    Some(m) => Some(m),
                    None    => {
                        eprintln!("Overflow");
                        None
                    },
                }
            },
            None    => None,
        }
    } else {
        parse_number_for_str(t)
    }
}

fn parse_type_string(s: &String, types_and_widths: &mut Vec<TypeAndWidth>) -> bool
{
    let mut char_iter = PushbackIter::new(s.chars());
    loop {
        match char_iter.next() {
            Some('a') => types_and_widths.push(type_and_width(Type::Ascii)), 
            Some('c') => types_and_widths.push(type_and_width(Type::Char)), 
            Some(c @ ('d' | 'f' | 'o' | 'u' | 'x')) => {
                let mut int_size = IntSize::Int;
                let mut float_size = FloatSize::Double;
                match char_iter.next() {
                    Some(c2 @ ('0'..='9')) => {
                        let mut t = String::new();
                        t.push(c2);
                        loop {
                            match char_iter.next() {
                                Some(c3 @ ('0'..='9')) => t.push(c3),
                                Some(c3) => {
                                    char_iter.undo(c3);
                                    break;
                                },
                                None => break,
                            }
                        }
                        match t.parse::<usize>() {
                            Ok(4) if c == 'f' => float_size = FloatSize::Single,
                            Ok(8) if c == 'f' => float_size = FloatSize::Double,
                            Ok(1) if c != 'f' => int_size = IntSize::Char,
                            Ok(2) if c != 'f' => int_size = IntSize::Short,
                            Ok(4) if c != 'f' => int_size = IntSize::Int,
                            Ok(8) if c != 'f' => int_size = IntSize::Long,
                            _ => {
                                eprintln!("Invalid type string");
                                return false;
                            },
                        }
                    },
                    Some('F') if c == 'f' => float_size = FloatSize::Single,
                    Some('D' | 'L') if c == 'f' => float_size = FloatSize::Double,
                    Some('C') if c != 'f' => int_size = IntSize::Char,
                    Some('S') if c != 'f' => int_size = IntSize::Short,
                    Some('I') if c != 'f' => int_size = IntSize::Int,
                    Some('L') if c != 'f' => int_size = IntSize::Long,
                    Some(c2) => char_iter.undo(c2),
                    None => (),
                }
                match c {
                    'd' => types_and_widths.push(type_and_width(Type::Int(IntFormat::Decimal, int_size))),
                    'f' => types_and_widths.push(type_and_width(Type::Float(float_size))),
                    'o' => types_and_widths.push(type_and_width(Type::Int(IntFormat::Octal, int_size))),
                    'u' => types_and_widths.push(type_and_width(Type::Int(IntFormat::Unsigned, int_size))),
                    'x' => types_and_widths.push(type_and_width(Type::Int(IntFormat::Hexdecimal, int_size))),
                    _   => (),
                }
            },
            Some(_) => {
                eprintln!("Invalid type string");
                return false;  
            },
            None => break,
        }
    }
    true
}

fn parse_offset(s: &String) -> Option<u64>
{
    let t = if s.starts_with("+") {
        &s[1..]
    } else {
        s.as_str()
    };
    if t.ends_with(".b") {
        match t[0..t.len() - 2].parse::<u64>() {
            Ok(n)  => n.checked_mul(512),
            Err(_) => None,
        }
    } else if t.ends_with(".") {
        match t[0..t.len() - 1].parse::<u64>() {
            Ok(n)  => Some(n),
            Err(_) => None,
        }
    } else if t.ends_with("b") {
        match u64::from_str_radix(&t[0..t.len() - 1], 8) {
            Ok(n)  => n.checked_mul(512),
            Err(_) => None,
        }
    } else {
        match u64::from_str_radix(t, 8) {
            Ok(n)  => Some(n),
            Err(_) => None,
        }
    }
}

fn initialize_special_char_names(special_char_names: &mut HashMap<u8, &'static str>)
{
    special_char_names.insert(0o000, "nul");
	special_char_names.insert(0o001, "soh");
	special_char_names.insert(0o002, "stx");
	special_char_names.insert(0o003, "etx");
	special_char_names.insert(0o004, "eot");
	special_char_names.insert(0o005, "enq");
	special_char_names.insert(0o006, "ack");
	special_char_names.insert(0o007, "bel");
	special_char_names.insert(0o010, "bs");
	special_char_names.insert(0o011, "ht");
    special_char_names.insert(0o012, "nl");
    special_char_names.insert(0o013, "vt");
    special_char_names.insert(0o014, "ff");
    special_char_names.insert(0o015, "cr");
    special_char_names.insert(0o016, "so");
	special_char_names.insert(0o017, "si");
	special_char_names.insert(0o020, "dle");
	special_char_names.insert(0o021, "dc1");
	special_char_names.insert(0o022, "dc2");
	special_char_names.insert(0o023, "dc3");
	special_char_names.insert(0o024, "dc4");
	special_char_names.insert(0o025, "nak");
    special_char_names.insert(0o026, "syn");
	special_char_names.insert(0o027, "etb");
	special_char_names.insert(0o030, "can");
    special_char_names.insert(0o031, "em");
	special_char_names.insert(0o032, "sub");
	special_char_names.insert(0o033, "esc");
	special_char_names.insert(0o034, "fs");
	special_char_names.insert(0o035, "gs");
	special_char_names.insert(0o036, "rs");
	special_char_names.insert(0o037, "us");
	special_char_names.insert(0o040, "sp");
	special_char_names.insert(0o177, "del");
}

pub fn main(args: &[String]) -> i32
{
    let mut special_char_names: HashMap<u8, &'static str> = HashMap::new();
    initialize_special_char_names(&mut special_char_names);
    let mut opt_parser = getopt::Parser::new(args, "A:Bbcdj:LN:ost:vx");
    let mut opts = Options {
        addr_base: AddressBase::Octal,
        skip: 0,
        count: None,
        endian: Endian::Little,
        types_and_widths: Vec::new(),
        output_duplication_flag: false,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('A', Some(opt_arg)))) => {
                match parse_addr_base(&opt_arg) {
                    Some(addr_base) => opts.addr_base = addr_base,
                    None            => return 1,
                }
            },
            Some(Ok(Opt('A', None))) => {
                eprintln!("option requires an argument -- 'A'");
                return 1;
            },
            Some(Ok(Opt('B', _))) => opts.endian = Endian::Big,
            Some(Ok(Opt('b', _))) => opts.types_and_widths.push(type_and_width(Type::Int(IntFormat::Octal, IntSize::Char))),
            Some(Ok(Opt('c', _))) => opts.types_and_widths.push(type_and_width(Type::Char)),
            Some(Ok(Opt('d', _))) => opts.types_and_widths.push(type_and_width(Type::Int(IntFormat::Unsigned, IntSize::Short))),
            Some(Ok(Opt('j', Some(opt_arg)))) => {
                match parse_count(&opt_arg) {
                    Some(skip) => opts.skip = skip,
                    None       => return 1,
                }
            },
            Some(Ok(Opt('j', None))) => {
                eprintln!("option requires an argument -- 'j'");
                return 1;
            },
            Some(Ok(Opt('L', _))) => opts.endian = Endian::Little,
            Some(Ok(Opt('N', Some(opt_arg)))) => {
                match parse_count(&opt_arg) {
                    Some(count) => opts.count = Some(count),
                    None        => return 1,
                }
            },
            Some(Ok(Opt('N', None))) => {
                eprintln!("option requires an argument -- 'N'");
                return 1;
            },
            Some(Ok(Opt('o', _))) => opts.types_and_widths.push(type_and_width(Type::Int(IntFormat::Octal, IntSize::Short))),
            Some(Ok(Opt('s', _))) => opts.types_and_widths.push(type_and_width(Type::Int(IntFormat::Decimal, IntSize::Short))),
            Some(Ok(Opt('t', Some(opt_arg)))) => {
                if !parse_type_string(&opt_arg, &mut opts.types_and_widths) { return 1; }
            },
            Some(Ok(Opt('v', _))) => opts.output_duplication_flag = true,
            Some(Ok(Opt('x', _))) => opts.types_and_widths.push(type_and_width(Type::Int(IntFormat::Hexdecimal, IntSize::Short))),
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
    if opts.types_and_widths.is_empty() {
        opts.types_and_widths.push(type_and_width(Type::Int(IntFormat::Octal, IntSize::Short)));
    }
    update_widths(&mut opts);
    let mut data = Data {
        path_bufs: Vec::new(),
        path_buf_index: 0,
        file_reader: None,
        stdin_reader: None,
        addr: 0,
    };
    let mut arg_iter = args.iter().skip(opt_parser.index());
    let mut is_offset = false;
    loop {
        match arg_iter.next() {
            Some(arg) => {
                if !opts.output_duplication_flag {
                    match parse_offset(arg) {
                        Some(skip) => {
                            opts.skip = skip;
                            is_offset = true;
                        },
                        None => {
                            if !is_offset {
                                let mut path_buf = PathBuf::new();
                                path_buf.push(arg);
                                data.path_bufs.push(path_buf);
                            } else {
                                eprintln!("Too many arguments");
                                return 1;
                            }
                        },
                    }
                } else {
                    let mut path_buf = PathBuf::new();
                    path_buf.push(arg);
                    data.path_bufs.push(path_buf);
                }
            },
            None => break,
        }
    }
    let mut status = 0;
    let (no_more_data, is_success) = skip_data(&mut data, &opts);
    if !no_more_data { return 1; }
    if !is_success { status = 1; }
    if !print_data(&mut data, &opts, &special_char_names) { status = 1; }
    status
}
