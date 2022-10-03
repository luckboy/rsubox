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
start_test uniq "uniq filters few lines from stdin"
    (echo abcdef; echo ghijkl; echo ghijkl; echo mnopqr) | "../$RSUBOX" uniq > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 abcdef ../test_tmp/stdout.txt &&
    assert_file_line 4 2 ghijkl ../test_tmp/stdout.txt &&
    assert_file_line 5 3 mnopqr ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters many lines from stdin"
    cat ../test_fixtures/test_uniq.txt | "../$RSUBOX" uniq > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_uniq_output.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines from file"
    "../$RSUBOX" uniq ../test_fixtures/test_uniq.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_uniq_output.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines from file and writes output file"
    "../$RSUBOX" uniq ../test_fixtures/test_uniq.txt output.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 output.txt &&
    assert_file_mode 5 '^-' output.txt &&
    assert_compare_files 6 ../test_fixtures/test_uniq_output.txt output.txt
end_test

start_test uniq "uniq filters lines from stdin and writes output file"
    cat ../test_fixtures/test_uniq.txt | "../$RSUBOX" uniq - output.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 output.txt &&
    assert_file_mode 5 '^-' output.txt &&
    assert_compare_files 6 ../test_fixtures/test_uniq_output.txt output.txt
end_test

start_test uniq "uniq filters lines from file with UTF-8 codes"
    "../$RSUBOX" uniq ../test_fixtures/test_uniq_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_uniq_output_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines and calculates repetitions"
    "../$RSUBOX" uniq -c ../test_fixtures/test_uniq.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_uniq_output_c.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq deletes lines which aren't repeated"
    "../$RSUBOX" uniq -d ../test_fixtures/test_uniq.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_uniq_output_d.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq deletes lines which are repeated"
    "../$RSUBOX" uniq -u ../test_fixtures/test_uniq.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_uniq_output_u.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines for ignored fields"
    (echo 'abc def 123'; echo 'ghi jkl 123'; echo 'abc def 456') | "../$RSUBOX" uniq -f 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'abc def 123' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'abc def 456' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines for ignored fields and first space charactacters"
    (echo '  abc def 123'; echo 'ghi jkl 123'; echo ' abc def 456') | "../$RSUBOX" uniq -f 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 '  abc def 123' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 ' abc def 456' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines for ignored fields and one field"
    (echo 'abc def 123'; echo 'ghi jkl 123'; echo 'abc') | "../$RSUBOX" uniq -f 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'abc def 123' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'abc' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines for zero ignored fields"
    (echo 'abc def 123'; echo 'ghi jkl 123'; echo 'abc def 456') | "../$RSUBOX" uniq -f 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'abc def 123' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'ghi jkl 123' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'abc def 456' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines for ignored characters"
    (echo abcdef; echo ghidef; echo ghijkl) | "../$RSUBOX" uniq -s 3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 abcdef ../test_tmp/stdout.txt &&
    assert_file_line 4 2 ghijkl ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines for zero ignored characters"
    (echo abcdef; echo ghidef; echo ghijkl) | "../$RSUBOX" uniq -s 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 abcdef ../test_tmp/stdout.txt &&
    assert_file_line 4 2 ghidef ../test_tmp/stdout.txt &&
    assert_file_line 5 3 ghijkl ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq filters lines for ignored characters and two characters"
    (echo abcdef; echo ghidef; echo gh) | "../$RSUBOX" uniq -s 3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 abcdef ../test_tmp/stdout.txt &&
    assert_file_line 4 2 gh ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test uniq "uniq complains on too many arguments"
    "../$RSUBOX" uniq xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
end_test

start_test uniq "uniq complains on non-existent file"
    "../$RSUBOX" uniq xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test uniq "uniq complains on file that doesn't contain valid UTF-8"
    "../$RSUBOX" uniq ../test_fixtures/test_uniq_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_uniq_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
