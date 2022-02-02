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
start_test rm "rm removes file"
    echo xxx > xxx
    echo -n | "../$RSUBOX" rm xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rm "rm removes two files"
    echo xxx > xxx
    echo yyy > yyy
    echo -n | "../$RSUBOX" rm xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_non_existent_file 4 yyy
end_test

start_test rm "rm doesn't follow links during removing"
    ln -s zzz xxx
    echo yyy > yyy
    echo zzz > zzz
    echo -n | "../$RSUBOX" rm xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_non_existent_file 5 yyy &&
    assert_existent_file 6 zzz
end_test

start_test rm "rm recursively removes directory for -R option"
    mkdir tst
    echo xxx > tst/xxx
    mkdir tst/test
    echo yyy > tst/test/yyy
    echo zzz > tst/test/zzz
    echo -n | "../$RSUBOX" rm -R tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 tst
end_test

start_test rm "rm recursively removes directory for -r option"
    mkdir tst
    echo xxx > tst/xxx
    mkdir tst/test
    echo yyy > tst/test/yyy
    echo zzz > tst/test/zzz
    echo -n | "../$RSUBOX" rm -r tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 tst
end_test

start_test rm "rm doesn't follow link during recursive removing"
    mkdir tst
    echo xxx > tst/xxx
    mkdir tst/test
    echo yyy > tst/test/yyy
    echo zzz > tst/test/zzz
    ln -s xxx tst2
    echo xxx > xxx
    mkdir tst3
    echo xxx > tst3/xxx
    ln -s ../yyy tst3/yyy
    echo yyy > yyy
    echo -n | "../$RSUBOX" rm -R tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 tst &&
    assert_non_existent_file 5 tst2 &&
    assert_existent_file 6 xxx &&
    assert_non_existent_file 7 tst3 &&
    assert_existent_file 8 yyy
end_test

start_test rm "rm removes file for force option"
    echo xxx > xxx
    "../$RSUBOX" rm -f xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rm "rm recursively removes directory for force option"
    mkdir tst
    echo xxx > tst/xxx
    mkdir tst/test
    echo yyy > tst/test/yyy
    echo zzz > tst/test/zzz
    "../$RSUBOX" rm -fR tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 test
end_test

start_test rm "rm doesn't complain non-existent file for force option"
    "../$RSUBOX" rm -f xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test rm "rm doesn't complain non-existent file for force option and recursive option"
    "../$RSUBOX" rm -fR xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test rm "rm doesn't complain too few arguments for force option"
    "../$RSUBOX" rm -f > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test rm "rm removes file for tty stdin"
    echo xxx > xxx
    echo -n | "../$RSUBOX" rm -T xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rm "rm asks for remove file and removes file for tty stdin and read only file"
    echo xxx > xxx
    chmod 444 xxx
    echo -n "remove xxx? " > ../test_tmp/expected.txt
    echo y | "../$RSUBOX" rm -T xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rm "rm asks for remove file and doesn't remove file for tty stdin and read only file"
    echo xxx > xxx
    chmod 444 xxx
    echo -n "remove xxx? " > ../test_tmp/expected.txt
    echo n | "../$RSUBOX" rm -T xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx
end_test

start_test rm "rm asks for descend into directory and descends into directory for tty stdin and read only directory"
    mkdir tst
    chmod 555 tst
    echo -n "descend into tst? " > ../test_tmp/expected.txt
    echo y | "../$RSUBOX" rm -RT tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 tst
end_test

start_test rm "rm asks for descend into directory and doesn't descend into directory for tty stdin and read only directory"
    mkdir tst
    chmod 555 tst
    echo -n "descend into tst? " > ../test_tmp/expected.txt
    echo n | "../$RSUBOX" rm -RT tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst
end_test

start_test rm "rm asks for descend into directory and doesn't descend into directory and doesn't remove two files for tty stdin and read only directory"
    mkdir tst
    echo xxx > tst/xxx
    echo yyy > tst/yyy
    chmod 555 tst
    echo -n "descend into tst? " > ../test_tmp/expected.txt
    echo n | "../$RSUBOX" rm -RT tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_existent_file 5 tst/xxx &&
    assert_existent_file 6 tst/yyy
    chmod 755 tst
end_test

start_test rm "rm doesn't ask for remove file and removes file for force option, tty stdin and read only file"
    echo xxx > xxx
    chmod 444 xxx
    echo n | "../$RSUBOX" rm -fT xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rm "rm doesn't ask for descend into directory and descends into directory for force option, tty stdin and read only directory"
    mkdir tst
    chmod 555 tst
    echo -n | "../$RSUBOX" rm -fRT tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 tst
end_test

start_test rm "rm asks for remove file and removes file for interactive option"
    echo xxx > xxx
    echo -n "remove xxx? " > ../test_tmp/expected.txt
    echo y | "../$RSUBOX" rm -i xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rm "rm asks for remove file and doesn't remove file for interactive option"
    echo xxx > xxx
    echo -n "remove xxx? " > ../test_tmp/expected.txt
    echo n | "../$RSUBOX" rm -i xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx
end_test

start_test rm "rm asks for descend into directory and remove directory and descends into directory and removes directory for interactive option"
    mkdir tst
    echo -n "descend into tst? remove tst? " > ../test_tmp/expected.txt
    (echo y; echo y) | "../$RSUBOX" rm -iR tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 tst
end_test

start_test rm "rm asks for descend into directory and remove directory and descends into directory and doesn't remove directory for interactive option"
    mkdir tst
    echo -n "descend into tst? remove tst? " > ../test_tmp/expected.txt
    (echo y; echo n) | "../$RSUBOX" rm -iR tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst
end_test

start_test rm "rm asks for descend into directory, remove two files and remove directory and descends into directory, removes two files and removes directory for interactive option"
    mkdir tst
    echo xxx > tst/xxx
    echo yyy > tst/yyy
    echo -n "descend into tst? remove tst/xxx? remove tst/yyy? remove tst? " > ../test_tmp/expected.txt
    (echo y; echo y; echo y; echo y) | "../$RSUBOX" rm -iR tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 tst
end_test

start_test rm "rm asks for descend into directory, remove two files and remove directory and descends into directory, doesn't remove two files and doesn't remove directory for interactive option"
    mkdir tst
    echo xxx > tst/xxx
    echo yyy > tst/yyy
    echo -n "descend into tst? remove tst/xxx? remove tst/yyy? remove tst? " > ../test_tmp/expected.txt
    (echo y; echo n; echo n; echo n) | "../$RSUBOX" rm -iR tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_existent_file 5 tst/xxx &&
    assert_existent_file 6 tst/yyy
end_test

start_test rm "rm asks for descend into directory and remove directory and doesn't descend into directory for interactive option"
    mkdir tst
    echo -n "descend into tst? " > ../test_tmp/expected.txt
    echo n | "../$RSUBOX" rm -iR tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_compare_files 3 ../test_tmp/expected.txt ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst
end_test

start_test rm "rm complains on too few arguments"
    echo -n | "../$RSUBOX" rm > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test rm "rm complains on file that is directory"
    mkdir tst
    echo xxx > xxx
    echo -n | "../$RSUBOX" rm tst xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'tst is a directory' ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_non_existent_file 5 xxx
end_test

start_test rm "rm complains on non-existent file"
    echo yyy > yyy
    echo -n | "../$RSUBOX" rm xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 yyy
end_test

start_test rm "rm complains on non-existent file for recursive option"
    echo yyy > yyy
    echo -n | "../$RSUBOX" rm -R xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 yyy
end_test

start_test rm "rm complains on . directory"
    echo xxx > xxx
    echo -n | "../$RSUBOX" rm . xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Can'"'"'t remove . or ..' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rm "rm complains on .. directory"
    mkdir tst
    echo xxx > xxx
    echo -n | "../$RSUBOX" rm tst/.. xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Can'"'"'t remove . or ..' ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_non_existent_file 5 xxx
end_test
