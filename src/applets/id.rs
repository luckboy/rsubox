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
use std::ffi::*;
use getopt::Opt;
use users::get_current_uid;
use users::get_current_gid;
use users::get_effective_uid;
use users::get_effective_gid;
use users::get_user_by_name;
use users::get_user_by_uid;
use users::get_group_by_gid;
use crate::utils::*;

enum IdFlag
{
    None,
    Groups,
    Gid,
    Uid,
}

struct Options
{
    id_flag: IdFlag,
    name_flag: bool,
    real_flag: bool,
    login: Option<OsString>,
}

struct AllIds
{
    uid: uid_t,
    gid: gid_t,
    euid: uid_t,
    egid: gid_t,
    groups: Vec<gid_t>,
}

fn get_groups_for_group(group: gid_t, opts: &Options) -> Option<Vec<gid_t>>
{
    let groups = match &opts.login {
        Some(login) => {
            match getgrouplist(login, group) {
                Some(groups) => Some(groups),
                None         => {
                    eprintln!("Can't get groups");
                    None
                },
            }
        },
        None => {
            match getgroups() {
                Ok(groups) => Some(groups),
                Err(err)   => {
                    eprintln!("{}", err);
                    None
                },
            }
        },
    };
    match groups {
        Some(mut groups) => {
            groups.sort();
            groups.dedup();
            Some(groups)
        },
        None => None,
    }
}

fn get_all_ids(opts: &Options) -> Option<AllIds>
{
    match &opts.login {
        Some(login) => {
            match get_user_by_name(login) {
                Some(user) => {
                    match get_groups_for_group(user.primary_group_id(), opts) {
                        Some(groups) => {
                            Some(AllIds {
                                    uid: user.uid(),
                                    gid: user.primary_group_id(),
                                    euid: user.uid(),
                                    egid: user.primary_group_id(),
                                    groups,
                            })
                        },
                        None => None,
                    }
                },
                None => {
                    eprintln!("Can't find user");
                    None
                },
            }
        },
        None => {
            match get_groups_for_group(get_current_gid(), opts) {
                Some(groups) => {
                    Some(AllIds {
                            uid: get_current_uid(),
                            gid: get_current_gid(),
                            euid: get_effective_uid(),
                            egid: get_effective_gid(),
                            groups,
                    })
                },
                None => None,
            }
        },
    }
}

fn get_groups(opts: &Options) -> Option<Vec<gid_t>>
{
    match &opts.login {
        Some(login) => {
            match get_user_by_name(login) {
                Some(user) => get_groups_for_group(user.primary_group_id(), opts),
                None       => {
                    eprintln!("Can't find user");
                    None
                },
            }
        },
        None => get_groups_for_group(get_current_gid(), opts),
    }
}

fn get_gid(opts: &Options) -> Option<gid_t>
{
    match &opts.login {
        Some(login) => {
            match get_user_by_name(login) {
                Some(user) => Some(user.primary_group_id()),
                None       => {
                    eprintln!("Can't find user");
                    None
                },
            }
        },
        None => {
            Some(if opts.real_flag { get_current_gid() } else { get_effective_gid() })
        },
    }
}

fn get_uid(opts: &Options) -> Option<uid_t>
{
    match &opts.login {
        Some(login) => {
            match get_user_by_name(login) {
                Some(user) => Some(user.uid()),
                None       => {
                    eprintln!("Can't find user");
                    None
                },
            }
        },
        None => {
            Some(if opts.real_flag { get_current_uid() } else { get_effective_uid() })
        },
    }
}

fn print_all_ids(opts: &Options) -> bool
{
    match get_all_ids(opts) {
        Some(all_ids) => {
            print!("uid={}", all_ids.uid);
            match get_user_by_uid(all_ids.uid) {
                Some(user) => print!("({})", user.name().to_string_lossy()),
                None       => (),
            }
            print!(" gid={}", all_ids.gid);
            match get_group_by_gid(all_ids.gid) {
                Some(group) => print!("({})", group.name().to_string_lossy()),
                None       => (),
            }
            if all_ids.euid != all_ids.uid {
                print!("euid={}", all_ids.euid);
                match get_user_by_uid(all_ids.euid) {
                    Some(user) => print!("({})", user.name().to_string_lossy()),
                    None       => (),
                }
            }
            if all_ids.egid != all_ids.gid {
                print!(" egid={}", all_ids.egid);
                match get_group_by_gid(all_ids.egid) {
                    Some(group) => print!("({})", group.name().to_string_lossy()),
                    None       => (),
                }
            }
            if !all_ids.groups.is_empty() {
                print!(" groups=");
                let mut is_first = true;
                for gid in all_ids.groups {
                    if !is_first { print!(","); }
                    print!("{}", gid);
                    match get_group_by_gid(gid) {
                        Some(group) => print!("({})", group.name().to_string_lossy()),
                        None       => (),
                    }
                    is_first = false;
                }
            }
            println!("");
            true
        },
        None => false,
    }
}

fn print_groups(opts: &Options) -> bool
{
    match get_groups(opts) {
        Some(groups) => {
            let mut is_success = true;
            let mut is_first = true;
            for gid in groups {
                if !is_first { print!(" "); }
                if !opts.name_flag {
                    print!("{}", gid);
                } else {
                    match get_group_by_gid(gid) {
                        Some(group) => print!("{}", group.name().to_string_lossy()),
                        None        => {
                            eprintln!("Can't find group");
                            is_success = false;
                        },
                    }
                }
                is_first = false;
            }
            println!("");
            is_success
        },
        None => false,
    }
}

fn print_gid(opts: &Options) -> bool {
    match get_gid(opts) {
        Some(gid) => {
            if !opts.name_flag {
                println!("{}", gid);
                true
            } else {
                match get_group_by_gid(gid) {
                    Some(group) => {
                        println!("{}", group.name().to_string_lossy());
                        true
                    },
                    None       => {
                        eprintln!("Can't find group");
                        false
                    },
                }
            }
        },
        None => false,
    }
}

fn print_uid(opts: &Options) -> bool {
    match get_uid(opts) {
        Some(uid) => {
            if !opts.name_flag {
                println!("{}", uid);
                true
            } else {
                match get_user_by_uid(uid) {
                    Some(user) => {
                        println!("{}", user.name().to_string_lossy());
                        true
                    },
                    None       => {
                        eprintln!("Can't find user");
                        false
                    },
                }
            }
        },
        None => false,
    }
}

pub fn main(args: &[String]) -> i32
{
    let mut opt_parser = getopt::Parser::new(args, "Ggnru");
    let mut opts = Options {
        id_flag: IdFlag::None,
        name_flag: false,
        real_flag: false,
        login: None,
    };
    loop {
        match opt_parser.next() {
            Some(Ok(Opt('G', _))) => opts.id_flag = IdFlag::Groups,
            Some(Ok(Opt('g', _))) => opts.id_flag = IdFlag::Gid,
            Some(Ok(Opt('n', _))) => opts.name_flag = true,
            Some(Ok(Opt('r', _))) => opts.real_flag = true,
            Some(Ok(Opt('u', _))) => opts.id_flag = IdFlag::Uid,
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
    let logins: Vec<&String> = args.iter().skip(opt_parser.index()).collect();
    match logins.get(0) {
        Some(login) => {
            if logins.len() > 1 {
                eprintln!("Too many arguments");
                return 1;
            }
            opts.login = Some(OsString::from(login));
        },
        None => (),
    }
    let is_success = match opts.id_flag {
        IdFlag::None   => print_all_ids(&opts),
        IdFlag::Groups => print_groups(&opts),
        IdFlag::Gid    => print_gid(&opts),
        IdFlag::Uid    => print_uid(&opts),
    };
    if is_success { 0 } else { 1 }
}
