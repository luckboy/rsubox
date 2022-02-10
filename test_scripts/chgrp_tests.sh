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
start_test chgrp "chgrp changes file group for one file"
    echo xxx > xxx
    "../$RSUBOX" chgrp "`id -gn`" xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx
end_test

start_test chgrp "chgrp changes file group for two files"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" chgrp "`id -gn`" xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx &&
    assert_existent_file 6 yyy &&
    assert_file_group 7 "`id -gn`" yyy
end_test

start_test chgrp "chgrp changes file group"
    echo xxx > xxx
    "../$RSUBOX" chgrp "`id -gn`" xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx
end_test

start_test chgrp "chgrp changes file group as number"
    echo xxx > xxx
    "../$RSUBOX" chgrp "`id -g`" xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx
end_test

start_test chgrp "chgrp changes file group for no dereference option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir tst
    "../$RSUBOX" chgrp "`id -gn`" xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx &&
    assert_existent_file 6 zzz &&
    assert_file_group 7 "`id -gn`" zzz &&
    assert_existent_file 8 tst &&
    assert_file_group 9 "`id -gn`" tst
end_test

start_test chgrp "chgrp changes file group for -H option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir tst
    "../$RSUBOX" chgrp -H "`id -gn`" xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx &&
    assert_existent_file 6 zzz &&
    assert_file_group 7 "`id -gn`" zzz &&
    assert_existent_file 8 tst &&
    assert_file_group 9 "`id -gn`" tst
end_test

start_test chgrp "chgrp changes file group for -L option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir tst
    "../$RSUBOX" chgrp -L "`id -gn`" xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx &&
    assert_existent_file 6 zzz &&
    assert_file_group 7 "`id -gn`" zzz &&
    assert_existent_file 8 tst &&
    assert_file_group 9 "`id -gn`" tst
end_test

start_test chgrp "chgrp changes file group for -P option"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    mkdir tst
    "../$RSUBOX" chgrp -P "`id -gn`" xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx &&
    assert_existent_file 6 zzz &&
    assert_file_group 7 "`id -gn`" zzz &&
    assert_existent_file 8 tst &&
    assert_file_group 9 "`id -gn`" tst
end_test

start_test chgrp "chgrp recursively changes file group"
    mkdir tst
    echo xxx > tst/xxx
    mkdir tst/test
    echo yyy > tst/test/yyy
    echo zzz > tst/test/zzz
    "../$RSUBOX" chgrp -R "`id -gn`" tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_group 5 "`id -gn`" tst &&
    assert_existent_file 5 tst/xxx &&
    assert_file_group 6 "`id -gn`" tst/xxx &&
    assert_existent_file 7 tst/test &&
    assert_file_group 8 "`id -gn`" tst/test &&
    assert_existent_file 9 tst/test/yyy &&
    assert_file_group 10 "`id -gn`" tst/test/yyy &&
    assert_existent_file 11 tst/test/yyy &&
    assert_file_group 12 "`id -gn`" tst/test/yyy
end_test

start_test chgrp "chgrp recursively changes file group for no dereference option"
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
    "../$RSUBOX" chgrp -R "`id -gn`" tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_group 5 "`id -gn`" tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_group 7 "`id -gn`" tst/xxx &&
    assert_existent_file 8 xxx &&
    assert_file_group 9 "`id -gn`" xxx &&
    assert_existent_file 10 tst3 &&
    assert_file_group 11 "`id -gn`" tst3 &&
    assert_existent_file 12 tst3/xxx &&
    assert_file_group 13 "`id -gn`" tst3/xxx &&
    assert_existent_file 14 tst3/yyy &&
    assert_file_group 15 "`id -gn`" tst3/yyy &&
    assert_existent_file 16 tst4 &&
    assert_file_group 17 "`id -gn`" tst4
end_test

start_test chgrp "chgrp recursively changes file group for -H option"
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
    "../$RSUBOX" chgrp -HR "`id -gn`" tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_group 5 "`id -gn`" tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_group 7 "`id -gn`" tst/xxx &&
    assert_existent_file 8 xxx &&
    assert_file_group 9 "`id -gn`" xxx &&
    assert_existent_file 10 tst3 &&
    assert_file_group 11 "`id -gn`" tst3 &&
    assert_existent_file 12 tst3/xxx &&
    assert_file_group 13 "`id -gn`" tst3/xxx &&
    assert_existent_file 14 tst3/yyy &&
    assert_file_group 15 "`id -gn`" tst3/yyy &&
    assert_existent_file 16 tst4 &&
    assert_file_group 17 "`id -gn`" tst4
end_test

start_test chgrp "chgrp recursively changes file group for -L option"
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
    "../$RSUBOX" chgrp -LR "`id -gn`" tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_group 5 "`id -gn`" tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_group 7 "`id -gn`" tst/xxx &&
    assert_existent_file 8 xxx &&
    assert_file_group 9 "`id -gn`" xxx &&
    assert_existent_file 10 tst3 &&
    assert_file_group 11 "`id -gn`" tst3 &&
    assert_existent_file 12 tst3/xxx &&
    assert_file_group 13 "`id -gn`" tst3/xxx &&
    assert_existent_file 14 tst3/yyy &&
    assert_file_group 15 "`id -gn`" tst3/yyy &&
    assert_existent_file 16 tst4 &&
    assert_file_group 17 "`id -gn`" tst4 &&
    assert_existent_file 18 tst4/xxx &&
    assert_file_group 19 "`id -gn`" tst4/xxx &&
    assert_existent_file 20 tst4/yyy &&
    assert_file_group 21 "`id -gn`" tst4/yyy
end_test

start_test chgrp "chgrp recursively changes file group for -P option"
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
    "../$RSUBOX" chgrp -PR "`id -gn`" tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_group 5 "`id -gn`" tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_group 7 "`id -gn`" tst/xxx &&
    assert_existent_file 8 xxx &&
    assert_file_group 9 "`id -gn`" xxx &&
    assert_existent_file 10 tst3 &&
    assert_file_group 11 "`id -gn`" tst3 &&
    assert_existent_file 12 tst3/xxx &&
    assert_file_group 13 "`id -gn`" tst3/xxx &&
    assert_existent_file 14 tst3/yyy &&
    assert_file_group 15 "`id -gn`" tst3/yyy &&
    assert_existent_file 16 tst4 &&
    assert_file_group 17 "`id -gn`" tst4
end_test

start_test chgrp "chgrp changes symbolic link group"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    "../$RSUBOX" chgrp -h "`id -gn`" xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx &&
    assert_existent_file 6 yyy &&
    assert_file_group 7 "`id -gn`" yyy
end_test

start_test chgrp "chgrp changes symbolic link group for symbolic link with non-existent target"
    echo xxx > xxx
    ln -s zzz yyy
    "../$RSUBOX" chgrp -h "`id -gn`" xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_group 5 "`id -gn`" xxx &&
    assert_file_group 6 "`id -gn`" yyy
end_test

start_test chgrp "chgrp complains on too few arguments"
    "../$RSUBOX" chgrp "`id -un`" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test chgrp "chgrp complains on too few arguments for no group"
    "../$RSUBOX" chgrp > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test
