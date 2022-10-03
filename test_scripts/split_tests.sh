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
start_test split "split splits data from stdin and writes file"
    echo abcdef | "../$RSUBOX" split > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_file_content 6 abcdef xaa &&
    assert_non_existent_file 4 xab
end_test

start_test split "split splits more data from stdin and writes file"
    cat ../test_fixtures/test.txt | "../$RSUBOX" split > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_compare_files 6 ../test_fixtures/test.txt xaa &&
    assert_non_existent_file 4 xab
end_test

start_test split "split splits file and writes file"
    "../$RSUBOX" split ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_compare_files 6 ../test_fixtures/test.txt xaa &&
    assert_non_existent_file 4 xab
end_test

start_test split "split splits file and writes file for name"
    "../$RSUBOX" split ../test_fixtures/test.txt xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xxxaa &&
    assert_file_mode 5 '^-' xxxaa &&
    assert_compare_files 6 ../test_fixtures/test.txt xxxaa &&
    assert_non_existent_file 4 xxxab
end_test

start_test split "split splits data from stdin and writes file for name"
    cat ../test_fixtures/test.txt | "../$RSUBOX" split - xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xxxaa &&
    assert_file_mode 5 '^-' xxxaa &&
    assert_compare_files 6 ../test_fixtures/test.txt xxxaa &&
    assert_non_existent_file 4 xxxab
end_test

start_test split "split splits file and writes file for suffix length"
    "../$RSUBOX" split -a 3 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaaa &&
    assert_file_mode 5 '^-' xaaa &&
    assert_compare_files 6 ../test_fixtures/test.txt xaaa &&
    assert_non_existent_file 4 xaab
end_test

start_test split "split splits file and writes file with UTF-8 codes"
    "../$RSUBOX" split ../test_fixtures/test_utf8.txt> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_compare_files 6 ../test_fixtures/test_utf8.txt xaa &&
    assert_non_existent_file 4 xab
end_test

start_test split "split splits file and writes file with invalid UTF-8 codes"
    "../$RSUBOX" split ../test_fixtures/test_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_compare_files 6 ../test_fixtures/test_invalid_utf8.txt xaa &&
    assert_non_existent_file 4 xab
end_test

start_test split "split splits file and writes files for bytes"
    "../$RSUBOX" split -b 1024 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_compare_files 6 ../test_fixtures/test_splitted_b_aa.txt xaa &&
    assert_existent_file 7 xab &&
    assert_file_mode 8 '^-' xab &&
    assert_compare_files 9 ../test_fixtures/test_splitted_b_ab.txt xab &&
    assert_existent_file 10 xac &&
    assert_file_mode 11 '^-' xac &&
    assert_compare_files 12 ../test_fixtures/test_splitted_b_ac.txt xac &&
    assert_existent_file 13 xad &&
    assert_file_mode 14 '^-' xad &&
    assert_compare_files 15 ../test_fixtures/test_splitted_b_ad.txt xad &&
    assert_existent_file 16 xae &&
    assert_file_mode 17 '^-' xae &&
    assert_compare_files 18 ../test_fixtures/test_splitted_b_ae.txt xae &&
    assert_non_existent_file 19 xaf
end_test

start_test split "split splits file and writes files for kilo byte"
    "../$RSUBOX" split -b 1k ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_compare_files 6 ../test_fixtures/test_splitted_b_aa.txt xaa &&
    assert_existent_file 7 xab &&
    assert_file_mode 8 '^-' xab &&
    assert_compare_files 9 ../test_fixtures/test_splitted_b_ab.txt xab &&
    assert_existent_file 10 xac &&
    assert_file_mode 11 '^-' xac &&
    assert_compare_files 12 ../test_fixtures/test_splitted_b_ac.txt xac &&
    assert_existent_file 13 xad &&
    assert_file_mode 14 '^-' xad &&
    assert_compare_files 15 ../test_fixtures/test_splitted_b_ad.txt xad &&
    assert_existent_file 16 xae &&
    assert_file_mode 17 '^-' xae &&
    assert_compare_files 18 ../test_fixtures/test_splitted_b_ae.txt xae &&
    assert_non_existent_file 19 xaf
end_test

start_test split "split splits file and writes file for mega byte"
    "../$RSUBOX" split -b 1m ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_compare_files 6 ../test_fixtures/test.txt xaa &&
    assert_non_existent_file 4 xab
end_test

start_test split "split splits file and writes files for lines"
    "../$RSUBOX" split -l 20 ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_compare_files 6 ../test_fixtures/test_splitted_l_aa.txt xaa &&
    assert_existent_file 7 xab &&
    assert_file_mode 8 '^-' xab &&
    assert_compare_files 9 ../test_fixtures/test_splitted_l_ab.txt xab &&
    assert_existent_file 10 xac &&
    assert_file_mode 11 '^-' xac &&
    assert_compare_files 12 ../test_fixtures/test_splitted_l_ac.txt xac &&
    assert_existent_file 13 xad &&
    assert_file_mode 14 '^-' xad &&
    assert_compare_files 15 ../test_fixtures/test_splitted_l_ad.txt xad &&
    assert_non_existent_file 16 xae
end_test

start_test split "split splits file and writes file for equal last lines"
    echo abc > test.txt
    echo def >> test.txt
    echo ghi >> test.txt
    echo jkl >> test.txt
    "../$RSUBOX" split -l 2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 xaa &&
    assert_file_mode 5 '^-' xaa &&
    assert_file_line_count 6 2 xaa &&
    assert_file_line 7 1 abc xaa &&
    assert_file_line 8 2 def xaa &&
    assert_existent_file 9 xab &&
    assert_file_mode 10 '^-' xab &&
    assert_file_line_count 10 2 xab &&
    assert_file_line 11 1 ghi xab &&
    assert_file_line 12 2 jkl xab &&
    assert_non_existent_file 13 xac
end_test

start_test split "split complains on too many arguments"
    "../$RSUBOX" split xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
    assert_non_existent_file 4 xaa
end_test

start_test split "split complains on invalid suffix length number"
    "../$RSUBOX" split -a xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
    assert_non_existent_file 4 xaa
end_test

start_test split "split complains on invalid byte number"
    "../$RSUBOX" split -b xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
    assert_non_existent_file 4 xaa
end_test

start_test split "split complains on invalid line number"
    "../$RSUBOX" split -l xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
    assert_non_existent_file 4 xaa
end_test

start_test split "split complains on non-existent file"
    "../$RSUBOX" split xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
    assert_non_existent_file 4 xaa
end_test
