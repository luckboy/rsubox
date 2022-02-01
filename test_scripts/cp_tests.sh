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
start_test cp "cp copies small file"
    echo xxx > xxx
    "../$RSUBOX" cp xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test cp "cp copies big file"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" cp xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_compare_files 7 ../test_fixtures/test.txt yyy
end_test

start_test cp "cp copies one file to directory"
    echo xxx > xxx
    mkdir dst
    "../$RSUBOX" cp xxx dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 dst &&
    assert_file_mode 6 '^d' dst &&
    assert_existent_file 7 dst/xxx &&
    assert_file_mode 8 '^-' dst/xxx &&
    assert_file_content 9 xxx dst/xxx
end_test

start_test cp "cp copies two files to directory"
    echo xxx > xxx
    echo yyy > yyy
    mkdir dst
    "../$RSUBOX" cp xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^-' dst/xxx &&
    assert_file_content 10 xxx dst/xxx &&
    assert_existent_file 11 dst/yyy &&
    assert_file_mode 12 '^-' dst/yyy &&
    assert_file_content 13 yyy dst/yyy
end_test

start_test cp "cp copies files for no dereference option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir dst
    "../$RSUBOX" cp xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^-' dst/xxx &&
    assert_file_content 10 xxx dst/xxx &&
    assert_existent_file 11 dst/yyy &&
    assert_file_mode 12 '^-' dst/yyy &&
    assert_file_content 13 zzz dst/yyy
end_test

start_test cp "cp copies files for -H option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir dst
    "../$RSUBOX" cp -H xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^-' dst/xxx &&
    assert_file_content 10 xxx dst/xxx &&
    assert_existent_file 11 dst/yyy &&
    assert_file_mode 12 '^-' dst/yyy && 
    assert_file_content 13 zzz dst/yyy
end_test

start_test cp "cp copies files for -L option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir dst
    "../$RSUBOX" cp -L xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^-' dst/xxx &&
    assert_file_content 10 xxx dst/xxx &&
    assert_existent_file 11 dst/yyy &&
    assert_file_mode 12 '^-' dst/yyy &&
    assert_file_content 13 zzz dst/yyy
end_test

start_test cp "cp copies files for -P option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir dst
    "../$RSUBOX" cp -P xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst && 
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^-' dst/xxx && 
    assert_file_content 10 xxx dst/xxx &&
    assert_file_mode 11 '^l' dst/yyy &&
    assert_file_link 12 zzz dst/yyy
end_test

start_test cp "cp recursively copies directory for -R option"
    mkdir src
    echo xxx > src/xxx
    mkdir src/test
    echo yyy > src/test/yyy
    echo zzz > src/test/zzz
    "../$RSUBOX" cp -R src dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 src/test &&
    assert_existent_file 7 src/test/yyy &&
    assert_existent_file 8 src/test/zzz &&
    assert_existent_file 9 dst &&
    assert_file_mode 10 '^drwx' dst &&
    assert_existent_file 11 dst/xxx &&
    assert_file_mode 12 '^-' dst/xxx &&
    assert_file_content 13 xxx dst/xxx &&
    assert_existent_file 14 dst/test &&
    assert_file_mode 15 '^drwx' dst/test &&
    assert_existent_file 16 dst/test/yyy &&
    assert_file_mode 17 '^-' dst/test/yyy &&
    assert_file_content 18 yyy dst/test/yyy &&
    assert_existent_file 19 dst/test/zzz &&
    assert_file_mode 20 '^-' dst/test/zzz &&
    assert_file_content 21 zzz dst/test/zzz
end_test

start_test cp "cp recursively copies directory for -r option"
    mkdir src
    echo xxx > src/xxx
    mkdir src/test
    echo yyy > src/test/yyy
    echo zzz > src/test/zzz
    "../$RSUBOX" cp -r src dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 src/test &&
    assert_existent_file 7 src/test/yyy &&
    assert_existent_file 8 src/test/zzz &&
    assert_existent_file 9 dst &&
    assert_file_mode 10 '^drwx' dst &&
    assert_existent_file 11 dst/xxx &&
    assert_file_mode 12 '^-' dst/xxx &&
    assert_file_content 13 xxx dst/xxx &&
    assert_existent_file 14 dst/test &&
    assert_file_mode 15 '^drwx' dst/test &&
    assert_existent_file 16 dst/test/yyy &&
    assert_file_mode 17 '^-' dst/test/yyy &&
    assert_file_content 18 yyy dst/test/yyy &&
    assert_existent_file 19 dst/test/zzz &&
    assert_file_mode 20 '^-' dst/test/zzz &&
    assert_file_content 21 zzz dst/test/zzz
end_test

start_test cp "cp recursively copies directories and file for no dereference option"
    mkdir src
    echo xxx > src/xxx
    mkdir src/test
    echo yyy > src/test/yyy
    ln -s aaa src/test/zzz
    echo aaa > src/test/aaa
    ln -s yyy src2
    echo yyy > yyy
    mkdir src3
    echo yyy > src3/yyy
    echo zzz > src3/zzz
    mkdir dst
    "../$RSUBOX" cp -R src src2 src3 dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 src/test &&
    assert_existent_file 7 src/test/yyy &&
    assert_existent_file 8 src/test/zzz &&
    assert_existent_file 9 src/test/aaa &&
    assert_existent_file 10 src2 &&
    assert_existent_file 11 src3 &&
    assert_existent_file 12 src3/yyy &&
    assert_existent_file 13 src3/yyy &&
    assert_existent_file 14 dst &&
    assert_file_mode 15 '^d' dst &&
    assert_existent_file 16 dst/src &&
    assert_file_mode 17 '^drwx' dst/src &&
    assert_existent_file 18 dst/src/xxx &&
    assert_file_mode 19 '^-' dst/src/xxx &&
    assert_file_content 20 xxx dst/src/xxx &&
    assert_existent_file 21 dst/src/test &&
    assert_file_mode 22 '^drwx' dst/src/test &&
    assert_existent_file 23 dst/src/test/yyy &&
    assert_file_mode 24 '^-' dst/src/test/yyy &&
    assert_file_content 25 yyy dst/src/test/yyy &&
    assert_existent_file 26 dst/src/test/zzz &&
    assert_file_mode 27 '^l' dst/src/test/zzz && 
    assert_file_link 28 aaa dst/src/test/zzz &&
    assert_existent_file 29 dst/src/test/aaa &&
    assert_file_mode 30 '^-' dst/src/test/aaa &&
    assert_file_content 31 aaa dst/src/test/aaa &&
    assert_file_mode 32 '^l' dst/src2 &&
    assert_file_link 33 yyy dst/src2 &&
    assert_existent_file 34 dst/src3 &&
    assert_file_mode 35 '^drwx' dst/src3 &&
    assert_existent_file 36 dst/src3/yyy &&
    assert_file_mode 37 '^-' dst/src3/yyy &&
    assert_file_content 38 yyy dst/src3/yyy &&
    assert_existent_file 39 dst/src3/zzz &&
    assert_file_mode 40 '^-' dst/src3/zzz &&
    assert_file_content 41 zzz dst/src3/zzz
end_test

start_test cp "cp recursively copies directories and file for -H option"
    mkdir src
    echo xxx > src/xxx
    mkdir src/test
    echo yyy > src/test/yyy
    ln -s aaa src/test/zzz
    echo aaa > src/test/aaa
    ln -s yyy src2
    echo yyy > yyy
    mkdir src3
    echo yyy > src3/yyy
    echo zzz > src3/zzz
    mkdir dst
    "../$RSUBOX" cp -HR src src2 src3 dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 src/test &&
    assert_existent_file 7 src/test/yyy &&
    assert_existent_file 8 src/test/zzz &&
    assert_existent_file 9 src/test/aaa &&
    assert_existent_file 10 src2 &&
    assert_existent_file 11 src3 &&
    assert_existent_file 12 src3/yyy &&
    assert_existent_file 13 src3/yyy &&
    assert_existent_file 14 dst &&
    assert_file_mode 15 '^d' dst && 
    assert_existent_file 16 dst/src &&
    assert_file_mode 17 '^drwx' dst/src &&
    assert_existent_file 18 dst/src/xxx &&
    assert_file_mode 19 '^-' dst/src/xxx &&
    assert_file_content 20 xxx dst/src/xxx &&
    assert_existent_file 21 dst/src/test &&
    assert_file_mode 22 '^drwx' dst/src/test &&
    assert_existent_file 23 dst/src/test/yyy &&
    assert_file_mode 24 '^-' dst/src/test/yyy &&
    assert_file_content 25 yyy dst/src/test/yyy &&
    assert_existent_file 26 dst/src/test/zzz &&
    assert_file_mode 27 '^l' dst/src/test/zzz &&
    assert_file_link 28 aaa dst/src/test/zzz &&
    assert_existent_file 29 dst/src/test/aaa &&
    assert_file_mode 30 '^-' dst/src/test/aaa &&
    assert_file_content 31 aaa dst/src/test/aaa &&
    assert_existent_file 32 dst/src2 &&
    assert_file_mode 33 '^-' dst/src2 &&
    assert_file_content 34 yyy dst/src2 &&
    assert_existent_file 35 dst/src3 &&
    assert_file_mode 36 '^drwx' dst/src3 &&
    assert_existent_file 37 dst/src3/yyy &&
    assert_file_mode 38 '^-' dst/src3/yyy &&
    assert_file_content 39 yyy dst/src3/yyy &&
    assert_existent_file 40 dst/src3/zzz &&
    assert_file_mode 41 '^-' dst/src3/zzz &&
    assert_file_content 42 zzz dst/src3/zzz
end_test

start_test cp "cp recursively copies directories and file for -L option"
    mkdir src
    echo xxx > src/xxx
    mkdir src/test
    echo yyy > src/test/yyy
    ln -s aaa src/test/zzz
    echo aaa > src/test/aaa
    ln -s yyy src2
    echo yyy > yyy
    mkdir src3
    echo yyy > src3/yyy
    echo zzz > src3/zzz
    mkdir dst
    "../$RSUBOX" cp -LR src src2 src3 dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 src/test &&
    assert_existent_file 7 src/test/yyy &&
    assert_existent_file 8 src/test/zzz &&
    assert_existent_file 9 src/test/aaa &&
    assert_existent_file 10 src2 &&
    assert_existent_file 11 src3 &&
    assert_existent_file 12 src3/yyy &&
    assert_existent_file 13 src3/yyy &&
    assert_existent_file 14 dst &&
    assert_file_mode 15 '^d' dst &&
    assert_existent_file 16 dst/src &&
    assert_file_mode 17 '^drwx' dst/src &&
    assert_existent_file 18 dst/src/xxx &&
    assert_file_mode 19 '^-' dst/src/xxx &&
    assert_file_content 20 xxx dst/src/xxx &&
    assert_existent_file 21 dst/src/test &&
    assert_file_mode 22 '^drwx' dst/src/test &&
    assert_existent_file 23 dst/src/test/yyy &&
    assert_file_mode 24 '^-' dst/src/test/yyy &&
    assert_file_content 25 yyy dst/src/test/yyy &&
    assert_existent_file 26 dst/src/test/zzz &&
    assert_file_mode 27 '^-' dst/src/test/zzz &&
    assert_file_content 28 aaa dst/src/test/zzz &&
    assert_existent_file 29 dst/src/test/aaa &&
    assert_file_mode 30 '^-' dst/src/test/aaa &&
    assert_file_content 31 aaa dst/src/test/aaa &&
    assert_existent_file 32 dst/src2 &&
    assert_file_mode 33 '^-' dst/src2 &&
    assert_file_content 34 yyy dst/src2 &&
    assert_existent_file 35 dst/src3 &&
    assert_file_mode 36 '^drwx' dst/src3 &&
    assert_existent_file 37 dst/src3/yyy &&
    assert_file_mode 38 '^-' dst/src3/yyy && 
    assert_file_content 39 yyy dst/src3/yyy &&
    assert_existent_file 40 dst/src3/zzz &&
    assert_file_mode 41 '^-' dst/src3/zzz &&
    assert_file_content 42 zzz dst/src3/zzz
end_test

start_test cp "cp recursively copies directories and file for -P options"
    mkdir src
    echo xxx > src/xxx
    mkdir src/test
    echo yyy > src/test/yyy
    ln -s aaa src/test/zzz
    echo aaa > src/test/aaa
    ln -s yyy src2
    echo yyy > yyy
    mkdir src3
    echo yyy > src3/yyy
    echo zzz > src3/zzz
    mkdir dst
    "../$RSUBOX" cp -PR src src2 src3 dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 src/test &&
    assert_existent_file 7 src/test/yyy &&
    assert_existent_file 8 src/test/zzz &&
    assert_existent_file 9 src/test/aaa &&
    assert_existent_file 10 src2 &&
    assert_existent_file 11 src3 &&
    assert_existent_file 12 src3/yyy &&
    assert_existent_file 13 src3/yyy &&
    assert_existent_file 14 dst &&
    assert_file_mode 15 '^d' dst &&
    assert_existent_file 16 dst/src &&
    assert_file_mode 17 '^drwx' dst/src &&
    assert_existent_file 18 dst/src/xxx &&
    assert_file_mode 19 '^-' dst/src/xxx &&
    assert_file_content 20 xxx dst/src/xxx &&
    assert_existent_file 21 dst/src/test &&
    assert_file_mode 22 '^drwx' dst/src/test &&
    assert_existent_file 13 dst/src/test/yyy &&
    assert_file_mode 24 '^-' dst/src/test/yyy &&
    assert_file_content 25 yyy dst/src/test/yyy &&
    assert_existent_file 26 dst/src/test/zzz &&
    assert_file_mode 27 '^l' dst/src/test/zzz && 
    assert_file_link 28 aaa dst/src/test/zzz &&
    assert_existent_file 29 dst/src/test/aaa &&
    assert_file_mode 30 '^-' dst/src/test/aaa &&
    assert_file_content 31 aaa dst/src/test/aaa &&
    assert_file_mode 32 '^l' dst/src2 &&
    assert_file_link 33 yyy dst/src2 &&
    assert_existent_file 34 dst/src3 &&
    assert_file_mode 35 '^drwx' dst/src3 &&
    assert_existent_file 36 dst/src3/yyy &&
    assert_file_mode 37 '^-' dst/src3/yyy &&
    assert_file_content 38 yyy dst/src3/yyy &&
    assert_existent_file 39 dst/src3/zzz &&
    assert_file_mode 40 '^-' dst/src3/zzz &&
    assert_file_content 41 zzz dst/src3/zzz
end_test

start_test cp "cp doesn't copy same file"
    echo xxx > xxx
    ln xxx yyy
    "../$RSUBOX" cp xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_nlink 7 2 yyy
end_test

start_test cp "cp preserves file status for -p option"
    echo xxx > xxx
    chmod 6644 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" cp -p xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-rwSr-Sr--' yyy &&
    assert_file_owner 7 "`id -un`" yyy &&
    assert_file_group 8 "`id -gn`" yyy &&
    assert_file_atime 9 2001 yyy &&
    assert_file_mtime 10 2002 yyy &&
    assert_file_content 11 xxx yyy
end_test

start_test cp "cp preserves directory status for -p option"
    mkdir xxx
    chmod 1755 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" cp -pR xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^drwxr-xr-t' yyy &&
    assert_file_owner 7 "`id -un`" yyy &&
    assert_file_group 8 "`id -gn`" yyy &&
    assert_file_atime 9 2001 yyy &&
    assert_file_mtime 10 2002 yyy
end_test

start_test cp "cp overwrites file"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" cp xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test cp "cp doesn't make directory"
    mkdir src
    echo xxx > src/xxx
    mkdir dst
    mkdir dst/src
    echo yyy > dst/src/yyy
    "../$RSUBOX" cp -R src dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/src &&
    assert_file_mode 9 '^d' dst/src &&
    assert_existent_file 10 dst/src/xxx &&
    assert_file_mode 11 '^-' dst/src/xxx &&
    assert_file_content 12 xxx dst/src/xxx &&
    assert_existent_file 13 dst/src/yyy &&
    assert_file_mode 14 '^-' dst/src/yyy &&
    assert_file_content 15 yyy dst/src/yyy
end_test

start_test cp "cp overwrites file for force option"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" cp -f xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test cp "cp doesn't make directory for force option"
    mkdir src
    echo xxx > src/xxx
    mkdir dst
    mkdir dst/src
    echo yyy > dst/src/yyy
    "../$RSUBOX" cp -fR src dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/src &&
    assert_file_mode 9 '^d' dst/src &&
    assert_existent_file 10 dst/src/xxx &&
    assert_file_mode 11 '^-' dst/src/xxx &&
    assert_file_content 12 xxx dst/src/xxx &&
    assert_existent_file 13 dst/src/yyy &&
    assert_file_mode 14 '^-' dst/src/yyy &&
    assert_file_content 15 yyy dst/src/yyy
end_test

start_test cp "cp copies file for interactive option"
    echo xxx > xxx
    echo -n | "../$RSUBOX" cp -i xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 4 yyy &&
    assert_file_mode 5 '^-' yyy &&
    assert_file_content 6 xxx yyy
end_test

start_test cp "cp asks for overwrite file and overwrites file for interactive option"
    echo xxx > xxx
    echo yyy > yyy
    echo -n "overwrite yyy? " > ../test_tmp/expected.txt
    echo y | "../$RSUBOX" cp -i xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test cp "cp asks for overwrite file and doesn't overwrite file for interactive option"
    echo xxx > xxx
    echo yyy > yyy
    echo -n "overwrite yyy? " > ../test_tmp/expected.txt
    echo n | "../$RSUBOX" cp -i xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 yyy yyy
end_test

start_test cp "cp doesn't make directory for interactive option"
    mkdir src
    echo xxx > src/xxx
    mkdir dst
    mkdir dst/src
    echo yyy > dst/src/yyy
    echo -n | "../$RSUBOX" cp -iR src dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 src/xxx &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/src &&
    assert_file_mode 9 '^d' dst/src &&
    assert_existent_file 10 dst/src/xxx &&
    assert_file_mode 11 '^-' dst/src/xxx &&
    assert_file_content 12 xxx dst/src/xxx &&
    assert_existent_file 13 dst/src/yyy &&
    assert_file_mode 14 '^-' dst/src/yyy &&
    assert_file_content 15 yyy dst/src/yyy
end_test

start_test cp "cp recursively copies fifo file"
    mkfifo xxx
    chmod 600 xxx
    "../$RSUBOX" cp -R xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^prw-------' yyy
end_test

start_test cp "cp overwrites symbolic link and doesn't overwrite target of symbolic link"
    echo xxx > xxx
    ln -s passwd yyy
    echo passwd > passwd
    "../$RSUBOX" cp xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy &&
    assert_existent_file 8 passwd &&
    assert_file_mode 9 '^-' passwd &&
    assert_file_content 9 passwd passwd
end_test

start_test cp "cp complains on too few arguments for zero arguments"
    "../$RSUBOX" cp > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test cp "cp complains on too few arguments for one argument"
    "../$RSUBOX" cp xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test cp "cp complains on destination that isn't directory for file"
    echo xxx > xxx
    echo yyy > yyy
    echo dst > dst
    "../$RSUBOX" cp xxx yyy dst> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'dst isn'"'"'t a directory' ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^-' dst &&
    assert_file_content 8 dst dst
end_test

start_test cp "cp complains on destination that isn't directory for non-existent file"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" cp xxx yyy dst> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'dst isn'"'"'t a directory' ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_non_existent_file 6 dst
end_test

start_test cp "cp complains on source that is directory"
    mkdir xxx
    echo yyy > yyy
    mkdir dst
    "../$RSUBOX" cp xxx yyy dst> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'xxx is a directory' ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_non_existent_file 8 dst/xxx &&
    assert_existent_file 9 dst/yyy &&
    assert_file_mode 10 '^-' dst/yyy &&
    assert_file_content 11 yyy dst/yyy
end_test

start_test cp "cp complains on source that is non-existent file"
    echo yyy > yyy
    mkdir dst
    "../$RSUBOX" cp xxx yyy dst> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 'xxx: ' ../test_tmp/stderr.txt
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_non_existent_file 8 dst/xxx &&
    assert_existent_file 9 dst/yyy &&
    assert_file_mode 10 '^-' dst/yyy &&
    assert_file_content 11 yyy dst/yyy
end_test
