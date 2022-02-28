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
start_test link "link creates hard link"
    echo xxx > xxx
    "../$RSUBOX" link xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_nlink 5 2 xxx &&
    assert_existent_file 6 yyy &&
    assert_file_mode 7 '^-' yyy &&
    assert_file_nlink 8 2 yyy
end_test

start_test link "link complains on too few arguments for zero arguments"
    "../$RSUBOX" link > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test link "link complains on too few arguments for one argument"
    "../$RSUBOX" link xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test link "link complains on too many arguments"
    "../$RSUBOX" link xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
end_test

start_test link "link complains on non-existent file"
    "../$RSUBOX" link xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_non_existent_file 6 yyy
end_test

start_test link "link complains on existent file"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" link xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^yyy: ' ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_nlink 5 1 xxx &&
    assert_existent_file 6 yyy &&
    assert_file_mode 7 '^-' yyy &&
    assert_file_nlink 8 1 yyy
end_test
