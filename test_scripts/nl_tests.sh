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
start_test nl "nl writes numbered lines from stdin"
    printf '     1\tabcdef\n' > ../test_tmp/expected.txt
    printf '     2\tghijkl\n' >> ../test_tmp/expected.txt
    (echo abcdef; echo ghijkl) | "../$RSUBOX" nl > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from more stdin"
    cat ../test_fixtures/test.txt | "../$RSUBOX" nl > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_numbered.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from one file"
    "../$RSUBOX" nl ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_numbered.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file and file with UTF-8 codes"
    "../$RSUBOX" nl ../test_fixtures/test.txt ../test_fixtures/test_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test11_numbered_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages"
    "../$RSUBOX" nl ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for numbering types"
    "../$RSUBOX" nl -b a -f t -h t ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for numbering type with regular expression"
    "../$RSUBOX" nl -b pblabla ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered3.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for join blank line number"
    "../$RSUBOX" nl -b a -l 2 ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for left align"
    "../$RSUBOX" nl -n ln ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered_ln.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for right align"
    "../$RSUBOX" nl -n rn ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered_rn.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for right align with zeros"
    "../$RSUBOX" nl -n rz ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered_rz.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for other paremeters"
    "../$RSUBOX" nl -i 2 -s '. ' -v 10 -w 4 ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered5.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for no renumber option"
    "../$RSUBOX" nl -p ../test_fixtures/test_nl.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl_numbered6.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl writes numbered lines from file with pages for other delimiter"
    "../$RSUBOX" nl -d '!+' ../test_fixtures/test_nl2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_nl2_numbered.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nl "nl complains on invalid numbering type"
    "../$RSUBOX" nl -b x xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid numbering type' ../test_tmp/stderr.txt
end_test

start_test nl "nl complains on invalid number format"
    "../$RSUBOX" nl -n x xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid number format' ../test_tmp/stderr.txt
end_test

start_test nl "nl complains on non-existent file"
    "../$RSUBOX" nl xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test nl "nl complains on file that doesn't contain valid UTF-8"
    "../$RSUBOX" nl ../test_fixtures/test_invalid_utf8.txt  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^\.\./test_fixtures/test_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
