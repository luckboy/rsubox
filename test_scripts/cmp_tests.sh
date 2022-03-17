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
start_test cmp "cmp compares two files"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    echo abcdef > test2.txt
    echo xxijxx >> test2.txt
    "../$RSUBOX" cmp test1.txt test2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_content 2 "test1.txt test2.txt differ: char 8, line 2" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two big files"
    "../$RSUBOX" cmp ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_content 2 "../test_fixtures/test.txt ../test_fixtures/test_utf8.txt differ: char 2, line 1" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two same files"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    "../$RSUBOX" cmp test1.txt test1.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two big same files"
    "../$RSUBOX" cmp ../test_fixtures/test.txt ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two files for first file size less than second file size"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    echo abcdef > test2.txt
    echo ghijkl >> test2.txt
    echo mnopqr >> test2.txt
    "../$RSUBOX" cmp test1.txt test2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "EOF on test1.txt" ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two files for first file size greater than second file size"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    echo mnopqr >> test1.txt
    echo abcdef > test2.txt
    echo ghijkl >> test2.txt
    "../$RSUBOX" cmp test1.txt test2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "EOF on test2.txt" ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two files with verbose"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    echo abcdef > test2.txt
    echo xxijxx >> test2.txt
    "../$RSUBOX" cmp -l test1.txt test2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 "8 147 170" ../test_tmp/stdout.txt &&
    assert_file_line 4 2 "9 150 170" ../test_tmp/stdout.txt &&
    assert_file_line 5 3 "12 153 170" ../test_tmp/stdout.txt &&
    assert_file_line 6 4 "13 154 170" ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two same files with verbose"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    "../$RSUBOX" cmp -l test1.txt test1.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two files with silent"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    echo abcdef > test2.txt
    echo xxijxx >> test2.txt
    "../$RSUBOX" cmp -s test1.txt test2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two same files with silent"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    "../$RSUBOX" cmp -s test1.txt test1.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two files with silent for first file size less than second file size"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    echo abcdef > test2.txt
    echo ghijkl >> test2.txt
    echo mnopqr >> test2.txt
    "../$RSUBOX" cmp -s test1.txt test2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares two files with silent for first file size greater than second file size"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    echo mnopqr >> test1.txt
    echo abcdef > test2.txt
    echo ghijkl >> test2.txt
    "../$RSUBOX" cmp -s test1.txt test2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares stdin and file"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    (echo abcdef; echo xxijxx) | "../$RSUBOX" cmp test1.txt - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_content 2 "test1.txt - differ: char 8, line 2" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares file and stdin"
    echo abcdef > test1.txt
    echo xxijxx >> test1.txt
    (echo abcdef; echo ghijkl) | "../$RSUBOX" cmp - test1.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_content 2 "- test1.txt differ: char 8, line 2" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp compares stdin and stdin"
    "../$RSUBOX" cmp - - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp complains on too few arguments"
    "../$RSUBOX" cmp > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test cmp "cmp complains on too few arguments for one file"
    "../$RSUBOX" cmp xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test cmp "cmp complains on too many arguments"
    "../$RSUBOX" cmp xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
end_test

start_test cmp "cmp complains on incompatible options"
    "../$RSUBOX" cmp -ls xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Incompatible options' ../test_tmp/stderr.txt
end_test

start_test cmp "cmp complains on non-existent first file"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    "../$RSUBOX" cmp xxx test1.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test cmp "cmp complains on non-existent second file"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    "../$RSUBOX" cmp test1.txt xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test cmp "cmp complains on non-existent first file for silent"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    "../$RSUBOX" cmp -s xxx test1.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test cmp "cmp complains on non-existent second file for silent"
    echo abcdef > test1.txt
    echo ghijkl >> test1.txt
    "../$RSUBOX" cmp -s test1.txt xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test
