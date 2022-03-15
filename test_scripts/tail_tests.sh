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
start_test tail "tail writes tail for stdin"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" tail > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "abcdef" ../test_tmp/stdout.txt &&
    assert_file_line 4 2 "ghijkl" ../test_tmp/stdout.txt &&
    assert_file_line 5 3 "mnopqr" ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for more data from stdin"
    tail -n 10 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    cat ../test_fixtures/test.txt | "../$RSUBOX" tail > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for file"
    tail -n 10 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for two files"
    echo "==> ../test_fixtures/test.txt <==" > ../test_tmp/expected.txt
    tail -n 10 ../test_fixtures/test.txt >> ../test_tmp/expected.txt
    echo >> ../test_tmp/expected.txt
    echo "==> ../test_fixtures/test_utf8.txt <==" >> ../test_tmp/expected.txt
    tail -n 10 ../test_fixtures/test_utf8.txt >> ../test_tmp/expected.txt
    "../$RSUBOX" tail ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for text with UTF-8 codes"
    tail -n 10 ../test_fixtures/test_utf8.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail from 10th line and for text with UTF-8 codes"
    tail -n +10 ../test_fixtures/test_utf8.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -n +10 ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 100 bytes and small data"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" tail -c 100 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "abcdef" ../test_tmp/stdout.txt &&
    assert_file_line 4 2 "ghijkl" ../test_tmp/stdout.txt &&
    assert_file_line 5 3 "mnopqr" ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 100 bytes"
    tail -c 100 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -c 100 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 100 bytes and file with invalid UTF-8 codes"
    tail -c 100 ../test_fixtures/test_invalid_utf8.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -c 100 ../test_fixtures/test_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 100 bytes with minus and small data"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" tail -c -100 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "abcdef" ../test_tmp/stdout.txt &&
    assert_file_line 4 2 "ghijkl" ../test_tmp/stdout.txt &&
    assert_file_line 5 3 "mnopqr" ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 100 bytes with minus"
    tail -c 100 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -c -100 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 100 bytes with minus and file with invalid UTF-8 codes"
    tail -c 100 ../test_fixtures/test_invalid_utf8.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -c -100 ../test_fixtures/test_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail from 100th byte for small data"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" tail -c +100 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail from 100th byte"
    tail -c +100 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -c +100 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail from 100th byte for file with invalid UTF-8 codes"
    tail -c +100 ../test_fixtures/test_invalid_utf8.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -c +100 ../test_fixtures/test_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 15 lines and small data"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" tail -n 15 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "abcdef" ../test_tmp/stdout.txt &&
    assert_file_line 4 2 "ghijkl" ../test_tmp/stdout.txt &&
    assert_file_line 5 3 "mnopqr" ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 15 lines"
    tail -n 15 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -n 15 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes 2 lines and line without newline for 15 lines"
    echo "abcdef" > ../test_tmp/expected.txt
    echo "ghijkl" >> ../test_tmp/expected.txt
    echo -n "mnopqr" >> ../test_tmp/expected.txt
    (echo abcdef; echo ghijkl; echo -n mnopqr) | "../$RSUBOX" tail -n 15 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 15 lines with minus and small data"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" tail -n -15 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "abcdef" ../test_tmp/stdout.txt &&
    assert_file_line 4 2 "ghijkl" ../test_tmp/stdout.txt &&
    assert_file_line 5 3 "mnopqr" ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail for 15 lines with minus"
    tail -n 15 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -n -15 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes 2 lines and line without newline for 15 lines with minus"
    echo "abcdef" > ../test_tmp/expected.txt
    echo "ghijkl" >> ../test_tmp/expected.txt
    echo -n "mnopqr" >> ../test_tmp/expected.txt
    (echo abcdef; echo ghijkl; echo -n mnopqr) | "../$RSUBOX" tail -n -15 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail from 15th line for small data"
    (echo abcdef; echo ghijkl; echo mnopqr) | "../$RSUBOX" tail -n +15 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes tail from 15th line"
    tail -n +15 ../test_fixtures/test.txt > ../test_tmp/expected.txt
    "../$RSUBOX" tail -n +15 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail writes 2 lines and line without newline from 15th line"
    (echo abcdef; echo ghijkl; echo -n mnopqr) | "../$RSUBOX" tail -n +15 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tail "tail complains on non-existent file"
    "../$RSUBOX" tail xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test tail "tail complains on file that doesn't contain valid UTF-8"
    "../$RSUBOX" tail ../test_fixtures/test_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\.\./test_fixtures/test_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test

start_test tail "tail complains on file that doesn't contain valid UTF-8 from 10th line"
    "../$RSUBOX" tail -n +10 ../test_fixtures/test_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\.\./test_fixtures/test_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
