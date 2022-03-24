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
start_test tr "tr replaces characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo AABBCC1122 > ../test_tmp/expected.txt
    echo DDEEFF3344 >> ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr 'a-z' 'A-Z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for complemented set of values"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo -n aabbccxxxxxddeeffxxxxx > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -c 'a-z' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for complemented set of characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo -n aabbccxxxxxddeeffxxxxx > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -C 'a-z' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces and squeezes characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo ABC1122 > ../test_tmp/expected.txt
    echo DEF3344 >> ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -s 'a-z' 'A-Z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces and squeezes characters for complemented set of values"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo -n aabbccxddeeffx > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -cs 'a-z' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces and squeezes characters for complemented set of characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo -n aabbccxddeeffx > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -Cs 'a-z' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces and squeezes characters for characters from first set and second set"
    echo AAAaaaAAA > test.txt
    echo A > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -s 'a-z' 'A-Z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr squeezes characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo abc1122 > ../test_tmp/expected.txt
    echo def3344 >> ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -s 'a-z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr squeezes characters for complemented set of values"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo aabbcc12 > ../test_tmp/expected.txt
    echo ddeeff34 >> ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -cs 'a-z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr squeezes characters for complemented set of characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo aabbcc12 > ../test_tmp/expected.txt
    echo ddeeff34 >> ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -Cs 'a-z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr deletes characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo 1122 > ../test_tmp/expected.txt
    echo 3344 >> ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -d 'a-z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr deletes characters for complemented set of values"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo -n aabbccddeeff > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -cd 'a-z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr deletes characters for complemented set of characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo -n aabbccddeeff > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -Cd 'a-z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr deletes and squeezes characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo 12 > ../test_tmp/expected.txt
    echo 34 >> ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -ds 'a-z' '0-9' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr deletes and squeezes characters for complemented set of values"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo -n abcdef > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -cds 'a-z' 'a-z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr deletes and squeezes characters for complemented set of characters"
    echo aabbcc1122 > test.txt
    echo ddeeff3344 >> test.txt
    echo -n abcdef > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -Cds 'a-z' 'a-z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr deletes and squeezes characters for squeezing characters are between characters from first set"
    echo 111aabbcc111 > test.txt
    echo 1 > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr -ds 'a-z' '0-9' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for characters"
    echo abcdef > test.txt
    echo ABCdef > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr 'abc' 'ABC' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for short escapes"
    printf 'ab\a\b\f\n\r\t\v\\c' > test.txt
    printf 'abxxxxxxxxc' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '\a\b\f\n\r\t\v\\' '[x*]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for long escapes"
    printf 'ab\45cd\123ef' > test.txt
    printf 'abxcdxef' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '\45\123' '[x*]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for ranges"
    echo abcdef > test.txt
    echo ABCDEF > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr 'a-z' 'A-Z' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for range with short escapes"
    printf 'ab\a\b\f\n\r\t\vc' > test.txt
    printf 'abxxxxxxxc' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '\a-\r' '[x*]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for range with long escapes"
    printf 'ab\45cd\56ef' > test.txt
    printf 'abxcdxef' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '\40-\57' '[x*]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for special characters"
    echo '[a]-bc' > test.txt
    echo 1234bc > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '\[a]-' '1234' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for repetitions with decimal numbers"
    echo abcdefxyz > test.txt
    echo 111xxx222 > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr 'a-z' '[1*3][x*20][2*3]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for repetitions with octal numbers"
    echo abcdefxyz > test.txt
    echo 111xxx222 > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr 'a-z' '[1*03][x*024][2*03]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for repetition to unknown"
    echo 0123456789 > test.txt
    echo abcxxxxdef > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '0-9' 'abc[x*]def' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for character class and repetition to unknown"
    echo 123abcdef > test.txt
    echo 876xxxxxx > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:alpha:]0-9' '[x*]9876543210' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for character classes and repetitions to unknown"
    echo 123abcdef > test.txt
    echo yyyxxxxxx > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:alpha:][:digit:]' '[x*][y*]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for character class and character"
    echo 123abcdef > test.txt
    echo 123xxxxxx > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:alpha:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for first set that is greater than second set"
    echo abcdef > test.txt
    echo ABCCCC > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr 'abcdef' 'ABC' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for first set that is less than second set"
    echo abcdef > test.txt
    echo ABCDEF > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr 'abcdef' 'ABCDEFGH' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for alnum character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./xxxxxxxxxx:;<=>?@xxxxxxxxxxxxxxxxxxxxxxxxxx[\\]^_`xxxxxxxxxxxxxxxxxxxxxxxxxx{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:alnum:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for alpha character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@xxxxxxxxxxxxxxxxxxxxxxxxxx[\\]^_`xxxxxxxxxxxxxxxxxxxxxxxxxx{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:alpha:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for blank character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\rx\vx!"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:blank:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for cntrl character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf 'xxxxxxx !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:cntrl:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for digit character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./xxxxxxxxxx:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:digit:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for graph character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\v xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:graph:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for lower character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`xxxxxxxxxxxxxxxxxxxxxxxxxx{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:lower:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for print character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\vxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:print:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for punct character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\v xxxxxxxxxxxxxxx0123456789xxxxxxxABCDEFGHIJKLMNOPQRSTUVWXYZxxxxxxabcdefghijklmnopqrstuvwxyzxxxx' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:punct:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for space character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\bxxxxxx!"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:space:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for upper character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@xxxxxxxxxxxxxxxxxxxxxxxxxx[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:upper:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for xdigit character class"
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > test.txt
    printf '\a\b\f\n\r\t\v !"#$%%&'"'"'()*+,-./xxxxxxxxxx:;<=>?@xxxxxxGHIJKLMNOPQRSTUVWXYZ[\\]^_`xxxxxxghijklmnopqrstuvwxyz{|}~' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:xdigit:]' x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for conversion from lower character class to upper character class"
    echo 123abcdef > test.txt
    echo 123ABCDEF > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:lower:]' '[:upper:]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for conversion from upper character class to lower character class"
    echo 123ABCDEF > test.txt
    echo 123abcdef > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[:upper:]' '[:lower:]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters for equivalent character"
    echo 123abcdef > test.txt
    echo 123ABCdef > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" tr '[=a=]bc' 'ABC' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr replaces characters with UTF-8 codes"
    cat ../test_fixtures/test_tr_utf8.txt | "../$RSUBOX" tr '[:lower:][:upper:]' '[:upper:][:lower:]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_tr2_utf8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too few arguments for replacing and zero arguments"
    "../$RSUBOX" tr > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too many arguments for replacing and one argument"
    "../$RSUBOX" tr xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too many arguments for replacing and three argument"
    "../$RSUBOX" tr xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too few arguments for squeezing and zero arguments"
    "../$RSUBOX" tr -s > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too many arguments for squeezing and three arguments"
    "../$RSUBOX" tr -s xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too few arguments for deleting and zero arguments"
    "../$RSUBOX" tr -d > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too many arguments for deleting and two arguments"
    "../$RSUBOX" tr -d xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too few arguments for deleting, squeezing and zero arguments"
    "../$RSUBOX" tr -ds > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too few arguments for deleting, squeezing and one arguments"
    "../$RSUBOX" tr -ds xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too many arguments for squeezing and three arguments"
    "../$RSUBOX" tr -ds xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many arguments' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on invalid expression in bracket"
    "../$RSUBOX" tr abc '[x]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid expression in bracket' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on invalid decimal number in repetition"
    "../$RSUBOX" tr abc '[x*x]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid expression in bracket' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on invalid octal number in repetition"
    "../$RSUBOX" tr abc '[x*0x]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid expression in bracket' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on too many repetitions to unknown"
    "../$RSUBOX" tr 'a-z' 'z[x*]z[y*]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too many repetitions to unknown' ../test_tmp/stderr.txt
end_test

start_test tr "tr complains on stdin that doesn't contain valid UTF-8"
    cat ../test_fixtures/test_tr_invalid_utf8.txt | "../$RSUBOX" tr '[:lower:][:upper:]' '[:upper:][:lower:]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^stream' ../test_tmp/stderr.txt
end_test
