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
start_test xargs "xargs executes command with arguments from line"
    echo abc def | "../$RSUBOX" xargs > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 'abc def' ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from line with echo program"
    echo abc def | "../$RSUBOX" xargs echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 'xxx abc def' ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from line with printf program"
    echo abc | "../$RSUBOX" xargs printf 'xxx %s yyy\n' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 'xxx abc yyy' ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from lines"
    echo abc def > test.txt
    echo ghi jkl >> test.txt
    echo mno pqr >> test.txt 
    cat test.txt | "../$RSUBOX" xargs echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx abc def ghi jkl mno pqr' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from lines for EOF"
    echo abc def > test.txt
    echo ghi jkl >> test.txt
    echo EOT pqr >> test.txt 
    cat test.txt | "../$RSUBOX" xargs -E EOT echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx abc def ghi jkl' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for replacing and EOF"
    echo abc def > test.txt
    echo ghi jkl >> test.txt
    echo EOT >> test.txt
    cat test.txt | "../$RSUBOX" xargs -E EOT -I arg echo xxx arg > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx abc def' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx ghi jkl' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for replacing and spaces"
    echo '  abc   def  ' > test.txt
    echo '  ghi   jkl  ' >> test.txt
    cat test.txt | "../$RSUBOX" xargs -I arg echo xxx arg yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx abc   def   yyy' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx ghi   jkl   yyy' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from lines for spaces"
    echo '  abc   def  ' > test.txt
    echo '  ghi   jkl  ' >> test.txt
    cat test.txt | "../$RSUBOX" xargs echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx abc def ghi jkl' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from lines for quotations"
    echo 'abc"xxx  '"'"'  yyy"def' > test.txt
    echo 'ghi'"'"'xxx  "  yyy'"'"'jkl' >> test.txt
    cat test.txt | "../$RSUBOX" xargs echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx abcxxx  '"'"'  yyydef ghixxx  "  yyyjkl' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for replacing"
    echo abc def > test.txt
    echo ghi jkl >> test.txt
    cat test.txt | "../$RSUBOX" xargs -I arg echo xxx arg > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx abc def' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx ghi jkl' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for lines"
    echo xxx yyy > test.txt
    echo zzz xxx >> test.txt
    echo yyy xxx >> test.txt
    echo aaa bbb >> test.txt
    echo ccc ddd >> test.txt
    cat test.txt | "../$RSUBOX" xargs -L 3 echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx xxx yyy zzz xxx yyy xxx' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx aaa bbb ccc ddd' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for lines and equal number of lines"
    echo xxx yyy > test.txt
    echo zzz xxx >> test.txt
    echo yyy xxx >> test.txt
    echo aaa bbb >> test.txt
    echo ccc ddd >> test.txt
    echo eee fff >> test.txt
    cat test.txt | "../$RSUBOX" xargs -L 3 echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx xxx yyy zzz xxx yyy xxx' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx aaa bbb ccc ddd eee fff' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines with empty lines for lines"
    echo xxx yyy > test.txt
    echo >> test.txt
    echo zzz xxx >> test.txt
    echo yyy xxx >> test.txt
    echo aaa bbb >> test.txt
    echo '   ' >> test.txt
    echo ccc ddd >> test.txt
    cat test.txt | "../$RSUBOX" xargs -L 3 echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx xxx yyy zzz xxx yyy xxx' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx aaa bbb ccc ddd' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for number of arguments"
    echo xxx yyy > test.txt
    echo zzz >> test.txt
    echo aaa >> test.txt
    echo bbb >> test.txt
    echo ccc >> test.txt
    echo ddd >> test.txt
    cat test.txt | "../$RSUBOX" xargs -n 3 echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx xxx yyy zzz' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx aaa bbb ccc' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'xxx ddd' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for number of arguments and equal number of argument"
    echo xxx yyy > test.txt
    echo zzz >> test.txt
    echo aaa >> test.txt
    echo bbb >> test.txt
    echo ccc >> test.txt
    cat test.txt | "../$RSUBOX" xargs -n 3 echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx xxx yyy zzz' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx aaa bbb ccc' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for prompt mode and yes"
    echo xxx yyy > test.txt
    echo aaa bbb >> test.txt
    echo y > reply.txt
    echo -n 'echo xxx xxx yyy aaa bbb ?...' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" xargs -p -T reply.txt echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx xxx yyy aaa bbb' ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for prompt mode and no"
    echo xxx yyy > test.txt
    echo aaa bbb >> test.txt
    echo n > reply.txt
    echo -n 'echo xxx xxx yyy aaa bbb ?...' > ../test_tmp/expected.txt
    cat test.txt | "../$RSUBOX" xargs -p -T reply.txt echo xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from lines for size"
    echo xxxx > test.txt
    cat test.txt | "../$RSUBOX" xargs -s 10 echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxxx' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from lines and complains for size"
    echo xxxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -s 10 echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'yyyy' ../test_tmp/stdout.txt &&
    assert_file_content 5 'Too long command line' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for replacing and size"
    echo xxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -I arg -s 10 echo arg > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxxx' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'yyyy' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines and complains for replacing and size"
    echo xxxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -I arg -s 10 echo arg > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'yyyy' ../test_tmp/stdout.txt &&
    assert_file_content 5 'Too long command line' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for lines and size"
    echo xxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -L 1 -s 10 echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxxx' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'yyyy' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments  from lines and complains for lines and size"
    echo xxxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -L 1 -s 10 echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'yyyy' ../test_tmp/stdout.txt &&
    assert_file_content 5 'Too long command line' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines for number of arguments and size"
    echo xxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -n 1 -s 10 echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxxx' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'yyyy' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes commands with arguments from lines and complains for number of arguments and size"
    echo xxxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -n 1 -s 10 echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'yyyy' ../test_tmp/stdout.txt &&
    assert_file_content 5 'Too long command line' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs executes command with arguments from lines for replacing and tracing"
    echo abc def > test.txt
    echo ghi jkl >> test.txt
    echo mno pqr >> test.txt 
    cat test.txt | "../$RSUBOX" xargs -I arg -t echo xxx arg > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx abc def' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx ghi jkl' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'xxx mno pqr' ../test_tmp/stdout.txt &&
    assert_file_line_count 6 3 ../test_tmp/stderr.txt &&
    assert_file_line 3 1 'echo xxx abc def' ../test_tmp/stderr.txt &&
    assert_file_line 4 2 'echo xxx ghi jkl' ../test_tmp/stderr.txt &&
    assert_file_line 5 3 'echo xxx mno pqr' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains and quits from lines for size and exit"
    echo xxxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -s 10 -x echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 5 'Too long command line' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains and quits for replacing, size and exit"
    echo xxxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -I arg -s 10 -x echo arg > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 5 'Too long command line' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains and quits for lines, size and exit"
    echo xxxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -L 1 -s 10 -x echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 5 'Too long command line' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains and quits for number of arguments, size and exit"
    echo xxxxx > test.txt
    echo yyyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs -n 1 -s 10 -x echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 5 'Too long command line' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on unclosed single quotation"
    echo "'"'xxx' > test.txt
    echo xxx yyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx yyy' ../test_tmp/stdout.txt &&
    assert_file_content 4 'Unclosed single quotation' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on unclosed double quotation"
    echo '"xxx' > test.txt
    echo xxx yyy >> test.txt
    cat test.txt | "../$RSUBOX" xargs echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx yyy' ../test_tmp/stdout.txt &&
    assert_file_content 4 'Unclosed double quotation' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on non-existent program"
    echo yyy | "../$RSUBOX" xargs ./xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\./xxx: ' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on invalid number of lines"
    echo yyy | "../$RSUBOX" xargs -L xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on number of lines is zero"
    echo yyy | "../$RSUBOX" xargs -L 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Number of lines is zero' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on invalid number of argument"
    echo yyy | "../$RSUBOX" xargs -n xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on number of argument is zero"
    echo yyy | "../$RSUBOX" xargs -n 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Number of arguments is zero' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on invalid size"
    echo yyy | "../$RSUBOX" xargs -s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test xargs "xargs complains on size is zero"
    echo yyy | "../$RSUBOX" xargs -s 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Size is zero' ../test_tmp/stderr.txt
end_test
