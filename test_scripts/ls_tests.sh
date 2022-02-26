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
start_test ls "ls prints list of files"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 9 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 aaa ../test_tmp/stdout.txt &&
    assert_file_line 4 2 asdfghjkl ../test_tmp/stdout.txt &&
    assert_file_line 5 3 bbb ../test_tmp/stdout.txt &&
    assert_file_line 6 4 ccc ../test_tmp/stdout.txt &&
    assert_file_line 7 5 qwertyuiop ../test_tmp/stdout.txt &&
    assert_file_line 8 6 test1 ../test_tmp/stdout.txt &&
    assert_file_line 9 7 test2 ../test_tmp/stdout.txt &&
    assert_file_line 10 8 xxx ../test_tmp/stdout.txt &&
    assert_file_line 11 9 yyy ../test_tmp/stdout.txt &&
    assert_file_size 12 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for long format"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -l > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^l.........  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^prw-------  *1  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^-rwxr-xr-x  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for comma format"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -m > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'aaa, asdfghjkl, bbb, ccc, qwertyuiop, test1, test2, xxx, yyy' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for multi-text-columns and up to down"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -C > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'aaa        bbb        qwertyuiop test2      yyy' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'asdfghjkl  ccc        test1      xxx' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for multi-text-columns and left to right"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -x > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'aaa        asdfghjkl  bbb        ccc        qwertyuiop test1      test2' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'xxx        yyy' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints files and directories for no dereference option"
    mkdir -m 755 test1
    echo xxx > test1/xxx
    chmod 644 test1/xxx
    mkdir -m 755 test1/test
    echo xxx > test1/test/xxx
    chmod 644 test1/test/xxx
    echo yyy > test1/test/yyy
    chmod 644 test1/test/yyy
    ln -s ../test3 test1/test3
    mkdir -m 755 test2
    echo xxx > test2/xxx
    chmod 644 test2/xxx
    echo yyy > test2/yyy
    chmod 644 test2/yyy
    mkdir -m 755 test3
    echo xxx > test3/xxx
    chmod 644 test3/xxx
    echo xxx > xxx
    chmod 644 xxx
    ln -s xxx yyy
    ln -s aaa zzz
    "../$RSUBOX" ls -l test1 test2 xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 14 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy -> xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *zzz -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 '' ../test_tmp/stdout.txt &&
    assert_file_line 7 5 'test1:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test3 -> ../test3' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line 12 10 '' ../test_tmp/stdout.txt &&
    assert_file_line 13 11 'test2:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 14 12 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 15 13 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 16 14 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 17 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints files and directories for -H option"
    mkdir -m 755 test1
    echo xxx > test1/xxx
    chmod 644 test1/xxx
    mkdir -m 755 test1/test
    echo xxx > test1/test/xxx
    chmod 644 test1/test/xxx
    echo yyy > test1/test/yyy
    chmod 644 test1/test/yyy
    ln -s ../test3 test1/test3
    mkdir -m 755 test2
    echo xxx > test2/xxx
    chmod 644 test2/xxx
    echo yyy > test2/yyy
    chmod 644 test2/yyy
    mkdir -m 755 test3
    echo xxx > test3/xxx
    chmod 644 test3/xxx
    echo xxx > xxx
    chmod 644 xxx
    ln -s xxx yyy
    ln -s aaa zzz
    "../$RSUBOX" ls -Hl test1 test2 xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 14 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *zzz -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 '' ../test_tmp/stdout.txt &&
    assert_file_line 7 5 'test1:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test3 -> ../test3' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line 12 10 '' ../test_tmp/stdout.txt &&
    assert_file_line 13 11 'test2:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 14 12 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 15 13 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 16 14 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 17 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints files and directories for -L option"
    mkdir -m 755 test1
    echo xxx > test1/xxx
    chmod 644 test1/xxx
    mkdir -m 755 test1/test
    echo xxx > test1/test/xxx
    chmod 644 test1/test/xxx
    echo yyy > test1/test/yyy
    chmod 644 test1/test/yyy
    ln -s ../test3 test1/test3
    mkdir -m 755 test2
    echo xxx > test2/xxx
    chmod 644 test2/xxx
    echo yyy > test2/yyy
    chmod 644 test2/yyy
    mkdir -m 755 test3
    echo xxx > test3/xxx
    chmod 644 test3/xxx
    echo xxx > xxx
    chmod 644 xxx
    ln -s xxx yyy
    ln -s aaa zzz
    "../$RSUBOX" ls -Ll test1 test2 xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 14 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *zzz -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 '' ../test_tmp/stdout.txt &&
    assert_file_line 7 5 'test1:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test3' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line 12 10 '' ../test_tmp/stdout.txt &&
    assert_file_line 13 11 'test2:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 14 12 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 15 13 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 16 14 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 17 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls recursively prints files and directories for no dereference option"
    mkdir -m 755 test1
    echo xxx > test1/xxx
    chmod 644 test1/xxx
    mkdir -m 755 test1/test
    echo xxx > test1/test/xxx
    chmod 644 test1/test/xxx
    echo yyy > test1/test/yyy
    chmod 644 test1/test/yyy
    ln -s ../test3 test1/test3
    mkdir -m 755 test2
    echo xxx > test2/xxx
    chmod 644 test2/xxx
    echo yyy > test2/yyy
    chmod 644 test2/yyy
    mkdir -m 755 test3
    echo xxx > test3/xxx
    chmod 644 test3/xxx
    echo xxx > xxx
    chmod 644 xxx
    ln -s xxx yyy
    ln -s aaa zzz
    "../$RSUBOX" ls -Rl test1 test2 xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 19 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy -> xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *zzz -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 '' ../test_tmp/stdout.txt &&
    assert_file_line 7 5 'test1:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test3 -> ../test3' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line 12 10 '' ../test_tmp/stdout.txt &&
    assert_file_line 13 11 'test1/test:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 14 12 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 15 13 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 16 14 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_line 17 15 '' ../test_tmp/stdout.txt &&
    assert_file_line 18 16 'test2:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 19 17 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 20 18 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 21 19 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 22 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls recursively prints files and directories for -H option"
    mkdir -m 755 test1
    echo xxx > test1/xxx
    chmod 644 test1/xxx
    mkdir -m 755 test1/test
    echo xxx > test1/test/xxx
    chmod 644 test1/test/xxx
    echo yyy > test1/test/yyy
    chmod 644 test1/test/yyy
    ln -s ../test3 test1/test3
    mkdir -m 755 test2
    echo xxx > test2/xxx
    chmod 644 test2/xxx
    echo yyy > test2/yyy
    chmod 644 test2/yyy
    mkdir -m 755 test3
    echo xxx > test3/xxx
    chmod 644 test3/xxx
    echo xxx > xxx
    chmod 644 xxx
    ln -s xxx yyy
    ln -s aaa zzz
    "../$RSUBOX" ls -RHl test1 test2 xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 19 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *zzz -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 '' ../test_tmp/stdout.txt &&
    assert_file_line 7 5 'test1:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test3 -> ../test3' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line 12 10 '' ../test_tmp/stdout.txt &&
    assert_file_line 13 11 'test1/test:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 14 12 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 15 13 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 16 14 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_line 17 15 '' ../test_tmp/stdout.txt &&
    assert_file_line 18 16 'test2:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 19 17 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 20 18 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 21 19 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 22 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls recursively prints files and directories for -L option"
    mkdir -m 755 test1
    echo xxx > test1/xxx
    chmod 644 test1/xxx
    mkdir -m 755 test1/test
    echo xxx > test1/test/xxx
    chmod 644 test1/test/xxx
    echo yyy > test1/test/yyy
    chmod 644 test1/test/yyy
    ln -s ../test3 test1/test3
    mkdir -m 755 test2
    echo xxx > test2/xxx
    chmod 644 test2/xxx
    echo yyy > test2/yyy
    chmod 644 test2/yyy
    mkdir -m 755 test3
    echo xxx > test3/xxx
    chmod 644 test3/xxx
    echo xxx > xxx
    chmod 644 xxx
    ln -s xxx yyy
    ln -s aaa zzz
    "../$RSUBOX" ls -RLl test1 test2 xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 23 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *zzz -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 '' ../test_tmp/stdout.txt &&
    assert_file_line 7 5 'test1:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test3' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line 12 10 '' ../test_tmp/stdout.txt &&
    assert_file_line 13 11 'test1/test:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 14 12 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 15 13 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 16 14 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_line 17 15 '' ../test_tmp/stdout.txt &&
    assert_file_line 18 16 'test1/test3:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 19 17 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 20 18 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line 21 19 '' ../test_tmp/stdout.txt &&
    assert_file_line 22 20 'test2:' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 23 21 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 24 22 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 25 23 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 26 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints last data modification times for long format"
    echo xxx > xxx
    chmod 644 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    chmod 644 yyy
    touch -at 200201010000.00 yyy
    touch -mt 200101010000.00 yyy
    "../$RSUBOX" ls -l > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9]  2002 xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9]  2001 yyy' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints last modification times for long format"
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 644 yyy
    "../$RSUBOX" ls -lc > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints access times for long format"
    echo xxx > xxx
    chmod 644 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    chmod 644 yyy
    touch -at 200201010000.00 yyy
    touch -mt 200101010000.00 yyy
    "../$RSUBOX" ls -lu > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9]  2001 xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9]  2002 yyy' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls sorts by last data modification time"
    echo xxx > xxx
    chmod 644 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    chmod 644 yyy
    touch -at 200201010000.00 yyy
    touch -mt 200101010000.00 yyy
    "../$RSUBOX" ls -t > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 xxx ../test_tmp/stdout.txt &&
    assert_file_line 4 2 yyy ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls sorts by data modification time for long format"
    echo xxx > xxx
    chmod 644 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    chmod 644 yyy
    touch -at 200201010000.00 yyy
    touch -mt 200101010000.00 yyy
    "../$RSUBOX" ls -lt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9]  2002 xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9]  2001 yyy' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls sorts by last modification time"
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 644 yyy
    "../$RSUBOX" ls -tc > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^..*' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test


start_test ls "ls sorts by last modification time for long format"
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 644 yyy
    "../$RSUBOX" ls -ltc > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *..*' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls sorts by access time"
    echo xxx > xxx
    chmod 644 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    chmod 644 yyy
    touch -at 200201010000.00 yyy
    touch -mt 200101010000.00 yyy
    "../$RSUBOX" ls -tu > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 yyy ../test_tmp/stdout.txt &&
    assert_file_line 4 2 xxx ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls sorts by access time for long format"
    echo xxx > xxx
    chmod 644 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    chmod 644 yyy
    touch -at 200201010000.00 yyy
    touch -mt 200101010000.00 yyy
    "../$RSUBOX" ls -ltu > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9]  2002 yyy' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9]  2001 xxx' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints mode with set-user/group-ID and stick bit for long format"
    echo xxx > xxx
    chmod 7644 xxx
    echo yyy > yyy
    chmod 7755 yyy
    "../$RSUBOX" ls -l > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rwSr-Sr-T  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rwsr-sr-t  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints number of links for long format"
    echo xxx > xxx
    chmod 644 xxx
    ln xxx yyy
    "../$RSUBOX" ls -l > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *2  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *2  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints files and directories for -d option"
    mkdir -m 755 test1
    echo xxx > test1/xxx
    chmod 644 test1/xxx
    mkdir -m 755 test1/test
    echo xxx > test1/test/xxx
    chmod 644 test1/test/xxx
    echo yyy > test1/test/yyy
    chmod 644 test1/test/yyy
    ln -s ../test3 test1/test3
    mkdir -m 755 test2
    echo xxx > test2/xxx
    chmod 644 test2/xxx
    echo yyy > test2/yyy
    chmod 644 test2/yyy
    mkdir -m 755 test3
    echo xxx > test3/xxx
    chmod 644 test3/xxx
    echo xxx > xxx
    chmod 644 xxx
    ln -s xxx yyy
    ln -s aaa zzz
    "../$RSUBOX" ls -d test1 test2 xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 5 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 test1 ../test_tmp/stdout.txt &&
    assert_file_line 4 2 test2 ../test_tmp/stdout.txt &&
    assert_file_line 5 3 xxx ../test_tmp/stdout.txt &&
    assert_file_line 6 4 yyy ../test_tmp/stdout.txt &&
    assert_file_line 7 5 zzz ../test_tmp/stdout.txt &&
    assert_file_size 8 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints files and directories for -d option and long format"
    mkdir -m 755 test1
    echo xxx > test1/xxx
    chmod 644 test1/xxx
    mkdir -m 755 test1/test
    echo xxx > test1/test/xxx
    chmod 644 test1/test/xxx
    echo yyy > test1/test/yyy
    chmod 644 test1/test/yyy
    ln -s ../test3 test1/test3
    mkdir -m 755 test2
    echo xxx > test2/xxx
    chmod 644 test2/xxx
    echo yyy > test2/yyy
    chmod 644 test2/yyy
    mkdir -m 755 test3
    echo xxx > test3/xxx
    chmod 644 test3/xxx
    echo xxx > xxx
    chmod 644 xxx
    ln -s xxx yyy
    ln -s aaa zzz
    "../$RSUBOX" ls -ld test1 test2 xxx yyy zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 5 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^drwxr-xr-x  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1 '"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy -> xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^l.........  *[0-9][0-9]* '"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *zzz -> aaa' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for one column"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -1 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 9 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 aaa ../test_tmp/stdout.txt &&
    assert_file_line 4 2 asdfghjkl ../test_tmp/stdout.txt &&
    assert_file_line 5 3 bbb ../test_tmp/stdout.txt &&
    assert_file_line 6 4 ccc ../test_tmp/stdout.txt &&
    assert_file_line 7 5 qwertyuiop ../test_tmp/stdout.txt &&
    assert_file_line 8 6 test1 ../test_tmp/stdout.txt &&
    assert_file_line 9 7 test2 ../test_tmp/stdout.txt &&
    assert_file_line 10 8 xxx ../test_tmp/stdout.txt &&
    assert_file_line 11 9 yyy ../test_tmp/stdout.txt &&
    assert_file_size 12 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for indicator option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -F > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 9 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 aaa ../test_tmp/stdout.txt &&
    assert_file_line 4 2 asdfghjkl ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'bbb@' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'ccc|' ../test_tmp/stdout.txt &&
    assert_file_line 7 5 qwertyuiop ../test_tmp/stdout.txt &&
    assert_file_line 8 6 test1/ ../test_tmp/stdout.txt &&
    assert_file_line 9 7 test2/ ../test_tmp/stdout.txt &&
    assert_file_line 10 8 xxx ../test_tmp/stdout.txt &&
    assert_file_line 11 9 'yyy*' ../test_tmp/stdout.txt &&
    assert_file_size 12 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for directory indicator option and long format"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -Fl > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^l.........  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb@ -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^prw-------  *1  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc|' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1/' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2/' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^-rwxr-xr-x  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy\*' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for directory indicator option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -p > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 9 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 aaa ../test_tmp/stdout.txt &&
    assert_file_line 4 2 asdfghjkl ../test_tmp/stdout.txt &&
    assert_file_line 5 3 bbb ../test_tmp/stdout.txt &&
    assert_file_line 6 4 ccc ../test_tmp/stdout.txt &&
    assert_file_line 7 5 qwertyuiop ../test_tmp/stdout.txt &&
    assert_file_line 8 6 test1/ ../test_tmp/stdout.txt &&
    assert_file_line 9 7 test2/ ../test_tmp/stdout.txt &&
    assert_file_line 10 8 xxx ../test_tmp/stdout.txt &&
    assert_file_line 11 9 yyy ../test_tmp/stdout.txt &&
    assert_file_size 12 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for indicator option and long format"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -pl > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^l.........  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^prw-------  *1  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1/' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2/' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^-rwxr-xr-x  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of all files"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -a > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 12 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 . ../test_tmp/stdout.txt &&
    assert_file_line 4 2 .. ../test_tmp/stdout.txt &&
    assert_file_line 5 3 .config ../test_tmp/stdout.txt &&
    assert_file_line 6 4 aaa ../test_tmp/stdout.txt &&
    assert_file_line 7 5 asdfghjkl ../test_tmp/stdout.txt &&
    assert_file_line 8 6 bbb ../test_tmp/stdout.txt &&
    assert_file_line 9 7 ccc ../test_tmp/stdout.txt &&
    assert_file_line 10 8 qwertyuiop ../test_tmp/stdout.txt &&
    assert_file_line 11 9 test1 ../test_tmp/stdout.txt &&
    assert_file_line 12 10 test2 ../test_tmp/stdout.txt &&
    assert_file_line 13 11 xxx ../test_tmp/stdout.txt &&
    assert_file_line 14 12 yyy ../test_tmp/stdout.txt &&
    assert_file_size 15 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for force option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -f > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 12 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 13 11 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 14 12 '^..*' ../test_tmp/stdout.txt &&
    assert_file_size 15 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls turns -l, -t, -s and -r off for force option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -fltsr > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 12 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 13 11 '^..*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 14 12 '^..*' ../test_tmp/stdout.txt &&
    assert_file_size 15 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for no owner option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -g > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1  *'"`id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1  *'"`id -gn`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^l.........  *[0-9][0-9]*  *'"`id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^prw-------  *1  *'"`id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^-rw-r--r--  *1  *'"`id -gn`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1  *'"`id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^-rwxr-xr-x  *1  *'"`id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for no group option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -o > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1  *'"`id -un`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1  *'"`id -un`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^l.........  *[0-9][0-9]*  *'"`id -un`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^prw-------  *1  *'"`id -un`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^-rw-r--r--  *1  *'"`id -un`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -un`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -un`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1  *'"`id -un`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^-rwxr-xr-x  *1  *'"`id -un`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for no owner option and no group option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -go > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^l.........  *[0-9][0-9]*  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^prw-------  *1  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^-rw-r--r--  *1  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]*  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]*  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^-rwxr-xr-x  *1  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for numeric and long format"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -ln > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^-rw-r--r--  *1  *'"`id -u` `id -g`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^-rw-r--r--  *1  *'"`id -u` `id -g`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^l.........  *[0-9][0-9]*  *'"`id -u` `id -g`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^prw-------  *1  *'"`id -u` `id -g`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^-rw-r--r--  *1  *'"`id -u` `id -g`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -u` `id -g`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^drwxr-xr-x  *[0-9][0-9]*  *'"`id -u` `id -g`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^-rw-r--r--  *1  *'"`id -u` `id -g`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^-rwxr-xr-x  *1  *'"`id -u` `id -g`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for reverse option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -r > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 9 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 yyy ../test_tmp/stdout.txt &&
    assert_file_line 4 2 xxx ../test_tmp/stdout.txt &&
    assert_file_line 5 3 test2 ../test_tmp/stdout.txt &&
    assert_file_line 6 4 test1 ../test_tmp/stdout.txt &&
    assert_file_line 7 5 qwertyuiop ../test_tmp/stdout.txt &&
    assert_file_line 8 6 ccc ../test_tmp/stdout.txt &&
    assert_file_line 9 7 bbb ../test_tmp/stdout.txt &&
    assert_file_line 10 8 asdfghjkl ../test_tmp/stdout.txt &&
    assert_file_line 11 9 aaa ../test_tmp/stdout.txt &&
    assert_file_size 12 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for inode option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -i > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 9 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^ *[0-9][0-9]* aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^ *[0-9][0-9]* asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^ *[0-9][0-9]* bbb' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^ *[0-9][0-9]* ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^ *[0-9][0-9]* qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^ *[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^ *[0-9][0-9]* test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^ *[0-9][0-9]* xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^ *[0-9][0-9]* yyy' ../test_tmp/stdout.txt &&
    assert_file_size 12 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for inode option and long format"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -li > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^ *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^ *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^ *[0-9][0-9]* l.........  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^ *[0-9][0-9]* prw-------  *1  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^ *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^ *[0-9][0-9]* drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^ *[0-9][0-9]* drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^ *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^ *[0-9][0-9]* -rwxr-xr-x  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for size option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -s > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 9 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^ *[0-9][0-9]* aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^ *[0-9][0-9]* asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^ *[0-9][0-9]* bbb' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^ *[0-9][0-9]* ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^ *[0-9][0-9]* qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^ *[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^ *[0-9][0-9]* test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^ *[0-9][0-9]* xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^ *[0-9][0-9]* yyy' ../test_tmp/stdout.txt &&
    assert_file_size 12 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for size option and long format"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -ls > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^ *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^ *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^ *[0-9][0-9]* l.........  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^ *[0-9][0-9]* prw-------  *1  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^ *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^ *[0-9][0-9]* drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^ *[0-9][0-9]* drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^ *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^ *[0-9][0-9]* -rwxr-xr-x  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for inode option and size option"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -is > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 9 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^ *[0-9][0-9]*  *[0-9][0-9]* aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^ *[0-9][0-9]*  *[0-9][0-9]* asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^ *[0-9][0-9]*  *[0-9][0-9]* bbb' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^ *[0-9][0-9]*  *[0-9][0-9]* ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^ *[0-9][0-9]*  *[0-9][0-9]* qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^ *[0-9][0-9]*  *[0-9][0-9]* test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^ *[0-9][0-9]*  *[0-9][0-9]* test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^ *[0-9][0-9]*  *[0-9][0-9]* xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^ *[0-9][0-9]*  *[0-9][0-9]* yyy' ../test_tmp/stdout.txt &&
    assert_file_size 12 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls prints list of files for inode option, size option and long format"
    echo .config > .config
    chmod 644 .config
    echo aaa > aaa
    chmod 644 aaa
    echo asdfghjkl > asdfghjkl
    chmod 644 asdfghjkl
    ln -s aaa bbb
    mkfifo -m 600 ccc
    echo qwertyuiop > qwertyuiop
    chmod 644 qwertyuiop
    mkdir -m 755 test1
    mkdir -m 755 test2
    echo xxx > xxx
    chmod 644 xxx
    echo yyy > yyy
    chmod 755 yyy
    "../$RSUBOX" ls -lis > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 10 ../test_tmp/stdout.txt &&
    assert_file_line_pattern 3 1 '^total [0-9][0-9]*' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 4 2 '^ *[0-9][0-9]*  *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 5 3 '^ *[0-9][0-9]*  *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *10 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *asdfghjkl' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 6 4 '^ *[0-9][0-9]*  *[0-9][0-9]* l.........  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9:\][0-9\:]*  *bbb -> aaa' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 7 5 '^ *[0-9][0-9]*  *[0-9][0-9]* prw-------  *1  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *ccc' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 8 6 '^ *[0-9][0-9]*  *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *11 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *qwertyuiop' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 9 7 '^ *[0-9][0-9]*  *[0-9][0-9]* drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test1' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 10 8 '^ *[0-9][0-9]*  *[0-9][0-9]* drwxr-xr-x  *[0-9][0-9]*  *'"`id -un` `id -gn`"'  *[0-9][0-9]* [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *test2' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 11 9 '^ *[0-9][0-9]*  *[0-9][0-9]* -rw-r--r--  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *xxx' ../test_tmp/stdout.txt &&
    assert_file_line_pattern 12 10 '^ *[0-9][0-9]*  *[0-9][0-9]* -rwxr-xr-x  *1  *'"`id -un` `id -gn`"'  *4 [A-Z][a-z][a-z] [0-9 ][0-9] [0-9: ][0-9:]*  *yyy' ../test_tmp/stdout.txt &&
    assert_file_size 13 0 ../test_tmp/stderr.txt
end_test

start_test ls "ls complains on non-existent file"
    "../$RSUBOX" ls xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test
