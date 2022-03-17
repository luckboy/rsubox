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
start_test cut "cut writes cutted data from stdin"
    printf 'abcdef\tghijkl\n' > ../test_tmp/expected.txt
    (printf 'abcdef\tghijkl\tmnopqr\n') | "../$RSUBOX" cut -f 1,2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted more data from stdin"
    cat ../test_fixtures/test_cut_tab.txt | "../$RSUBOX" cut -f 1,2,3,5,6,8,9,10,11,12 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_tab_fields.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file"
    "../$RSUBOX" cut -f 1,2,3,5,6,8,9,10,11,12 ../test_fixtures/test_cut_tab.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_tab_fields.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes two cutted files"
    cat ../test_fixtures/test_cut_tab_fields.txt > ../test_tmp/expected.txt
    cat ../test_fixtures/test_cut2_tab_fields.txt >> ../test_tmp/expected.txt
    "../$RSUBOX" cut -f 1,2,3,5,6,8,9,10,11,12 ../test_fixtures/test_cut_tab.txt ../test_fixtures/test_cut2_tab.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for unsorted fields"
    "../$RSUBOX" cut -f 5-6,2-3,8-11,-2,10-,9 ../test_fixtures/test_cut_tab.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_tab_fields.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for second unsorted fields"
    "../$RSUBOX" cut -f 5,1,6,2,2-3,8-11,2,10-,9 ../test_fixtures/test_cut_tab.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_tab_fields.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for third unsorted fields"
    "../$RSUBOX" cut -f 5,6,-2,-3,10-,8- ../test_fixtures/test_cut_tab.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_tab_fields.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted data from stdin for two imposed ranges"
    printf 'abcdef\tghijkl\tmnopqr\n' > ../test_tmp/expected.txt
    (printf 'abcdef\tghijkl\tmnopqr\n') | "../$RSUBOX" cut -f -2,1- > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for bytes"
    "../$RSUBOX" cut -b -20,40-60,80-90,100- ../test_fixtures/test_cut_space.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_space_bytes.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file with UTF-8 codes for bytes"
    "../$RSUBOX" cut -b -15,35-50,85-95,100- ../test_fixtures/test_cut_space_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_space_bytes_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for bytes and ignored -n option"
    "../$RSUBOX" cut -b -20,40-60,80-90,100- -n ../test_fixtures/test_cut_space.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_space_bytes.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file with UTF-8 codes for bytes and ignored -n option"
    "../$RSUBOX" cut -b -15,35-50,85-95,100- -n ../test_fixtures/test_cut_space_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_space_bytes_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for characters"
    "../$RSUBOX" cut -c -20,50-70,80-90,100- ../test_fixtures/test_cut_space.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_space_chars.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file with UTF-8 codes for bytes"
    "../$RSUBOX" cut -c -15,30-45,80-95,100- ../test_fixtures/test_cut_space_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_space_chars_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for fields"
    "../$RSUBOX" cut -f -3,5-6,8- ../test_fixtures/test_cut_tab.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_tab_fields.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for fields and space delimiter"
    "../$RSUBOX" cut -f -3,5-7,9- -d ' ' ../test_fixtures/test_cut_space.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_space_fields.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file with UTF-8 codes for fields and space delimiter"
    "../$RSUBOX" cut -f -3,5-7,9- -d ' ' ../test_fixtures/test_cut_space_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_space_fields_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for fields and comma delimiter"
    "../$RSUBOX" cut -f -2,4-6,8- -d ',' ../test_fixtures/test_cut_comma.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_comma_fields.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file for fields, comma delimiter and only delimited flag"
    "../$RSUBOX" cut -f -2,4-6,8- -d ',' -s ../test_fixtures/test_cut_comma.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_cut_comma_fields_s.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted data from stdin without only delimited flag"
    printf 'abcdef\nmnopqr\tstuvwx\n' > ../test_tmp/expected.txt
    (printf 'abcdef\nghijkl\tmnopqr\tstuvwx\n') | "../$RSUBOX" cut -f 2,3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted data from stdin with only delimited flag"
    printf 'mnopqr\tstuvwx\n' > ../test_tmp/expected.txt
    (printf 'abcdef\nghijkl\tmnopqr\tstuvwx\n') | "../$RSUBOX" cut -f 2,3 -s > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted file and data from stdin"
    cat ../test_fixtures/test_cut_tab_fields.txt > ../test_tmp/expected.txt
    cat ../test_fixtures/test_cut2_tab_fields.txt >> ../test_tmp/expected.txt
    cat ../test_fixtures/test_cut2_tab.txt | "../$RSUBOX" cut -f 1,2,3,5,6,8,9,10,11,12 ../test_fixtures/test_cut_tab.txt - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut writes cutted line without newline from stdin"
    printf 'abcdef\nmnopqr\tstuvwx\n' > ../test_tmp/expected.txt
    (printf 'abcdef\nghijkl\tmnopqr\tstuvwx') | "../$RSUBOX" cut -f 2,3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on no list"
    echo xxx > xxx
    "../$RSUBOX" cut xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'No list' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on empty list"
    echo xxx > xxx
    "../$RSUBOX" cut -f '' xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^cannot parse' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on element that is zero"
    echo xxx > xxx
    "../$RSUBOX" cut -f 0,1 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Element is zero' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on high that is zero"
    echo xxx > xxx
    "../$RSUBOX" cut -f -0,1 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'High is zero' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on low that is zero"
    echo xxx > xxx
    "../$RSUBOX" cut -f 0-,1 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Low is zero' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on high that is zero for limited range"
    echo xxx > xxx
    "../$RSUBOX" cut -f 2-0,1 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'High is zero' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on low that is zero for limited range"
    echo xxx > xxx
    "../$RSUBOX" cut -f 0-2,1 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Low is zero' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on invalid range"
    echo xxx > xxx
    "../$RSUBOX" cut -f 2-1 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid range' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on invalid range without low and high"
    echo xxx > xxx
    "../$RSUBOX" cut -f - xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid range' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on element that is invalid number"
    echo xxx > xxx
    "../$RSUBOX" cut -f xxx xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on delimiter that isn't single character"
    echo xxx > xxx
    "../$RSUBOX" cut -f 1,2 -d xy xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Delimiter isn'"'"'t single character' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on non-existent file"
    "../$RSUBOX" cut -f 1,2 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test cut "cut complains on file that doesn't contain valid UTF-8"
    "../$RSUBOX" cut -f -3,5-6,8- ../test_fixtures/test_cut_space_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_cut_space_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
