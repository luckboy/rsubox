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
start_test expand "expand expands lines from stdin"
    echo abcdef > test.txt
    echo ghijkl >> test.txt
    cat test.txt | "../$RSUBOX" expand > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands many lines from stdin"
    cat ../test_fixtures/test.txt | "../$RSUBOX" expand > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands lines from one file"
    "../$RSUBOX" expand ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands lines from file and file with UTF-8 codes"
    cat ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/expected.txt
    "../$RSUBOX" expand ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands lines from file and stdin"
    cat ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/expected.txt
    cat ../test_fixtures/test_utf8.txt | "../$RSUBOX" expand ../test_fixtures/test.txt - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands lines"
    printf '\tabc\tdef\tghi\n' > test.txt
    printf '\tdef\t\b\bghi\tjkl\n' >> test.txt
    printf '\b\babc\n' >> test.txt
    printf '        abc     def     ghi\n' > ../test_tmp/expected.txt
    printf '        def     \b\bghi       jkl\n' >> ../test_tmp/expected.txt
    printf '\b\babc\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" expand test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands lines for one tab stop"
    printf '\tabc\tdef\tghi\n' > test.txt
    printf '\tdef\t\b\bghi\tjkl\n' >> test.txt
    printf '\b\babc\n' >> test.txt
    printf '    abc def ghi\n' > ../test_tmp/expected.txt
    printf '    def \b\bghi   jkl\n' >> ../test_tmp/expected.txt
    printf '\b\babc\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" expand -t 4 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands lines for two tab stops"
    printf '\tabc\tdef\tghi\n' > test.txt
    printf '\tdef\t\b\bghi\tjkl\n' >> test.txt
    printf '\b\babc\n' >> test.txt
    printf '        abc def ghi\n' > ../test_tmp/expected.txt
    printf '        def \b\bghi jkl\n' >> ../test_tmp/expected.txt
    printf '\b\babc\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" expand -t 8,12 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands lines for three tab stops"
    printf '\tabc\tdef\tghi\n' > test.txt
    printf '\tdef\t\b\bghi\tjkl\n' >> test.txt
    printf '\b\babc\n' >> test.txt
    printf '        abc def ghi\n' > ../test_tmp/expected.txt
    printf '        def \b\bghi   jkl\n' >> ../test_tmp/expected.txt
    printf '\b\babc\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" expand -t 8,12,16 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand expands lines for two tab stops which are blank seperated"
    printf '\tabc\tdef\tghi\n' > test.txt
    printf '\tdef\t\b\bghi\tjkl\n' >> test.txt
    printf '\b\babc\n' >> test.txt
    printf '        abc def ghi\n' > ../test_tmp/expected.txt
    printf '        def \b\bghi jkl\n' >> ../test_tmp/expected.txt
    printf '\b\babc\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" expand -t '8 12' test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expand "expand complains on tab stop is zero"
    echo xxx > xxx
    "../$RSUBOX" expand -t 0 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Tab stop is zero' ../test_tmp/stderr.txt
end_test

start_test expand "expand complains on invalid number"
    echo xxx > xxx
    "../$RSUBOX" expand -t xxx xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test expand "expand complains on tab stops must be ascending for equal tab stops"
    echo xxx > xxx
    "../$RSUBOX" expand -t 8,8 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Tab stops must be ascending' ../test_tmp/stderr.txt
end_test

start_test expand "expand complains on non-existent file"
    "../$RSUBOX" expand xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test expand "expand complains on file that doesn't contain valid UTF-8"
    "../$RSUBOX" expand ../test_fixtures/test_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
