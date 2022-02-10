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
start_test chown "chown changes file owner for one file"
    echo xxx > xxx
    "../$RSUBOX" chown "`id -un`" xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx
end_test

start_test chown "chown changes file owner for two files"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" chown "`id -un`" xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_existent_file 6 yyy &&
    assert_file_owner 7 "`id -un`" yyy
end_test

start_test chown "chown changes file owner"
    echo xxx > xxx
    "../$RSUBOX" chown "`id -un`" xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx
end_test

start_test chown "chown changes file owner as number"
    echo xxx > xxx
    "../$RSUBOX" chown "`id -u`" xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx
end_test

start_test chown "chown changes file owner and file group"
    echo xxx > xxx
    "../$RSUBOX" chown "`id -un`:`id -gn`" xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_file_group 6 "`id -gn`" xxx
end_test

start_test chown "chown changes file owner as number and file group as number"
    echo xxx > xxx
    "../$RSUBOX" chown "`id -u`:`id -g`" xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_file_group 6 "`id -gn`" xxx
end_test

start_test chown "chown changes file owner for no dereference option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir tst
    "../$RSUBOX" chown "`id -un`" xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_existent_file 6 zzz &&
    assert_file_owner 7 "`id -un`" zzz &&
    assert_existent_file 8 tst &&
    assert_file_owner 9 "`id -un`" tst
end_test

start_test chown "chown changes file owner for -H option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir tst
    "../$RSUBOX" chown -H "`id -un`" xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_existent_file 6 zzz &&
    assert_file_owner 7 "`id -un`" zzz &&
    assert_existent_file 8 tst &&
    assert_file_owner 9 "`id -un`" tst
end_test

start_test chown "chown changes file owner for -L option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir tst
    "../$RSUBOX" chown -L "`id -un`" xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_existent_file 6 zzz &&
    assert_file_owner 7 "`id -un`" zzz &&
    assert_existent_file 8 tst &&
    assert_file_owner 9 "`id -un`" tst
end_test

start_test chown "chown changes file owner for -P option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir tst
    "../$RSUBOX" chown -P "`id -un`" xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_existent_file 6 zzz &&
    assert_file_owner 7 "`id -un`" zzz &&
    assert_existent_file 8 tst &&
    assert_file_owner 9 "`id -un`" tst
end_test

start_test chown "chown recursively changes file owner"
    mkdir tst
    echo xxx > tst/xxx
    mkdir tst/test
    echo yyy > tst/test/yyy
    echo zzz > tst/test/zzz
    "../$RSUBOX" chown -R "`id -un`" tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_owner 5 "`id -un`" tst &&
    assert_existent_file 5 tst/xxx &&
    assert_file_owner 6 "`id -un`" tst/xxx &&
    assert_existent_file 7 tst/test &&
    assert_file_owner 8 "`id -un`" tst/test &&
    assert_existent_file 9 tst/test/yyy &&
    assert_file_owner 10 "`id -un`" tst/test/yyy &&
    assert_existent_file 11 tst/test/yyy &&
    assert_file_owner 12 "`id -un`" tst/test/yyy
end_test

start_test chown "chown recursively changes file owner for no dereference option"
    mkdir tst
    echo xxx > tst/xxx
    ln -s ../tst4 tst/test
    ln -s xxx tst2
    echo xxx > xxx
    mkdir tst3
    echo xxx > tst3/xxx
    echo yyy > tst3/yyy
    mkdir tst4
    echo xxx > tst4/xxx
    echo yyy > tst4/yyy
    "../$RSUBOX" chown -R "`id -un`" tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_owner 5 "`id -un`" tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_owner 7 "`id -un`" tst/xxx &&
    assert_existent_file 8 xxx &&
    assert_file_owner 9 "`id -un`" xxx &&
    assert_existent_file 10 tst3 &&
    assert_file_owner 11 "`id -un`" tst3 &&
    assert_existent_file 12 tst3/xxx &&
    assert_file_owner 13 "`id -un`" tst3/xxx &&
    assert_existent_file 14 tst3/yyy &&
    assert_file_owner 15 "`id -un`" tst3/yyy &&
    assert_existent_file 16 tst4 &&
    assert_file_owner 17 "`id -un`" tst4
end_test

start_test chown "chown recursively changes file owner for -H option"
    mkdir tst
    echo xxx > tst/xxx
    ln -s ../tst4 tst/test
    ln -s xxx tst2
    echo xxx > xxx
    mkdir tst3
    echo xxx > tst3/xxx
    echo yyy > tst3/yyy
    mkdir tst4
    echo xxx > tst4/xxx
    echo yyy > tst4/yyy
    "../$RSUBOX" chown -HR "`id -un`" tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_owner 5 "`id -un`" tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_owner 7 "`id -un`" tst/xxx &&
    assert_existent_file 8 xxx &&
    assert_file_owner 9 "`id -un`" xxx &&
    assert_existent_file 10 tst3 &&
    assert_file_owner 11 "`id -un`" tst3 &&
    assert_existent_file 12 tst3/xxx &&
    assert_file_owner 13 "`id -un`" tst3/xxx &&
    assert_existent_file 14 tst3/yyy &&
    assert_file_owner 15 "`id -un`" tst3/yyy &&
    assert_existent_file 16 tst4 &&
    assert_file_owner 17 "`id -un`" tst4
end_test

start_test chown "chown recursively changes file owner for -L option"
    mkdir tst
    echo xxx > tst/xxx
    ln -s ../tst4 tst/test
    ln -s xxx tst2
    echo xxx > xxx
    mkdir tst3
    echo xxx > tst3/xxx
    echo yyy > tst3/yyy
    mkdir tst4
    echo xxx > tst4/xxx
    echo yyy > tst4/yyy
    "../$RSUBOX" chown -LR "`id -un`" tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_owner 5 "`id -un`" tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_owner 7 "`id -un`" tst/xxx &&
    assert_existent_file 8 xxx &&
    assert_file_owner 9 "`id -un`" xxx &&
    assert_existent_file 10 tst3 &&
    assert_file_owner 11 "`id -un`" tst3 &&
    assert_existent_file 12 tst3/xxx &&
    assert_file_owner 13 "`id -un`" tst3/xxx &&
    assert_existent_file 14 tst3/yyy &&
    assert_file_owner 15 "`id -un`" tst3/yyy &&
    assert_existent_file 16 tst4 &&
    assert_file_owner 17 "`id -un`" tst4 &&
    assert_existent_file 18 tst4/xxx &&
    assert_file_owner 19 "`id -un`" tst4/xxx &&
    assert_existent_file 20 tst4/yyy &&
    assert_file_owner 21 "`id -un`" tst4/yyy
end_test

start_test chown "chown recursively changes file owner for -P option"
    mkdir tst
    echo xxx > tst/xxx
    ln -s ../tst4 tst/test
    ln -s xxx tst2
    echo xxx > xxx
    mkdir tst3
    echo xxx > tst3/xxx
    echo yyy > tst3/yyy
    mkdir tst4
    echo xxx > tst4/xxx
    echo yyy > tst4/yyy
    "../$RSUBOX" chown -PR "`id -un`" tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_owner 5 "`id -un`" tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_owner 7 "`id -un`" tst/xxx &&
    assert_existent_file 8 xxx &&
    assert_file_owner 9 "`id -un`" xxx &&
    assert_existent_file 10 tst3 &&
    assert_file_owner 11 "`id -un`" tst3 &&
    assert_existent_file 12 tst3/xxx &&
    assert_file_owner 13 "`id -un`" tst3/xxx &&
    assert_existent_file 14 tst3/yyy &&
    assert_file_owner 15 "`id -un`" tst3/yyy &&
    assert_existent_file 16 tst4 &&
    assert_file_owner 17 "`id -un`" tst4
end_test

start_test chown "chown changes symbolic link owner"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    "../$RSUBOX" chown -h "`id -un`" xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_existent_file 6 yyy &&
    assert_file_owner 7 "`id -un`" yyy
end_test

start_test chown "chown changes symbolic link owner for symbolic link with non-existent target"
    echo xxx > xxx
    ln -s zzz yyy
    "../$RSUBOX" chown -h "`id -un`" xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_owner 5 "`id -un`" xxx &&
    assert_file_owner 6 "`id -un`" yyy
end_test

start_test chown "chown complains on too few arguments"
    "../$RSUBOX" chown "`id -un`" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test chown "chown complains on too few arguments for no owner"
    "../$RSUBOX" chown > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test
