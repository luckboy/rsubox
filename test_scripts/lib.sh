#
# Rsubox - Rust single unix utilities in one executable.
# Copyright (C) 2022 Łukasz Szpakowski
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Usage: start_test_suites
start_test_suites() {
    rm -fr test_counts
    mkdir test_counts
    echo 0 > test_counts/passed_count.txt
    echo 0 > test_counts/failed_count.txt
}

# Usage: end_test_suites
end_test_suites() {
    echo
    _passed_count="`cat test_counts/passed_count.txt`"
    _failed_count="`cat test_counts/failed_count.txt`"
    _total_count="`expr "$_passed_count" + "$_failed_count"`"
    printf 'Test result: %d total, %d passed, %d failed\n' "$_total_count" "$_passed_count" "$_failed_count"
    rm -fr test_counts
}

# Usage: start_test <test suite name> <test description>
start_test() {
    printf 'Test: %s: %s ...' "$1" "$2"
    rm -fr test_root test_tmp
    rm -f test_counts/failed.txt
    mkdir test_root test_tmp
    cd test_root
}

# Usage: end_test
end_test() {
    cd ..
    [ ! -e test_counts/failed.txt ] && echo " ok"
    rm -fr test_root test_tmp
    if [ -e test_counts/failed.txt ]; then
        expr "`cat test_counts/failed_count.txt`" + 1 > test_counts/failed_count.txt
    else
        expr "`cat test_counts/passed_count.txt`" + 1 > test_counts/passed_count.txt
    fi
    rm -f test_counts/failed.txt
}

# Arguments: assert <assert name> <command> [<argument>...]
assert() {
    _assert_name="$1"
    shift
    $* > /dev/null 2> /dev/null
    _status="$?"
    if [ "$_status" != 0 ]; then
        printf 'fail assertion %s\n' "$_assert_name"
        echo "stdout:"
        cat ../test_tmp/stdout.txt
        echo
        echo "stderr:"
        cat ../test_tmp/stderr.txt
        echo
        echo -n > ../test_counts/failed.txt
        if [ "$TEST_ABORT" != "" ]; then
            echo
            exit 1
        fi
    fi
    return "$_status"
}

# Usage: assert_non_existent_file <assert name> <file>
assert_non_existent_file() {
    [ ! -e "$2" ]
    assert "$1" [ 0 = "$?" ]
}

# Usage: assert_existent_file <assert name> <file>
assert_existent_file() {
    [ -e "$2" ]
    assert "$1" [ 0 = "$?" ]
}

# Usage: assert_compare_files <assert name> <file1> <file2>
assert_compare_files() {
    cmp "$2" "$3" > /dev/null 2> /dev/null
    assert "$1" [ 0 = "$?" ]
}

# Usage: assert_file_content <assert name> <content> <file>
assert_file_content() {
    printf '%s\n' "$2" | cmp - "$3" > /dev/null 2>/dev/null
    assert "$1" [ 0 = "$?" ]
}

# Usage: assert_file_content_pattern <assert name> <pattern> <file>
assert_file_content_pattern() {
    grep "$2" "$3" > /dev/null 2>/dev/null
    assert "$1" [ 0 = "$?" ]
}

# Usage: assert_file_line_count <assert name> <number of lines> <file>
assert_file_line_count() {
    _line_count="`wc -l "$3" | awk '{ print $1; }'`"
    assert "$1" [ "$2" = "$_line_count" ]
}

read_file_line() {
    tail -n +"$2" "$1" | head -n 1
}

# Usage: assert_file_line <assert name> <number of line> <line> <file>
assert_file_line() {
    _line="`read_file_line "$4" "$2"`"
    [ "$3" = "$_line" ]
    assert "$1" [ 0 = "$?" ]
}

# Usage: assert_file_line_pattern <assert name> <number of line> <pattern> <file>
assert_file_line_pattern() {
    read_file_line "$4" "$2" | grep "$3" > /dev/null 2> /dev/null
    assert "$1" [ 0 = "$?" ]
}

# Usage: asseet_file_mode <assert name> <pattern> <file>
assert_file_mode() {
    _mode="`ls -ld "$3" 2> /dev/null | awk '{ print $1; }'`"
    printf '%s\n' "$_mode" | grep "$2" > /dev/null 2> /dev/null
    assert "$1" [ 0 = "$?" ]
}

# Usage: assert_file_nlink <assert name> <number of links> <file>
assert_file_nlink() {
    _nlink="`ls -ld "$3" 2> /dev/null | awk '{ print $2; }'`"
    assert "$1" [ "$2" = "$_nlink" ]
}

# Usage: assert_file_owner <assert name> <owner> <file>
assert_file_owner() {
    _owner="`ls -ld "$3" 2> /dev/null | awk '{ print $3; }'`"
    assert "$1" [ "$2" = "$_owner" ]
}

# Usage: assert_file_group <assert name> <group> <file>
assert_file_group() {
    _group="`ls -ld "$3" 2> /dev/null | awk '{ print $4; }'`"
    assert "$1" [ "$2" = "$_group" ]
}

# Usage: assert_file_size <assert name> <size> <file>
assert_file_size() {
    _size="`ls -ld "$3" 2> /dev/null | awk '{ print $5; }'`"
    assert "$1" [ "$2" = "$_size" ]
}

# Usage: assert_file_atime <assert name> <pattern> <file>
assert_file_atime() {
    _atime="`ls -ldu "$3" 2> /dev/null | awk '{ print $6 " " $7 " " $8; }'`"
    printf '%s\n' "$_atime" | grep "$2" > /dev/null 2> /dev/null
    assert "$1" [ 0 = "$?" ]
}

# Usage: <assert name> <pattern> <file>
assert_file_mtime() {
    _mtime="`ls -ldc "$3" 2> /dev/null | awk '{ print $6 " " $7 " " $8; }'`"
    printf '%s\n' "$_mtime" | grep "$2" > /dev/null 2> /dev/null
    assert "$1" [ 0 = "$?" ]
}

# Usage: assert_file_link <assert name> <link> <file>
assert_file_link() {
    _link="`readlink "$3" 2> /dev/null`"
    [ "$2" = "$_link" ]
    assert "$1" [ 0 = "$?" ]
}
