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
start_test find "find prints files and directories"
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
    "../$RSUBOX" find > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 11 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^. EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^./xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^./test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^./test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^./test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^./test1/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^./test1/test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^./test1/test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 11 '^./test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 12 '^./test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 13 '^./test2/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 14 0 ../test_tmp/stderr.txt
end_test

start_test find "find prints files and directories for no deference option"
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
    "../$RSUBOX" find test1 test2 test3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 14 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test1/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test1/test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test1/test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test1/test4 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 11 '^test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 12 '^test2/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 13 '^test2/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 14 '^test2/test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 15 '^test2/test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 16 '^test3 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 17 0 ../test_tmp/stderr.txt
end_test

start_test find "find prints files and directories for -H option"
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
    "../$RSUBOX" find -H test1 test2 test3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 19 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test1/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test1/test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test1/test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test1/test4 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 11 '^test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 12 '^test2/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 13 '^test2/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 14 '^test2/test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 15 '^test2/test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 16 '^test3 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 17 '^test3/aaa EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 18 '^test3/bbb EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 19 '^test3/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 20 '^test3/test/aaa EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 21 '^test3/test/bbb EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 22 0 ../test_tmp/stderr.txt
end_test

start_test find "find prints files and directories for -L option"
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
    "../$RSUBOX" find -L test1 test2 test3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 21 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test1/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test1/test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test1/test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test1/test4 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test1/test4/aaa EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 11 '^test1/test4/bbb EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 12 '^test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 13 '^test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 14 '^test2/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 15 '^test2/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 16 '^test2/test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 17 '^test2/test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 18 '^test3 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 19 '^test3/aaa EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 20 '^test3/bbb EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 22 '^test3/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 23 '^test3/test/aaa EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 24 '^test3/test/bbb EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 25 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by name"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test -name 'ab*' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/abc EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test/ab12 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/abz EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by dot name"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    "../$RSUBOX" find . -name '.' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^. EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by nouser operand"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -nouser > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 0 ../test_tmp/stdout_xargs.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by nogroup operand"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -nogroup > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 0 ../test_tmp/stdout_xargs.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by xdev operand"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -xdev > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 8 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 11 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by prune operand"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -prune > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by permissions for numeric mode"
    mkdir test
    chmod 755 test
    echo xxx > test/xxx
    chmod 644 test/xxx
    echo yyy > test/yyy
    chmod 644 test/yyy
    mkdir test/test1
    chmod 755 test/test1
    echo xxx > test/test1/xxx
    chmod 644 test/test1/xxx
    echo yyy > test/test1/yyy
    chmod 664 test/test1/yyy
    mkdir test/test2
    chmod 775 test/test2
    echo xxx > test/test2/xxx
    chmod 664 test/test2/xxx
    "../$RSUBOX" find test -perm 664 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by permissions for symbolic mode"
    mkdir test
    chmod 755 test
    echo xxx > test/xxx
    chmod 644 test/xxx
    echo yyy > test/yyy
    chmod 644 test/yyy
    mkdir test/test1
    chmod 755 test/test1
    echo xxx > test/test1/xxx
    chmod 644 test/test1/xxx
    echo yyy > test/test1/yyy
    chmod 664 test/test1/yyy
    mkdir test/test2
    chmod 775 test/test2
    echo xxx > test/test2/xxx
    chmod 664 test/test2/xxx
    "../$RSUBOX" find test -perm ug=rw,o=r > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by permissions with minus for numeric mode"
    mkdir test
    chmod 755 test
    echo xxx > test/xxx
    chmod 644 test/xxx
    echo yyy > test/yyy
    chmod 644 test/yyy
    mkdir test/test1
    chmod 755 test/test1
    echo xxx > test/test1/xxx
    chmod 644 test/test1/xxx
    echo yyy > test/test1/yyy
    chmod 664 test/test1/yyy
    mkdir test/test2
    chmod 775 test/test2
    echo xxx > test/test2/xxx
    chmod 664 test/test2/xxx
    "../$RSUBOX" find test -perm -664 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by permissions with minus for symbolic mode"
    mkdir test
    chmod 755 test
    echo xxx > test/xxx
    chmod 644 test/xxx
    echo yyy > test/yyy
    chmod 644 test/yyy
    mkdir test/test1
    chmod 755 test/test1
    echo xxx > test/test1/xxx
    chmod 644 test/test1/xxx
    echo yyy > test/test1/yyy
    chmod 664 test/test1/yyy
    mkdir test/test2
    chmod 775 test/test2
    echo xxx > test/test2/xxx
    chmod 664 test/test2/xxx
    "../$RSUBOX" find test -perm -ug=rw,o=r > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by regular file type"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    mkfifo test/test1/yyy
    mkdir test/test2
    ln -s ../../xxx test/test2/xxx
    echo xxx > xxx
    "../$RSUBOX" find test -type f > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by directory type"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    mkfifo test/test1/yyy
    mkdir test/test2
    ln -s ../../xxx test/test2/xxx
    echo xxx > xxx
    "../$RSUBOX" find test -type d > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by symbolic link type"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    mkfifo test/test1/yyy
    mkdir test/test2
    ln -s ../../xxx test/test2/xxx
    echo xxx > xxx
    "../$RSUBOX" find test -type l > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by FIFO type"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    mkfifo test/test1/yyy
    mkdir test/test2
    ln -s ../../xxx test/test2/xxx
    echo xxx > xxx
    "../$RSUBOX" find test -type p > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by links and regular file"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    ln test/xxx test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    ln test/xxx test/test2/xxx
    "../$RSUBOX" find test -type f -links 3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by links with plus and regular file"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    ln test/xxx test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    ln test/xxx test/test2/xxx
    "../$RSUBOX" find test -type f -links +2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by links with minus and regular file"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    ln test/xxx test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    ln test/xxx test/test2/xxx
    "../$RSUBOX" find test -type f -links -2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by user"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -user "`id -un`" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 8 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 11 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by group"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -group "`id -gn`" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 8 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 11 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by size"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    cp ../test_fixtures/test.txt test/test1/test.txt
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -size 10 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/test.txt EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by size with plus"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    cp ../test_fixtures/test.txt test/test1/test.txt
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -size +9 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/test.txt EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by size with minus"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    cp ../test_fixtures/test.txt test/test1/test.txt
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -size -10 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 8 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 11 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by size with c character"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    cp ../test_fixtures/test.txt test/test1/test.txt
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -size 4623c > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/test.txt EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by size with plus and c character"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    cp ../test_fixtures/test.txt test/test1/test.txt
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -size +4622c > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/test.txt EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by size with minus and c character"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    cp ../test_fixtures/test.txt test/test1/test.txt
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -size -4623c > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 8 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 11 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by access time with plus"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    touch -at 200101010000.00 test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -atime +365 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by modification time with plus"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    touch -mt 200101010000.00 test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -mtime +365 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by exec operand with echo program"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -exec echo xxx '{}' ';' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 8 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^xxx test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^xxx test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^xxx test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^xxx test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^xxx test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^xxx test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^xxx test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^xxx test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 11 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by exec operand with test program and print operand"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -exec test -f '{}' ';' -print > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 5 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 8 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by exec operand with plus and echo program"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -exec echo abc '{}' + > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 'abc' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 4 'test' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 5 'test/xxx' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 6 'test/yyy' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 7 'test/test1' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 8 'test/test1/xxx' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 9 'test/test1/yyy' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 11 'test/test2' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 12 'test/test2/xxx' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by two exec operands with pluses and echo program"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test -name abc -exec echo xxx '{}' + -o -name def -exec echo yyy '{}' + > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'xxx test/abc' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'yyy test/def' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by ok operand with echo program"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    echo n > replies.txt
    echo y >> replies.txt
    echo y >> replies.txt
    echo y >> replies.txt
    echo y >> replies.txt
    echo y >> replies.txt
    echo y >> replies.txt
    echo y >> replies.txt
    cat replies.txt | "../$RSUBOX" find test -ok echo xxx '{}' ';' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 7 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^xxx test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^xxx test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^xxx test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^xxx test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^xxx test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^xxx test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^xxx test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt
end_test

start_test find "find finds files and directories by print operand"
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    "../$RSUBOX" find test -print > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 8 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test1 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/test1/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 9 '^test/test2 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 10 '^test/test2/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 11 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by print operand and names"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test -name 'ab*' -print -o -name 'de*' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/abc EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test/ab12 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/abz EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories by newer operand"
    echo xxx > xxx
    touch -mt 200101020000.00 xxx
    mkdir test
    echo xxx > test/xxx
    echo yyy > test/yyy
    mkdir test/test1
    echo xxx > test/test1/xxx
    echo yyy > test/test1/yyy
    mkdir test/test2
    echo xxx > test/test2/xxx
    touch -mt 200101010000.00 test/test1/xxx
    touch -mt 200101040000.00 test/test1/yyy
    touch -mt 200101010000.00 test/test1
    touch -mt 200101010000.00 test/test2/xxx
    touch -mt 200101010000.00 test/test2
    touch -mt 200101030000.00 test/xxx
    touch -mt 200101010000.00 test/yyy
    touch -mt 200101010000.00 test
    "../$RSUBOX" find test -newer xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test1/yyy EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories without depth operand"
    mkdir test
    mkdir test/test1
    "../$RSUBOX" find test > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'test' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'test/test1' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories with depth operand"
    mkdir test
    mkdir test/test1
    "../$RSUBOX" find test -depth > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'test/test1' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'test' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories with logical-NOT operator"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test ! -name 'ab*' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 5 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/def EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test/de34 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/abz/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 8 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories with two logical-NOT operators"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test ! ! -name 'ab*' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/abc EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test/ab12 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/abz EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories with logical-AND operator"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test -name 'ab*' -a -type f > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/abc EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test/ab12 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories with logical-AND operator without -a operand"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test -name 'ab*' -type f > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/abc EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test/ab12 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories with logical-OR operator"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test -name 'ab*' -o -type f > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 6 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/abc EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/def EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test/ab12 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test/de34 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 7 '^test/abz EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 8 '^test/abz/xxx EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 9 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories with logical-AND operators and logical-OR operator"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test -name 'ab*' -a -type d -o -name 'de*' -a -type f > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/def EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/test/de34 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/abz EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test find "find finds files and directories with logical operators and parentheses"
    mkdir test
    echo abc > test/abc
    echo def > test/def
    mkdir test/test
    echo ab12 > test/test/ab12
    echo de34 > test/test/de34
    mkdir test/abz
    echo xxx > test/abz/xxx
    "../$RSUBOX" find test -type f -a \( -name 'ab*' -o -name 'de*' \) > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    cat ../test_tmp/stdout.txt | xargs -I arg echo arg EOL > ../test_tmp/stdout_xargs.txt

    assert 1 [ 0 = "$status" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 3 '^test/abc EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 4 '^test/def EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 5 '^test/test/ab12 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_content_pattern 6 '^test/test/de34 EOL' ../test_tmp/stdout_xargs.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test find "find complains on non-existent file"
    "../$RSUBOX" find xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test find "find complains on syntax error for unknown operand"
    echo xxx > xxx
    "../$RSUBOX" find xxx -xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Syntax error' ../test_tmp/stderr.txt
end_test

start_test find "find complains on unclosed parentheses"
    echo xxx > xxx
    "../$RSUBOX" find xxx \( -name xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Unclosed parentheses' ../test_tmp/stderr.txt
end_test

start_test find "find complains on invalid mode without minus"
    echo xxx > xxx
    "../$RSUBOX" find xxx -perm yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid mode' ../test_tmp/stderr.txt
end_test

start_test find "find complains on invalid mode with minus"
    echo xxx > xxx
    "../$RSUBOX" find xxx -perm -yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid mode' ../test_tmp/stderr.txt
end_test

start_test find "find complains on invalid file type"
    echo xxx > xxx
    "../$RSUBOX" find xxx -type x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid file type' ../test_tmp/stderr.txt
end_test

start_test find "find complains on invalid file type"
    echo xxx > xxx
    "../$RSUBOX" find xxx -type x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid file type' ../test_tmp/stderr.txt
end_test

start_test find "find complains on no argument"
    echo xxx > xxx
    "../$RSUBOX" find xxx -type > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'No argument' ../test_tmp/stderr.txt
end_test

start_test find "find complains on no argument for exec operand"
    echo xxx > xxx
    "../$RSUBOX" find xxx -exec echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'No argument' ../test_tmp/stderr.txt
end_test

start_test find "find complains on non-existent program for exec operand"
    echo xxx > xxx
    "../$RSUBOX" find xxx -exec ./yyy '{}' ';' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\./yyy: ' ../test_tmp/stderr.txt
end_test

start_test find "find complains on too many {} for exec operand with plus"
    echo xxx > xxx
    "../$RSUBOX" find xxx -exec echo '{}' '{}' + > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Only one occurrence of {} is supported' ../test_tmp/stderr.txt
end_test

start_test find "find complains on non-existent program for exec operand with plus"
    echo xxx > xxx
    "../$RSUBOX" find xxx -exec ./yyy '{}' + > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\./yyy: ' ../test_tmp/stderr.txt
end_test

start_test find "find complains on no argument for ok operand"
    echo xxx > xxx
    echo -n | "../$RSUBOX" find xxx -ok echo > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'No argument' ../test_tmp/stderr.txt
end_test

start_test find "find complains on non-existent program for ok operand"
    echo xxx > xxx
    echo y | "../$RSUBOX" find xxx -ok ./yyy '{}' ';' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\./yyy xxx? ./yyy: ' ../test_tmp/stderr.txt
end_test

start_test find "find complains on non-existent file for newer operand"
    echo xxx > xxx
    "../$RSUBOX" find xxx -newer yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^yyy: ' ../test_tmp/stderr.txt
end_test
