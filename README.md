# Rsubox

Rsubox is Rust single Unix utilities in one executable. This program is written in Rust programming
language. This program contains common Unix utilities.

## Compliance with standard

These utilities are most compliant with the SUSV3 (Single UNIX Specification Version 3).
Non-compliance with the SUSV3 is most caused security and size of the utilities. The most utilities
are from the SUSV3. Also, this program contains some non-standard utilities.

## Installation

You can install this program by invoke the following command:

    cargo install rsubox

## Usage

You can display names of all implemented utilities by invoke the following command:

    rsubox applets

You can run an utility by invoke the following command:

    rsubox <utility name> [<argument> ...]

You can create links with names of the utilities to this program in directory of binaries and run
the utilities by directly invoke their names.

## License

This program is licensed under the GNU General Public License v3 or later. See the LICENSE file for
the full licensing terms.
