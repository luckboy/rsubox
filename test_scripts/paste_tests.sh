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
start_test paste "paste pastes small files"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    echo ghijkl > test2.txt
    echo mnopqr >> test2.txt
    echo mnopqr > test3.txt
    echo stuvwx >> test3.txt
    paste -d '\t' test1.txt test2.txt test3.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste test1.txt test2.txt test3.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes big files"
    paste -d '\t' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes big files for delimiters"
    paste -d '12' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste -d '12' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes big files for delimiters with zero character"
    paste -d '1\0' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste -d '1\0' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes big files for delimiters with newline"
    paste -d '1\n' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste -d '1\n' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes big files for delimiters with tab"
    paste -d '1\t' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste -d '1\t' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes big files for delimiters with backslash"
    paste -d '1\\' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste -d '1\\' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes files for serial"
    paste -d '\t' -s ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste -s ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes files for delimiters and serial"
    paste -d '12' -s ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    "../$RSUBOX" paste -d '12' -s ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes file and file with UTF-8 codes"
    "../$RSUBOX" paste ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste1_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_paste_pasted_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes file and file with UTF-8 codes for serial"
    "../$RSUBOX" paste -s ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste1_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_paste_pasted_s_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes files with data from stdin"
    paste -d '\t' ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    cat ../test_fixtures/test_paste2.txt | "../$RSUBOX" paste ../test_fixtures/test_paste1.txt - ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste pastes files with data from stdin for serial"
    paste -d '\t' -s ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste2.txt ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/expected.txt
    cat ../test_fixtures/test_paste2.txt | "../$RSUBOX" paste -s ../test_fixtures/test_paste1.txt - ../test_fixtures/test_paste3.txt ../test_fixtures/test_paste4.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test paste "paste complains on too few arguments"
    "../$RSUBOX" paste > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test paste "paste complains on non-existent file"
    "../$RSUBOX" paste xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test paste "paste complains on non-existent file for serial"
    "../$RSUBOX" paste -s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test paste "paste complains on file that doesn't contain valid UTF-8"
    "../$RSUBOX" paste ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste1_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_paste1_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test

start_test paste "paste complains on file that doesn't contain valid UTF-8 for serial"
    "../$RSUBOX" paste -s ../test_fixtures/test_paste1.txt ../test_fixtures/test_paste1_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_paste1_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
