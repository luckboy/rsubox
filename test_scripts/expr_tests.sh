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
start_test expr "expr evaluates expression"
    "../$RSUBOX" expr 1 + 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 3 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with negative numbers"
    "../$RSUBOX" expr -1 + -2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 -3 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with two operators"
    "../$RSUBOX" expr 10 + 20 - 5 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 25 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates addition and multiplication"
    "../$RSUBOX" expr 1 + 2 \* 3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 7 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with parentheses"
    "../$RSUBOX" expr \( 1 + 2 \) \* 3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 9 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-OR operator for two trues"
    "../$RSUBOX" expr 1 \| 1 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 1 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-OR operator for two falses"
    "../$RSUBOX" expr 0 \| 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-OR operator for two empty strings"
    "../$RSUBOX" expr '' \| '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-OR operator for one empty strings"
    "../$RSUBOX" expr aaa \| '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 aaa ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-AND operator for two trues"
    "../$RSUBOX" expr 1 \| 1 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 1 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-AND operator for two falses"
    "../$RSUBOX" expr 0 \& 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-AND operator for two empty strings"
    "../$RSUBOX" expr '' \& '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-AND operator for one empty strings"
    "../$RSUBOX" expr aaa \& '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with logical-AND operator for two strings"
    "../$RSUBOX" expr aaa \& bbb > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 aaa ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates equation"
    "../$RSUBOX" expr 2 = 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 1 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates inequation"
    "../$RSUBOX" expr 3 != 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 1 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with less than"
    "../$RSUBOX" expr 1 \< 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 1 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with greater than or equal"
    "../$RSUBOX" expr aaa \>= bbb > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with greater than"
    "../$RSUBOX" expr aaa \> 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 1 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates expression with less than or equal"
    "../$RSUBOX" expr 222 \<= 1aa > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates addition"
    "../$RSUBOX" expr 1 + 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 3 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates subtraction"
    "../$RSUBOX" expr 5 - 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 3 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates multiplication"
    "../$RSUBOX" expr 2 \* 3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 6 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates division"
    "../$RSUBOX" expr 10 / 5 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 2 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates remainder"
    "../$RSUBOX" expr 23 \% 10 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 3 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates matching"
    "../$RSUBOX" expr abcdef : '[Aa][Bb][Cc]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 3 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates matching for no matching"
    "../$RSUBOX" expr xxx : '[Aa][Bb][Cc]' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates matching for regular expression with subexpression"
    "../$RSUBOX" expr abbbc : 'a\(bbb\)c' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 bbb ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr evaluates matching for integer numbers"
    "../$RSUBOX" expr 1234 : '1\(23\)4' + 5 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 28 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test expr "expr complains on no argument"
    "../$RSUBOX" expr 1 + > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'No argument' ../test_tmp/stderr.txt
end_test

start_test expr "expr complains on unknown operator"
    "../$RSUBOX" expr 1 '$' 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Syntax error' ../test_tmp/stderr.txt
end_test

start_test expr "expr complains on non-integer argument"
    "../$RSUBOX" expr aaa + 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Non-integer argument' ../test_tmp/stderr.txt
end_test

start_test expr "expr complains on integer number with plus"
    "../$RSUBOX" expr +2 + 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Non-integer argument' ../test_tmp/stderr.txt
end_test

start_test expr "expr complains on unclosed parentheses"
    "../$RSUBOX" expr \( 1 + 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Unclosed parentheses' ../test_tmp/stderr.txt
end_test

start_test expr "expr complains on division by zero"
    "../$RSUBOX" expr 10 / 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Division by zero' ../test_tmp/stderr.txt
end_test

start_test expr "expr complains on division by zero for remainder"
    "../$RSUBOX" expr 10 \% 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Division by zero' ../test_tmp/stderr.txt
end_test

start_test expr "expr complains on overflow"
    "../$RSUBOX" expr 9223372036854775807 + 9223372036854775807 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Overflow' ../test_tmp/stderr.txt
end_test
