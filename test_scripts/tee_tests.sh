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
start_test tee "tee reads from stdin and writes to stdout"
    echo abcdef | "../$RSUBOX" tee > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 abcdef ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tee "tee reads more data from stdin and writes to stdout"
    cat ../test_fixtures/test.txt | "../$RSUBOX" tee > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tee "tee duplicates stdin to one file"
    cat ../test_fixtures/test.txt | "../$RSUBOX" tee xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-' xxx &&
    assert_compare_files 6 ../test_fixtures/test.txt xxx
end_test

start_test tee "tee duplicates stdin to two files"
    cat ../test_fixtures/test.txt | "../$RSUBOX" tee xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-' xxx &&
    assert_compare_files 6 ../test_fixtures/test.txt xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test tee "tee duplicates stdin to file for existent file"
    echo xxx > xxx
    cat ../test_fixtures/test.txt | "../$RSUBOX" tee xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-' xxx &&
    assert_compare_files 6 ../test_fixtures/test.txt xxx
end_test

start_test tee "tee duplicates stdin to file for appending"
    cat ../test_fixtures/test.txt | "../$RSUBOX" tee -a xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-' xxx &&
    assert_compare_files 6 ../test_fixtures/test.txt xxx
end_test

start_test tee "tee duplicates stdin to file for appending and existent file"
    echo xxx > xxx
    echo xxx > ../test_tmp/expected.txt
    cat ../test_fixtures/test.txt >> ../test_tmp/expected.txt
    cat ../test_fixtures/test.txt | "../$RSUBOX" tee -a xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-' xxx &&
    assert_compare_files 6 ../test_tmp/expected.txt xxx
end_test

start_test tee "tee duplicates stdin to one file for ignored interrupts"
    cat ../test_fixtures/test.txt | "../$RSUBOX" tee -i xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-' xxx &&
    assert_compare_files 6 ../test_fixtures/test.txt xxx
end_test
