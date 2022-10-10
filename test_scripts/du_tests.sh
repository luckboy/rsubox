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
start_test du "du prints blocks and directories"
    echo xxx > xxx
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    mkdir test2
    echo xxx > test2/xxx
    echo yyy > test2/yyy
    "../$RSUBOX" du > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^[0-9][0-9]* \.' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test du "du prints blocks and directories for no deference option"
    echo xxx > xxx
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    ln -s ../test4 test1/test4
    mkdir test2
    echo xxx > test2/xxx
    echo yyy > test2/yyy
    mkdir test2/test
    echo xxx > test2/test/xxx
    echo yyy > test2/test/yyy
    ln -s test5 test3
    mkdir test4
    echo aaa > test4/aaa
    echo bbb > test4/bbb
    mkdir test5
    echo aaa > test5/aaa
    echo bbb > test5/bbb
    mkdir test5/test
    echo aaa > test5/test/aaa
    echo bbb > test5/test/bbb
    "../$RSUBOX" du test1 test2 test3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 5 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* test1/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 3 '^[0-9][0-9]* test2/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 4 '^[0-9][0-9]* test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^[0-9][0-9]* test3' ../test_tmp/stdout.txt &&
    assert_file_size 8 0 ../test_tmp/stderr.txt
end_test

start_test du "du prints blocks and directories for -H option"
    echo xxx > xxx
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    ln -s ../test4 test1/test4
    mkdir test2
    echo xxx > test2/xxx
    echo yyy > test2/yyy
    mkdir test2/test
    echo xxx > test2/test/xxx
    echo yyy > test2/test/yyy
    ln -s test5 test3
    mkdir test4
    echo aaa > test4/aaa
    echo bbb > test4/bbb
    mkdir test5
    echo aaa > test5/aaa
    echo bbb > test5/bbb
    mkdir test5/test
    echo aaa > test5/test/aaa
    echo bbb > test5/test/bbb
    "../$RSUBOX" du -H test1 test2 test3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 6 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* test1/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^[0-9][0-9]* test2/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^[0-9][0-9]* test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^[0-9][0-9]* test3/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^[0-9][0-9]* test3' ../test_tmp/stdout.txt &&
    assert_file_size 9 0 ../test_tmp/stderr.txt
end_test

start_test du "du prints blocks and directories for -L option"
    echo xxx > xxx
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    ln -s ../test4 test1/test4
    mkdir test2
    echo xxx > test2/xxx
    echo yyy > test2/yyy
    mkdir test2/test
    echo xxx > test2/test/xxx
    echo yyy > test2/test/yyy
    ln -s test5 test3
    mkdir test4
    echo aaa > test4/aaa
    echo bbb > test4/bbb
    mkdir test5
    echo aaa > test5/aaa
    echo bbb > test5/bbb
    mkdir test5/test
    echo aaa > test5/test/aaa
    echo bbb > test5/test/bbb
    "../$RSUBOX" du -L test1 test2 test3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 7 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* test1/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* test1/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^[0-9][0-9]* test2/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^[0-9][0-9]* test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^[0-9][0-9]* test3/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^[0-9][0-9]* test3' ../test_tmp/stdout.txt &&
    assert_file_size 10 0 ../test_tmp/stderr.txt
end_test

start_test du "du prints kilobytes and directories"
    echo xxx > xxx
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    mkdir test2
    echo xxx > test2/xxx
    echo yyy > test2/yyy
    "../$RSUBOX" du -k > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^[0-9][0-9]* \.' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test du "du prints blocks and files and/or directories"
    echo xxx > xxx
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    mkdir test2
    echo xxx > test2/xxx
    echo yyy > test2/yyy
    "../$RSUBOX" du -a > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 11 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&    
    assert_file_line_pattern 11 9 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&    
    assert_file_line_pattern 12 10 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 13 11 '^[0-9][0-9]* \.' ../test_tmp/stdout.txt &&
    assert_file_size 14 0 ../test_tmp/stderr.txt
end_test

start_test du "du prints sums"
    echo xxx > xxx
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    mkdir test2
    echo xxx > test2/xxx
    echo yyy > test2/yyy
    mkdir test2/test
    echo xxx > test2/test/xxx
    echo yyy > test2/test/yyy
    "../$RSUBOX" du -s test1 test2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* test2' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test du "du prints blocks and directories for one filesystem"
    echo xxx > xxx
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    mkdir test2
    echo xxx > test2/xxx
    echo yyy > test2/yyy
    "../$RSUBOX" du -x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^[0-9][0-9]* \./..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^[0-9][0-9]* \.' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test du "du prints blocks and file"
    echo xxx > xxx
    "../$RSUBOX" du xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* xxx' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test du "du omits one directory for two same directories"
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    mkdir test1/test
    echo xxx > test1/test/xxx
    echo yyy > test1/test/yyy
    ln -s test test1/test2
    "../$RSUBOX" du -L test1 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* test1/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test du "du omits one file for two same files"
    mkdir test1
    echo xxx > test1/xxx
    echo yyy > test1/yyy
    ln test1/xxx test1/zzz
    "../$RSUBOX" du -aL test1 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^[0-9][0-9]* test1/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^[0-9][0-9]* test1/..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test du "du complains on non-existent file"
    "../$RSUBOX" du xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test
