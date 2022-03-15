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
start_test head "head writes head for stdin"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" head > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "abcdef" ../test_tmp/stdout.txt &&
    assert_file_line 4 2 "ghijkl" ../test_tmp/stdout.txt &&
    assert_file_line 5 3 "mnopqr" ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test head "head writes head for more data from stdin"
    head -n 10 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    cat ../test_fixtures/test.txt | "../$RSUBOX" head > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test head "head writes head for file"
    head -n 10 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" head ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test head "head writes head for two files"
    echo "==> ../test_fixtures/test.txt <==" > ../test_tmp/expected.txt
    head -n 10 ../test_fixtures/test.txt >> ../test_tmp/expected.txt
    echo >> ../test_tmp/expected.txt
    echo "==> ../test_fixtures/test_utf8.txt <==" >> ../test_tmp/expected.txt
    head -n 10 ../test_fixtures/test_utf8.txt >> ../test_tmp/expected.txt
    "../$RSUBOX" head ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test head "head writes head for text with UTF-8 codes"
    head -n 10 ../test_fixtures/test_utf8.txt > ../test_tmp/expected.txt
    "../$RSUBOX" head ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test head "head writes 15 lines for 15 files"
    head -n 15 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" head -n 15 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test head "head writes 3 lines for 15 lines"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" head -n 15 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "abcdef" ../test_tmp/stdout.txt &&
    assert_file_line 4 2 "ghijkl" ../test_tmp/stdout.txt &&
    assert_file_line 5 3 "mnopqr" ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test head "head writes 2 lines and line without newline for 15 lines"
    echo "abcdef" > ../test_tmp/expected.txt
    echo "ghijkl" >> ../test_tmp/expected.txt
    echo -n "mnopqr" >> ../test_tmp/expected.txt
    (echo abcdef; echo ghijkl; echo -n mnopqr) | "../$RSUBOX" head -n 15 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test head "head complains on non-existent file"
    "../$RSUBOX" head xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test head "head complains on file that doesn't contain valid UTF-8"
    "../$RSUBOX" head ../test_fixtures/test_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
