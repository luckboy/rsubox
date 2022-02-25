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
start_test printf "printf prints format string"
    "../$RSUBOX" printf 'abcdef\n' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 abcdef ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints arguments"
    "../$RSUBOX" printf '%d %s\n' 1234 abcdef > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "1234 abcdef" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints format string without newline in end"
    echo -n abcdef > ../test_tmp/expected.txt 
    "../$RSUBOX" printf 'abcdef' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints short escapes in format string"
    printf '\a\b\f\n\r\t\v\\' > ../test_tmp/expected.txt
    "../$RSUBOX" printf '\a\b\f\n\r\t\v\\' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints long escapes in format string"
    printf 'ab\45cd\123ef' > ../test_tmp/expected.txt
    "../$RSUBOX" printf 'ab\45cd\123ef' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints percent"
    "../$RSUBOX" printf '%%\n' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "%" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number"
    "../$RSUBOX" printf '%d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "1234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints negative decimal number"
    "../$RSUBOX" printf '%d\n' -1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "-1234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints negative decimal number"
    "../$RSUBOX" printf '%d\n' -1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "-1234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints negative minimal decimal number"
    "../$RSUBOX" printf '%d\n' -9223372036854775808 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "-9223372036854775808" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints integer number"
    "../$RSUBOX" printf '%i\n' 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "5678" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints negative integer number"
    "../$RSUBOX" printf '%d\n' -5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "-5678" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints octal number"
    "../$RSUBOX" printf '%o\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "2322" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints unsigned number"
    "../$RSUBOX" printf '%u\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "1234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints hexdemical number for lowercase"
    "../$RSUBOX" printf '%x\n' 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "162e" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints hexdemical number for uppercase"
    "../$RSUBOX" printf '%X\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "4D2" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width"
    "../$RSUBOX" printf '%10d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "      1234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints negative decimal number with field width"
    "../$RSUBOX" printf '%10d\n' -1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "     -1234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width and zero flag"
    "../$RSUBOX" printf '%010d\n' 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "0000005678" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints negative decimal number with field width and zero flag"
    "../$RSUBOX" printf '%010d\n' -5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "-000005678" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width, zero flag and plus flag"
    "../$RSUBOX" printf '%+010d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "+000001234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width, zero flag and space flag"
    "../$RSUBOX" printf '% 010d\n' 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 " 000005678" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width that is less than number width"
    "../$RSUBOX" printf '%5d\n' 12345678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "12345678" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with precision"
    "../$RSUBOX" printf '%.7d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "0001234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width and precision"
    "../$RSUBOX" printf '%10.7d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "   0001234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width, precision and zero flag"
    "../$RSUBOX" printf '%010.7d\n' 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "   0005678" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width and precision"
    "../$RSUBOX" printf '%10.7d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "   0001234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width and precision that is less than number field width"
    "../$RSUBOX" printf '%10.7d\n' 12345678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "  12345678" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width and precision that is greater than field width"
    "../$RSUBOX" printf '%5.7d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "0001234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with zero precision for zero"
    "../$RSUBOX" printf '%.0d\n' 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with hash flag"
    "../$RSUBOX" printf '%#d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "1234" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints octal number with hash flag"
    "../$RSUBOX" printf '%#o\n' 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "013056" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints octal number with zero precision and hash flag for zero"
    "../$RSUBOX" printf '%#.0o\n' 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "0" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints hexdecmial number with hash flag"
    "../$RSUBOX" printf '%#x\n' 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "0x162e" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints hexdecmial number with hash flag for uppercase"
    "../$RSUBOX" printf '%#X\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "0X4D2" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints hexdecmial number with zero procesion hash flag for zero"
    "../$RSUBOX" printf '%#.0x\n' 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints hexdecmial number with field width, zero flag and hash flag"
    "../$RSUBOX" printf '%#010x\n' 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "0x0000162e" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width and minus flag"
    "../$RSUBOX" printf '%-10d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "1234      " ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints decimal number with field width, precision and minus flag"
    "../$RSUBOX" printf '%-10.7d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "0001234   " ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints byte"
    "../$RSUBOX" printf '%b\n' a > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "a" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints short escape bytes"
    printf '\a\b\f\n\r\t\v\\' > ../test_tmp/expected.txt
    "../$RSUBOX" printf '%b%b%b%b%b%b%b%b' '\a' '\b' '\f' '\n' '\r' '\t' '\v' '\\' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints long escape bytes"
    printf '\45\123' > ../test_tmp/expected.txt
    "../$RSUBOX" printf '%b%b' '\045' '\0123' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_tmp/expected.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints byte with field width"
    "../$RSUBOX" printf '%5b\n' a > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "    a" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints byte with field width and minus flag"
    "../$RSUBOX" printf '%-5b\n' a > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "a    " ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints character"
    "../$RSUBOX" printf '%c\n' b > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "b" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints backslash character"
    "../$RSUBOX" printf '%c\n' '\0123' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 '\' ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints character with field width"
    "../$RSUBOX" printf '%5c\n' b > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "    b" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints character with field width and minus flag"
    "../$RSUBOX" printf '%-5c\n' b > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "b    " ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints string"
    "../$RSUBOX" printf '%s\n' abcdef > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "abcdef" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints string with backslashes"
    "../$RSUBOX" printf '%s\n' '\n\0123' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 '\n\0123' ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints string with field width"
    "../$RSUBOX" printf '%10s\n' abcdef > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "    abcdef" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints string with precision"
    "../$RSUBOX" printf '%.5s\n' abcdef > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "abcde" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints string with zero precision"
    "../$RSUBOX" printf '%.0s\n' abcdef > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints string with field width and precision"
    "../$RSUBOX" printf '%10.5s\n' abcdef > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "     abcde" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf prints string with field width and minus flag"
    "../$RSUBOX" printf '%-10s\n' abcdef > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "abcdef    " ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test printf "printf complains on invalid format character"
    "../$RSUBOX" printf '%d %y\n' 1234 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content 2 "Invalid format character" ../test_tmp/stderr.txt
end_test

start_test printf "printf complains on no format character"
    "../$RSUBOX" printf '%d %' 1234 5678 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content 2 "No format character" ../test_tmp/stderr.txt
end_test

start_test printf "printf complains on invalid argument"
    "../$RSUBOX" printf '%d\n' xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content_pattern 2 '^Invalid argument: ' ../test_tmp/stderr.txt
end_test

start_test printf "printf complains on no argument"
    "../$RSUBOX" printf '%d %d\n' 1234 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_content 2 "No argument" ../test_tmp/stderr.txt
end_test
