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
start_test rmdir "rmdir removes directory"
    mkdir xxx
    "../$RSUBOX" rmdir xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rmdir "rmdir removes two directories"
    mkdir xxx yyy
    "../$RSUBOX" rmdir xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx &&
    assert_non_existent_file 5 yyy
end_test

start_test rmdir "rmdir doesn't remove parents"
    mkdir xxx
    mkdir xxx/yyy
    mkdir xxx/yyy/zzz
    "../$RSUBOX" rmdir xxx/yyy/zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx &&
    assert_existent_file 6 xxx/yyy &&
    assert_file_mode 7 '^d' xxx/yyy &&
    assert_non_existent_file 8 xxx/yyy/zzz
end_test

start_test rmdir "rmdir removes direcotory with parents"
    mkdir xxx
    mkdir xxx/yyy
    mkdir xxx/yyy/zzz
    "../$RSUBOX" rmdir -p xxx/yyy/zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rmdir "rmdir complains on too few arguments"
    "../$RSUBOX" rmdir > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test rmdir "rmdir complains on non-existent directory"
    "../$RSUBOX" rmdir xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern  3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test rmdir "rmdir complains on non-empty directory"
    mkdir xxx
    echo yyy > xxx/yyy
    "../$RSUBOX" rmdir xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern  3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx &&
    assert_existent_file 6 xxx/yyy &&
    assert_file_mode 7 '^-' xxx/yyy
end_test
