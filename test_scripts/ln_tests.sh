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
start_test ln "ln creates hard link"
    echo xxx > xxx
    "../$RSUBOX" ln xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_nlink 5 2 xxx &&
    assert_existent_file 6 yyy &&
    assert_file_mode 7 '^-' yyy &&
    assert_file_nlink 8 2 yyy
end_test

start_test ln "ln creates symbolic link"
    echo xxx > xxx
    "../$RSUBOX" ln -s xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^l' yyy &&
    assert_file_link 7 xxx yyy
end_test

start_test ln "ln creates one hard link in directory"
    echo xxx > xxx
    mkdir dst
    "../$RSUBOX" ln xxx dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_nlink 5 2 xxx &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^-' dst/xxx &&
    assert_file_nlink 10 2 dst/xxx
end_test

start_test ln "ln creates one symbolic link in directory"
    echo xxx > xxx
    mkdir dst
    "../$RSUBOX" ln -s ../xxx dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 dst &&
    assert_file_mode 6 '^d' dst &&
    assert_existent_file 7 dst/xxx &&
    assert_file_mode 8 '^l' dst/xxx &&
    assert_file_link 9 ../xxx dst/xxx
end_test

start_test ln "ln creates two hard links in directory"
    echo xxx > xxx
    echo yyy > yyy
    mkdir dst
    "../$RSUBOX" ln xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_nlink 5 2 xxx &&
    assert_existent_file 6 yyy &&
    assert_file_nlink 7 2 yyy &&
    assert_existent_file 8 dst &&
    assert_file_mode 9 '^d' dst &&
    assert_existent_file 10 dst/xxx &&
    assert_file_mode 11 '^-' dst/xxx &&
    assert_file_nlink 12 2 dst/xxx &&
    assert_existent_file 13 dst/yyy &&
    assert_file_mode 14 '^-' dst/yyy &&
    assert_file_nlink 15 2 dst/yyy
end_test

start_test ln "ln creates two symbolic links in directory"
    echo xxx > xxx
    echo yyy > yyy
    mkdir dst
    "../$RSUBOX" ln -s ../xxx ../yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^d' dst &&
    assert_existent_file 8 dst/xxx &&
    assert_file_mode 9 '^l' dst/xxx &&
    assert_file_link 10 ../xxx dst/xxx &&
    assert_existent_file 11 dst/yyy &&
    assert_file_mode 12 '^l' dst/yyy &&
    assert_file_link 13 ../yyy dst/yyy
end_test

start_test ln "ln creates symbolic link to non-existent file"
    "../$RSUBOX" ln -s xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_file_mode 4 '^l' yyy &&
    assert_file_link 5 xxx yyy
end_test

start_test ln "ln creates symbolic link to directory"
    mkdir src
    "../$RSUBOX" ln -s src dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 src &&
    assert_existent_file 5 dst &&
    assert_file_mode 7 '^l' dst &&
    assert_file_link 6 src dst
end_test

start_test ln "ln creates hard link for force option"
    echo xxx > xxx
    "../$RSUBOX" ln -f xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_nlink 5 2 xxx &&
    assert_existent_file 6 yyy &&
    assert_file_mode 7 '^-' yyy &&
    assert_file_nlink 8 2 yyy
end_test

start_test ln "ln creates symbolic link for force option"
    echo xxx > xxx
    "../$RSUBOX" ln -fs xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^l' yyy &&
    assert_file_link 7 xxx yyy
end_test

start_test ln "ln removes file for force option"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" ln -f xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_nlink 5 2 xxx &&
    assert_existent_file 6 yyy &&
    assert_file_mode 7 '^-' yyy &&
    assert_file_nlink 8 2 yyy
end_test

start_test ln "ln removes file for force option"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" ln -fs xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_file_mode 6 '^l' yyy &&
    assert_file_link 7 xxx yyy
end_test

start_test ln "ln complains on too few arguments for zero arguments"
    "../$RSUBOX" ln > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test ln "ln complains on too few arguments for one argument"
    "../$RSUBOX" ln xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test ln "ln complains on destination that isn't directory for file"
    echo xxx > xxx
    echo yyy > yyy
    echo dst > dst
    "../$RSUBOX" ln xxx yyy dst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'dst isn'"'"'t a directory' ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 5 yyy &&
    assert_existent_file 6 dst &&
    assert_file_mode 7 '^-' dst &&
    assert_file_content 8 dst dst
end_test

start_test ln "ln complains on non-existent file"
    "../$RSUBOX" ln xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_non_existent_file 6 yyy
end_test

start_test ln "ln complains on existent file for hard link"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" ln xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^yyy: ' ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_nlink 5 1 xxx &&
    assert_existent_file 6 yyy &&
    assert_file_mode 7 '^-' yyy &&
    assert_file_nlink 8 1 yyy
end_test

start_test ln "ln complains on existent file for symbolic link"
    echo xxx > xxx
    echo yyy > yyy
    "../$RSUBOX" ln -s xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^yyy: ' ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_existent_file 6 yyy &&
    assert_file_mode 7 '^-' yyy
end_test
