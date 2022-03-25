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
start_test fold "fold folds lines from stdin"
    echo abcdef > test.txt
    echo ghijkl >> test.txt
    cat test.txt | "../$RSUBOX" fold > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds many lines from stdin"
    cat ../test_fixtures/test.txt | "../$RSUBOX" fold > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines from one file"
    "../$RSUBOX" fold ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines from file and file with UTF-8 codes"
    cat ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/expected.txt
    "../$RSUBOX" fold ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines from file and stdin"
    cat ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/expected.txt
    cat ../test_fixtures/test_utf8.txt | "../$RSUBOX" fold ../test_fixtures/test.txt - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines from file for width"
    "../$RSUBOX" fold -w 40 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_folded_40.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines from file for width and space option"
    "../$RSUBOX" fold -w 40 -s ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_folded_40_s.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines from file for width and byte option"
    "../$RSUBOX" fold -w 40 -b ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_folded_40.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines from file for width, byte option and space option"
    "../$RSUBOX" fold -w 40 -bs ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_folded_40_s.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines with special characters"
    printf 'abc\b\b1234567890123456789012345\n' > test.txt
    printf 'abc\r1234567890123456789012345\n' >> test.txt
    printf '\t123456789\t0123456789012345\n' >> test.txt
    printf 'abc\b\b1234567890123456789\n012345\n' > ../test_tmp/expected.txt
    printf 'abc\r12345678901234567890\n12345\n' >> ../test_tmp/expected.txt
    printf '\t123456789\n\t012345678901\n2345\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" fold -w 20 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds lines with special characters for byte option"
    printf 'abc\b\b1234567890123456789012345\n' > test.txt
    printf 'abc\r1234567890123456789012345\n' >> test.txt
    printf '\t123456789\t0123456789012345\n' >> test.txt
    printf 'abc\b\b123456789012345\n6789012345\n' > ../test_tmp/expected.txt
    printf 'abc\r1234567890123456\n789012345\n' >> ../test_tmp/expected.txt
    printf '\t123456789\t012345678\n9012345\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" fold -w 20 -b test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold folds line and line without newline"
    echo abcdef > test.txt
    echo -n ghijkl >> test.txt
    "../$RSUBOX" fold test.txt> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test fold "fold complains on non-existent file"
    "../$RSUBOX" fold xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test fold "fold complains on file that doesn't contain valid UTF-8"
    "../$RSUBOX" fold ../test_fixtures/test_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
