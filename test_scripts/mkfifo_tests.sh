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
start_test mkfifo "mkdir makes FIFO file"
    "../$RSUBOX" mkfifo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^p' xxx
end_test

start_test mkfifo "mkfifo makes two FIFO files"
    "../$RSUBOX" mkfifo xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^p' xxx &&
    assert_existent_file 4 yyy &&
    assert_file_mode 5 '^p' yyy
end_test

start_test mkfifo "mkfifo makes FIFO file with permissions"
    "../$RSUBOX" mkfifo -m 644 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^prw-r--r--' xxx
end_test

start_test mkfifo "mkfifo makes FIFO file with permissions as symbolic mode"
    saved_mask="`umask`"
    umask 2
    "../$RSUBOX" mkfifo -m g-w xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt
    status="$?"
    umask "$saved_mask"

    assert 1 [ 0 = "$status" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^prw-r--r--' xxx
end_test

start_test mkfifo "mkfifo complains on too few arguments"
    "../$RSUBOX" mkfifo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test mkfifo "mkfifo complains on existent file"
    echo xxx > xxx
    "../$RSUBOX" mkfifo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern  3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-' xxx    
end_test
