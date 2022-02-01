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
start_test mv "mv renames file"
    echo xxx > xxx
    echo -n | "../$RSUBOX" mv xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv renames one file to directory"
    echo xxx > xxx
    mkdir dst
    echo -n | "../$RSUBOX" mv xxx dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 dst &&
    assert_file_mode 6 '^d' dst &&
    assert_existent_file 7 dst/xxx &&
    assert_file_mode 8 '^-' dst/xxx &&
    assert_file_content 9 xxx dst/xxx
end_test

start_test mv "mv renames two files to directory"
    echo xxx > xxx
    echo yyy > yyy
    mkdir dst
    echo -n | "../$RSUBOX" mv xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_non_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^-' dst/xxx &&
    assert_file_content 10 xxx dst/xxx &&
    assert_existent_file 11 dst/yyy &&
    assert_file_mode 12 '^-' dst/yyy &&
    assert_file_content 13 yyy dst/yyy
end_test

start_test mv "mv renames directory"
    mkdir src
    echo xxx > src/xxx
    echo yyy > src/yyy
    echo -n | "../$RSUBOX" mv src dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 src &&
    assert_existent_file 5 dst &&
    assert_file_mode 6 '^d' dst &&
    assert_existent_file 7 dst/xxx &&
    assert_file_mode 8 '^-' dst/xxx &&
    assert_file_content 9 xxx dst/xxx &&
    assert_existent_file 10 dst/yyy &&
    assert_file_mode 11 '^-' dst/yyy &&
    assert_file_content 12 yyy dst/yyy
end_test

start_test mv "mv overwrites file"
    echo xxx > xxx
    echo yyy > yyy
    echo -n | "../$RSUBOX" mv xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv renames file for force option"
    echo xxx > xxx
    "../$RSUBOX" mv -f xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv overwrites file for force option"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" mv -f xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv renames file for tty stdin"
    echo xxx > xxx
    echo -n | "../$RSUBOX" mv -T xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv overwrites file for tty stdin"
    echo xxx > xxx
    echo yyy > yyy
    echo -n | "../$RSUBOX" mv -T xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv asks for overwrite file and overwrites file for tty stdin and read only file"
    echo xxx > xxx
    echo yyy > yyy
    chmod 444 yyy
    echo -n "overwrite yyy? " > ../test_tmp/expected.txt
    echo y | "../$RSUBOX" mv -T xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv asks for overwrite file and doesn't overwrite file for tty stdin and read only file"
    echo xxx > xxx
    echo yyy > yyy
    chmod 444 yyy
    echo -n "overwrite yyy? " > ../test_tmp/expected.txt
    echo n | "../$RSUBOX" mv -T xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 yyy yyy
end_test

start_test mv "mv doesn't ask for overwrite file and overwrites file for force option, tty stdin and read only file"
    echo xxx > xxx
    echo yyy > yyy
    chmod 444 yyy
    echo y | "../$RSUBOX" mv -fT xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv asks for overwrite file and overwrites file for interactive option"
    echo xxx > xxx
    echo yyy > yyy
    echo -n "overwrite yyy? " > ../test_tmp/expected.txt
    echo y | "../$RSUBOX" mv -i xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv asks for overwrite file and doesn't overwrite file for interactive option"
    echo xxx > xxx
    echo yyy > yyy
    echo -n "overwrite yyy? " > ../test_tmp/expected.txt
    echo n | "../$RSUBOX" mv -i xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 yyy yyy
end_test

start_test mv "mv moves file"
    echo xxx > xxx
    echo -n | "../$RSUBOX" mv -N xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy
end_test

start_test mv "mv moves one file to directory"
    echo xxx > xxx
    mkdir dst
    echo -n | "../$RSUBOX" mv -N xxx dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 dst &&
    assert_file_mode 6 '^d' dst &&
    assert_existent_file 7 dst/xxx &&
    assert_file_mode 8 '^-' dst/xxx &&
    assert_file_content 9 xxx dst/xxx
end_test

start_test mv "mv moves two files to directory"
    echo xxx > xxx
    echo yyy > yyy
    mkdir dst
    echo -n | "../$RSUBOX" mv -N xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_non_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^-' dst/xxx &&
    assert_file_content 10 xxx dst/xxx &&
    assert_existent_file 11 dst/yyy &&
    assert_file_mode 12 '^-' dst/yyy &&
    assert_file_content 13 yyy dst/yyy
end_test

start_test mv "mv moves directory"
    mkdir src
    echo xxx > src/xxx
    echo yyy > src/yyy
    echo -n | "../$RSUBOX" mv -N src dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 src &&
    assert_existent_file 5 dst &&
    assert_file_mode 6 '^d' dst &&
    assert_existent_file 7 dst/xxx &&
    assert_file_mode 8 '^-' dst/xxx &&
    assert_file_content 9 xxx dst/xxx &&
    assert_existent_file 10 dst/yyy &&
    assert_file_mode 11 '^-' dst/yyy &&
    assert_file_content 12 yyy dst/yyy
end_test

start_test mv "mv doesn't follow links during moving"
    mkdir src
    echo xxx > src/xxx
    ln -s zzz src/yyy
    echo zzz > src/zzz
    echo src2 > src2
    mkdir src3
    echo xxx > src3/xxx
    echo yyy > src3/yyy
    mkdir dst
    echo -n | "../$RSUBOX" mv -N src src2 src3 dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 src &&
    assert_non_existent_file 5 src2 &&
    assert_non_existent_file 6 src3 &&
    assert_existent_file 7 dst &&
    assert_file_mode 8 '^d' dst &&
    assert_existent_file 9 dst/src &&
    assert_file_mode 10 '^d' dst/src &&
    assert_existent_file 11 dst/src/xxx &&
    assert_file_mode 12 '^-' dst/src/xxx &&
    assert_file_content 13 xxx dst/src/xxx &&
    assert_existent_file 14 dst/src/yyy &&
    assert_file_mode 15 '^l' dst/src/yyy &&
    assert_file_link 16 zzz dst/src/yyy &&
    assert_existent_file 17 dst/src/zzz &&
    assert_file_mode 18 '^-' dst/src/zzz &&
    assert_file_content 19 zzz dst/src/zzz &&
    assert_existent_file 20 dst/src2 &&
    assert_file_mode 21 '^-' dst/src2 &&
    assert_file_content 22 src2 dst/src2 &&
    assert_existent_file 23 dst/src3 &&
    assert_file_mode 24 '^d' dst/src3 &&
    assert_existent_file 25 dst/src3/xxx &&
    assert_file_mode 26 '^-' dst/src3/xxx &&
    assert_file_content 27 xxx dst/src3/xxx &&
    assert_existent_file 28 dst/src3/yyy &&
    assert_file_mode 29 '^-' dst/src3/yyy &&
    assert_file_content 30 yyy dst/src3/yyy
end_test

start_test mv "mv preserves file status"
    echo xxx > xxx
    chmod 6644 xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo -n | "../$RSUBOX" mv -N xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-rwSr-Sr--' yyy &&
    assert_file_owner 7 "`id -un`" yyy &&
    assert_file_group 8 "`id -gn`" yyy &&
    assert_file_atime 9 2001 yyy &&
    assert_file_mtime 10 2002 yyy &&
    assert_file_content 11 xxx yyy
end_test

start_test mv "mv preserves directory status"
    mkdir tst
    chmod 1755 tst
    touch -at 200101010000.00 tst
    touch -mt 200201010000.00 tst
    echo -n | "../$RSUBOX" mv -N tst dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 tst &&
    assert_existent_file 5 dst &&
    assert_file_mode 6 '^drwxr-xr-t' dst &&
    assert_file_owner 7 "`id -un`" dst &&
    assert_file_group 8 "`id -gn`" dst &&
    assert_file_atime 9 2001 dst &&
    assert_file_mtime 10 2002 dst
end_test

start_test mv "mv overwrites symbolic link and doesn't overwrite target of symbolic link"
    echo xxx > xxx
    ln -s passwd yyy
    echo passwd > passwd
    echo -n | "../$RSUBOX" mv -N xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^-' yyy &&
    assert_file_content 7 xxx yyy &&
    assert_existent_file 8 passwd &&
    assert_file_mode 9 '^-' passwd &&
    assert_file_content 9 passwd passwd
end_test

start_test mv "mv complains on too few arguments for zero arguments"
    echo -n | "../$RSUBOX" mv > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test mv "mv complains on too few arguments for one argument"
    echo -n | "../$RSUBOX" mv xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test mv "mv complains on destination that isn't directory for file"
    echo xxx > xxx
    echo yyy > yyy
    echo dst > dst
    echo -n | "../$RSUBOX" mv xxx yyy dst> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'dst isn'"'"'t a directory' ../test_tmp/stderr.txt
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^-' dst &&
    assert_file_content 8 dst dst
end_test

start_test mv "mv complains on source that is non-existent file"
    echo yyy > yyy
    mkdir dst
    echo -n | "../$RSUBOX" mv xxx yyy dst> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_non_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_non_existent_file 8 dst/xxx &&
    assert_existent_file 9 dst/yyy &&
    assert_file_mode 10 '^-' dst/yyy &&
    assert_file_content 11 yyy dst/yyy
end_test
