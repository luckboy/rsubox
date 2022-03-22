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
start_test sort "sort sorts few lines from stdin"
    (echo mnopqr; echo abcdef; echo ghijkl) | "../$RSUBOX" sort > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 abcdef ../test_tmp/stdout.txt &&
    assert_file_line 4 2 ghijkl ../test_tmp/stdout.txt &&
    assert_file_line 5 3 mnopqr ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts many lines from stdin"
    cat ../test_fixtures/test_sort.txt | "../$RSUBOX" sort > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort_sorted.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines from one file"
    "../$RSUBOX" sort ../test_fixtures/test_sort.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort_sorted.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines from two files"
    "../$RSUBOX" sort ../test_fixtures/test_sort.txt ../test_fixtures/test_sort2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort12_sorted.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines from file for unique option"
    "../$RSUBOX" sort -u ../test_fixtures/test_sort.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort_sorted_u.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines from file with UTF-8 codes"
    "../$RSUBOX" sort ../test_fixtures/test_sort_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort_sorted_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines from file and writes output file"
    "../$RSUBOX" sort -o test.txt ../test_fixtures/test_sort.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 test.txt &&
    assert_file_mode 5 '^-' test.txt &&
    assert_compare_files 6 ../test_fixtures/test_sort_sorted.txt test.txt
end_test

start_test sort "sort sorts lines from file and stdin"
    cat ../test_fixtures/test_sort2.txt | "../$RSUBOX" sort ../test_fixtures/test_sort.txt - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort12_sorted.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort checks lines from stdin"
    cat ../test_fixtures/test_sort_sorted.txt | "../$RSUBOX" sort -c > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort checks whether lines are sorted for sorted lines"
    "../$RSUBOX" sort -c ../test_fixtures/test_sort_sorted.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort checks whether lines are sorted for unsorted lines"
    "../$RSUBOX" sort -c ../test_fixtures/test_sort.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort checks whether lines are sorted for unique sorted lines and unique option"
    "../$RSUBOX" sort -cu ../test_fixtures/test_sort_sorted_u.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort checks whether lines are sorted for non-unique sorted lines and unique option"
    "../$RSUBOX" sort -cu ../test_fixtures/test_sort_sorted.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort checks whether lines are sorted for unsorted lines and unique option"
    "../$RSUBOX" sort -cu ../test_fixtures/test_sort.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort checks whether lines with UTF-8 codes are sorted for unsorted lines"
    "../$RSUBOX" sort -c ../test_fixtures/test_sort_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort checks lines from stdin for minus"
    cat ../test_fixtures/test_sort_sorted.txt | "../$RSUBOX" sort -c - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort merges lines from two files"
    "../$RSUBOX" sort -m ../test_fixtures/test_sort_sorted.txt ../test_fixtures/test_sort2_sorted.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort12_sorted.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort merges lines from three files with UTF-8 codes"
    "../$RSUBOX" sort -m ../test_fixtures/test_sort_sorted.txt ../test_fixtures/test_sort2_sorted.txt ../test_fixtures/test_sort_sorted_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort121_sorted_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort merges lines from two files for unique option"
    "../$RSUBOX" sort -mu ../test_fixtures/test_sort_sorted.txt ../test_fixtures/test_sort2_sorted.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort12_sorted_u.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort merges lines from two files and writes output file"
    "../$RSUBOX" sort -o test.txt ../test_fixtures/test_sort_sorted.txt ../test_fixtures/test_sort2_sorted.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
    assert_existent_file 4 test.txt &&
    assert_file_mode 5 '^-' test.txt &&
    assert_compare_files 6 ../test_fixtures/test_sort12_sorted.txt test.txt
end_test

start_test sort "sort merges lines from file and stdin"
    cat ../test_fixtures/test_sort2_sorted.txt | "../$RSUBOX" sort -m ../test_fixtures/test_sort_sorted.txt - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_sort12_sorted.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for default order"
    echo bbbb > test.txt
    echo aaaa >> test.txt
    echo dddd >> test.txt
    echo cccc >> test.txt
    "../$RSUBOX" sort test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 aaaa ../test_tmp/stdout.txt &&
    assert_file_line 4 2 bbbb ../test_tmp/stdout.txt &&
    assert_file_line 5 3 cccc ../test_tmp/stdout.txt &&
    assert_file_line 6 4 dddd ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for numeric order"
    echo aaaa > test.txt
    echo 123 >> test.txt
    echo 2345bb >> test.txt
    echo -123 >> test.txt
    "../$RSUBOX" sort -n test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 -123 ../test_tmp/stdout.txt &&
    assert_file_line 4 2 aaaa ../test_tmp/stdout.txt &&
    assert_file_line 5 3 123 ../test_tmp/stdout.txt &&
    assert_file_line 6 4 2345bb ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for default order and reverse option"
    echo bbbb > test.txt
    echo aaaa >> test.txt
    echo dddd >> test.txt
    echo cccc >> test.txt
    "../$RSUBOX" sort -r test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 dddd ../test_tmp/stdout.txt &&
    assert_file_line 4 2 cccc ../test_tmp/stdout.txt &&
    assert_file_line 5 3 bbbb ../test_tmp/stdout.txt &&
    assert_file_line 6 4 aaaa ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for numeric order and reverse option"
    echo aaaa > test.txt
    echo 123 >> test.txt
    echo 2345bb >> test.txt
    echo -123 >> test.txt
    "../$RSUBOX" sort -nr test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 2345bb ../test_tmp/stdout.txt &&
    assert_file_line 4 2 123 ../test_tmp/stdout.txt &&
    assert_file_line 5 3 aaaa ../test_tmp/stdout.txt &&
    assert_file_line 6 4 -123 ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for -b option"
    printf 'bbbb\n' > test.txt
    printf '  aaaa\n' >> test.txt
    printf 'dddd\n' >> test.txt
    printf '\tcccc\n' >> test.txt
    printf '  aaaa\n' > ../test_tmp/expected.txt
    printf 'bbbb\n' >> ../test_tmp/expected.txt
    printf '\tcccc\n' >> ../test_tmp/expected.txt
    printf 'dddd\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" sort -b test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for -d option"
    printf 'bb12\n' > test.txt
    printf '  aaaa\n' >> test.txt
    printf 'bb!34\n' >> test.txt
    printf '\tcccc\n' >> test.txt
    printf '\tcccc\n' > ../test_tmp/expected.txt
    printf '  aaaa\n' >> ../test_tmp/expected.txt
    printf 'bb12\n' >> ../test_tmp/expected.txt
    printf 'bb!34\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" sort -d test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for -f option"
    echo AAbb > test.txt
    echo aaaa >> test.txt
    echo CCdd >> test.txt
    echo cccc >> test.txt
    "../$RSUBOX" sort -f test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 aaaa ../test_tmp/stdout.txt &&
    assert_file_line 4 2 AAbb ../test_tmp/stdout.txt &&
    assert_file_line 5 3 cccc ../test_tmp/stdout.txt &&
    assert_file_line 6 4 CCdd ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for -i option"
    printf ' aaaa\n' > test.txt
    printf 'aaaa\n' >> test.txt
    printf 'bbbb\n' >> test.txt
    printf '\raa12\n' >> test.txt
    printf ' aaaa\n' > ../test_tmp/expected.txt
    printf '\raa12\n' >> ../test_tmp/expected.txt
    printf 'aaaa\n' >> ../test_tmp/expected.txt
    printf 'bbbb\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" sort -i test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for first key"
    echo aaaa bbbb aaaa > test.txt
    echo bbbb aaaa bbbb >> test.txt
    echo cccc dddd cccc >> test.txt
    echo dddd cccc dddd >> test.txt
    "../$RSUBOX" sort -k 2,2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa bbbb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd cccc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for second key"
    echo aaaa aaaa bbbb > test.txt
    echo bbbb aaaa aaaa >> test.txt
    echo cccc dddd cccc >> test.txt
    echo dddd cccc dddd >> test.txt
    "../$RSUBOX" sort -k 2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd cccc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for second key"
    echo aaaa aaaa bbbb > test.txt
    echo bbbb aaaa aaaa >> test.txt
    echo cccc dddd cccc >> test.txt
    echo dddd cccc dddd >> test.txt
    "../$RSUBOX" sort -k 2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd cccc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for third key"
    echo bbbb aaaa aaaa bbbb > test.txt
    echo aaaa aaaa aaaa aaaa >> test.txt
    echo cccc aaaa aaaa cccc >> test.txt
    echo aaaa dddd dddd aaaa >> test.txt
    "../$RSUBOX" sort -k 2,3 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa aaaa aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'cccc aaaa aaaa cccc' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'aaaa dddd dddd aaaa' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for fourth key"
    echo bbbb aaaa aaaa > test.txt
    echo aaaa aaaa >> test.txt
    echo cccc aaaa aaaa>> test.txt
    echo aaaa dddd >> test.txt
    "../$RSUBOX" sort -k 2,3 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 4 1 'aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 3 2 'bbbb aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'cccc aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'aaaa dddd' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for first key with character positions"
    echo aaaa aabbbaa aaaa > test.txt
    echo bbbb bbaaabb bbbb >> test.txt
    echo cccc ccdddcc cccc >> test.txt
    echo dddd ddcccdd dddd >> test.txt
    "../$RSUBOX" sort -k 2.3,2.5 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb bbaaabb bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa aabbbaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd ddcccdd dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc ccdddcc cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for second key with character position"
    echo aaaa aaaa bbbb > test.txt
    echo bbbb baaa aaaa >> test.txt
    echo cccc cddd cccc >> test.txt
    echo dddd dccc dddd >> test.txt
    "../$RSUBOX" sort -k 2.2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb baaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd dccc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc cddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for third key with character positions"
    echo bbbb bbaa aaab bbbb > test.txt
    echo aaaa aaaa aaaa aaaa >> test.txt
    echo cccc ccaa aaac cccc >> test.txt
    echo aaaa aadd ddda aaaa >> test.txt
    "../$RSUBOX" sort -k 2.3,3.3 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb bbaa aaab bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa aaaa aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'cccc ccaa aaac cccc' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'aaaa aadd ddda aaaa' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for fourth key with character positions"
    echo bbbb bbaa bbbb bbbb > test.txt
    echo aaaa aaaa aaaa aaaa >> test.txt
    echo cccc ccaa cccc cccc >> test.txt
    echo aaaa aadd aaaa aaaa >> test.txt
    "../$RSUBOX" sort -k 2.3,1.10 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb bbaa bbbb bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa aaaa aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'cccc ccaa cccc cccc' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'aaaa aadd aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for fiveth key with character positions"
    echo bbbb bbaa aaab > test.txt
    echo aaaa aaaa >> test.txt
    echo cccc ccaa aaac >> test.txt
    echo aaaa aadd >> test.txt
    "../$RSUBOX" sort -k 2.3,3.3 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 4 1 'aaaa aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 3 2 'bbbb bbaa aaab' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'cccc ccaa aaac' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'aaaa aadd' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for sixth key and character position"
    echo aaaa abbb aaaa > test.txt
    echo bbbb baaa bbbb >> test.txt
    echo cccc cddd cccc >> test.txt
    echo dddd dccc dddd >> test.txt
    "../$RSUBOX" sort -k 2.2,2.0 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb baaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa abbb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd dccc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc cddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for two keys"
    echo aaaa aaaa aaaa cccc > test.txt
    echo bbbb aaaa bbbb bbbb >> test.txt
    echo cccc aaaa cccc aaaa >> test.txt
    echo dddd cccc dddd cccc >> test.txt
    "../$RSUBOX" sort -k 2,2 -k 4,4 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'cccc aaaa cccc aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'bbbb aaaa bbbb bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'aaaa aaaa aaaa cccc' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'dddd cccc dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key and separator"
    echo aaaa,bbbb,aaaa > test.txt
    echo bbbb,aaaa,bbbb >> test.txt
    echo cccc,dddd,cccc >> test.txt
    echo dddd,cccc,dddd >> test.txt
    "../$RSUBOX" sort -k 2,2 -t ',' test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb,aaaa,bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa,bbbb,aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd,cccc,dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc,dddd,cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for keys and default order options"
    echo 'aaaa #bbbb aaaa' > test.txt
    echo 'bbbb aaaa bbbb' >> test.txt
    echo 'cccc @dddd cccc' >> test.txt
    echo 'dddd cc@cc dddd' >> test.txt
    "../$RSUBOX" sort -k 2,2 -d test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa #bbbb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd cc@cc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc @dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for keys and first key order options instead of default order options"
    echo 'aaaa #bbbb aaaa' > test.txt
    echo 'bbbb aaaa bbbb' >> test.txt
    echo 'cccc @dddd cccc' >> test.txt
    echo 'dddd cc@cc dddd' >> test.txt
    "../$RSUBOX" sort -k 2d,2 -n test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa #bbbb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd cc@cc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc @dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for keys and second key order options instead of default order options"
    echo 'aaaa #bbbb aaaa' > test.txt
    echo 'bbbb aaaa bbbb' >> test.txt
    echo 'cccc @dddd cccc' >> test.txt
    echo 'dddd cc@cc dddd' >> test.txt
    "../$RSUBOX" sort -k 2,2d -n test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa #bbbb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd cc@cc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc @dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key and key default order"
    echo aaaa bbbb aaaa > test.txt
    echo bbbb aaaa bbbb >> test.txt
    echo cccc dddd cccc >> test.txt
    echo dddd cccc dddd >> test.txt
    "../$RSUBOX" sort -k 2,2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa bbbb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd cccc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key and numeric order"
    echo bbbb aaaa bbbb > test.txt
    echo aaaa 123 aaaa >> test.txt
    echo aaaa 2345bb aaaa >> test.txt
    echo cccc -123 cccc >> test.txt
    "../$RSUBOX" sort -k 2n,2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'cccc -123 cccc' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'aaaa 123 aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'aaaa 2345bb aaaa' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key, key default order and reverse order option"
    echo aaaa bbbb aaaa > test.txt
    echo bbbb aaaa bbbb >> test.txt
    echo cccc dddd cccc >> test.txt
    echo dddd cccc dddd >> test.txt
    "../$RSUBOX" sort -k 2r,2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 6 1 'cccc dddd cccc' ../test_tmp/stdout.txt &&
    assert_file_line 5 2 'dddd cccc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 4 3 'aaaa bbbb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 3 4 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key, numeric order and reverse order option"
    echo bbbb aaaa bbbb > test.txt
    echo aaaa 123 aaaa >> test.txt
    echo aaaa 2345bb aaaa >> test.txt
    echo cccc -123 cccc >> test.txt
    "../$RSUBOX" sort -k 2nr,2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 6 1 'aaaa 2345bb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 2 'aaaa 123 aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 4 3 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 3 4 'cccc -123 cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key and start b order option"
    printf 'aaaa,bbbb,aaaa\n' > test.txt
    printf 'bbbb,  aaaa,bbbb\n' >> test.txt
    printf 'cccc,dddd,cccc\n' >> test.txt
    printf 'dddd,\tcccc,dddd\n' >> test.txt
    printf 'bbbb,  aaaa,bbbb\n' > ../test_tmp/expected.txt
    printf 'aaaa,bbbb,aaaa\n' >> ../test_tmp/expected.txt
    printf 'dddd,\tcccc,dddd\n' >> ../test_tmp/expected.txt
    printf 'cccc,dddd,cccc\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" sort -k 2b,2 -t ',' test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key and end b order option"
    printf 'aaaa,aaaa   ,aaaa\n' > test.txt
    printf 'bbbb,aaaa,bbbb\n' >> test.txt
    printf 'cccc,cccc\t,cccc\n' >> test.txt
    printf 'dddd,cccc,dddd\n' >> test.txt
    printf 'aaaa,aaaa   ,aaaa\n' > ../test_tmp/expected.txt
    printf 'bbbb,aaaa,bbbb\n' >> ../test_tmp/expected.txt
    printf 'cccc,cccc\t,cccc\n' >> ../test_tmp/expected.txt
    printf 'dddd,cccc,dddd\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" sort -k 2,2b -t ',' test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key and d order option"
    printf 'aaaa,bb12,aaaa\n' > test.txt
    printf 'bbbb,  aaaa,bbbb\n' >> test.txt
    printf 'dddd,bb!34,dddd\n' >> test.txt
    printf 'cccc,\tcccc,cccc\n' >> test.txt
    printf 'cccc,\tcccc,cccc\n' > ../test_tmp/expected.txt
    printf 'bbbb,  aaaa,bbbb\n' >> ../test_tmp/expected.txt
    printf 'aaaa,bb12,aaaa\n' >> ../test_tmp/expected.txt
    printf 'dddd,bb!34,dddd\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" sort -k 2d,2 -t ',' test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key and f order option"
    echo aaaa AAbb aaaa > test.txt
    echo bbbb aaaa bbbb >> test.txt
    echo cccc CCdd cccc >> test.txt
    echo dddd cccc dddd >> test.txt
    "../$RSUBOX" sort -k 2f,2 test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bbbb aaaa bbbb' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'aaaa AAbb aaaa' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'dddd cccc dddd' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'cccc CCdd cccc' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort sorts lines for key and i order option"
    printf 'bbbb, aaaa,bbbb\n' > test.txt
    printf 'aaaa,aaaa,aaaa\n' >> test.txt
    printf 'cccc,bbbb,cccc\n' >> test.txt
    printf 'dddd,\raa12,dddd\n' >> test.txt
    printf 'bbbb, aaaa,bbbb\n' > ../test_tmp/expected.txt
    printf 'dddd,\raa12,dddd\n' >> ../test_tmp/expected.txt
    printf 'aaaa,aaaa,aaaa\n' >> ../test_tmp/expected.txt
    printf 'cccc,bbbb,cccc\n' >> ../test_tmp/expected.txt
    "../$RSUBOX" sort -k2i,2 -t ',' test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on too many arguments for checking"
    echo xxx > xxx
    "../$RSUBOX" sort -c xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on first field position that is zero"
    echo xxx > xxx
    "../$RSUBOX" sort -k 0 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Field position is zero' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on second field position that is zero"
    echo xxx > xxx
    "../$RSUBOX" sort -k 1,0 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Field position is zero' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on first character position that is zero"
    echo xxx > xxx
    "../$RSUBOX" sort -k 1.0 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Character position is zero' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on first field position that is invalid number"
    echo xxx > xxx
    "../$RSUBOX" sort -k '@#$' xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on second field position that is invalid number"
    echo xxx > xxx
    "../$RSUBOX" sort -k '1,@#$' xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on first character position that is invalid number"
    echo xxx > xxx
    "../$RSUBOX" sort -k '1.@#$' xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on second character position that is invalid number"
    echo xxx > xxx
    "../$RSUBOX" sort -k '1,2.@#$' xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on invalid first type"
    echo xxx > xxx
    "../$RSUBOX" sort -k 1x xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid type' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on invalid second type"
    echo xxx > xxx
    "../$RSUBOX" sort -k 1,2x xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid type' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on separator that isn't single character"
    echo xxx > xxx
    "../$RSUBOX" sort -k 1,2 -t xy xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Separator isn'"'"'t single character' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on non-existent file for sorting"
    "../$RSUBOX" sort xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on file that doesn't contain valid UTF-8 for sorting"
    "../$RSUBOX" sort  ../test_fixtures/test_sort_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\.\./test_fixtures/test_sort_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on non-existent file for sorting"
    "../$RSUBOX" sort -c xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on file that doesn't contain valid UTF-8 for checking"
    "../$RSUBOX" sort -c ../test_fixtures/test_sort_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\.\./test_fixtures/test_sort_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on non-existent file for merging"
    "../$RSUBOX" sort -m xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test sort "sort complains on file that doesn't contain valid UTF-8 for merging"
    "../$RSUBOX" sort -m ../test_fixtures/test_sort_invalid_utf8.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\.\./test_fixtures/test_sort_invalid_utf8.txt: stream' ../test_tmp/stderr.txt
end_test
