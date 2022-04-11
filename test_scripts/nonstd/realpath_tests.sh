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
start_test nonstd/realpath "realpath prints real path"
    echo xxx > xxx
    "../$RSUBOX" realpath xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`pwd -P`/xxx" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nonstd/realpath "realpath prints two real paths"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" realpath xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "`pwd -P`/xxx" ../test_tmp/stdout.txt &&
    assert_file_line 3 2 "`pwd -P`/yyy" ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test nonstd/realpath "realpath prints real path for symbolic link"
    echo xxx > xxx
    ln -s xxx yyy
    "../$RSUBOX" realpath yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`pwd -P`/xxx" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nonstd/realpath "realpath prints real path for path with . component"
    mkdir test
    echo xxx > test/xxx
    "../$RSUBOX" realpath test/./xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`pwd -P`/test/xxx" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nonstd/realpath "realpath prints real path for path with .. component"
    mkdir test
    mkdir test2
    echo xxx > test2/xxx
    "../$RSUBOX" realpath test/../test2/xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`pwd -P`/test2/xxx" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nonstd/realpath "realpath prints real path for path with symbolic link component"
    mkdir test
    echo xxx > test/xxx
    ln -s test test2
    "../$RSUBOX" realpath test2/xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`pwd -P`/test/xxx" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test
