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
start_test comm "comm selects or rejects lines"
    "../$RSUBOX" comm ../test_fixtures/test_comm1.txt ../test_fixtures/test_comm2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_comm_output.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm selects or rejects lines from stdin as first file"
    cat ../test_fixtures/test_comm1.txt | "../$RSUBOX" comm - ../test_fixtures/test_comm2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_comm_output.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm selects or rejects lines from stdin as second file"
    cat ../test_fixtures/test_comm2.txt | "../$RSUBOX" comm ../test_fixtures/test_comm1.txt - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_comm_output.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm selects or rejects lines with UTF-8 codes"
    "../$RSUBOX" comm ../test_fixtures/test_comm1_utf8.txt ../test_fixtures/test_comm2_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_comm_output_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm selects or rejects lines for -1 option"
    "../$RSUBOX" comm -1 ../test_fixtures/test_comm1.txt ../test_fixtures/test_comm2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_comm_output1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm selects or rejects lines for -2 option"
    "../$RSUBOX" comm -2 ../test_fixtures/test_comm1.txt ../test_fixtures/test_comm2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_comm_output2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm selects or rejects lines for -1 and -2 options"
    "../$RSUBOX" comm -12 ../test_fixtures/test_comm1.txt ../test_fixtures/test_comm2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_comm_output12.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm selects or rejects lines for -3 option"
    "../$RSUBOX" comm -3 ../test_fixtures/test_comm1.txt ../test_fixtures/test_comm2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_comm_output3.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm selects or rejects lines for -1, -2 and -3 options"
    "../$RSUBOX" comm -123 ../test_fixtures/test_comm1.txt ../test_fixtures/test_comm2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test comm "comm complains on non-existent first file"
    echo yyy > yyy
    "../$RSUBOX" comm xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test comm "comm complains on non-existent second file"
    echo xxx > xxx
    "../$RSUBOX" comm xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^yyy: ' ../test_tmp/stderr.txt
end_test

start_test comm "comm complains on first file that doesn't contain valid UTF-8"
    "../$RSUBOX" comm ../test_fixtures/test_comm1_invalid_utf8.txt ../test_fixtures/test_comm2_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_comm1_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test

start_test comm "comm complains on second file that doesn't contain valid UTF-8"
    "../$RSUBOX" comm ../test_fixtures/test_comm1_utf8.txt ../test_fixtures/test_comm2_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_comm2_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
