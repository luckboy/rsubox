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
start_test mkdir "mkdir makes directory"
    "../$RSUBOX" mkdir xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx
end_test

start_test mkdir "mkdir makes two directories"
    "../$RSUBOX" mkdir xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx &&
    assert_existent_file 4 yyy &&
    assert_file_mode 5 '^d' yyy
end_test

start_test mkdir "mkdir makes directory with permissions"
    "../$RSUBOX" mkdir -m 755 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^drwxr-xr-x' xxx
end_test

start_test mkdir "mkdir makes directory with permissions as symbolic mode"
    saved_mask="`umask`"
    umask 2
    "../$RSUBOX" mkdir -m g-w xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt
    status="$?"
    umask "$saved_mask"

    assert 1 [ 0 = "$status" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^drwxr-xr-x' xxx
end_test

start_test mkdir "mkdir makes directory with parents"
    "../$RSUBOX" mkdir -p xxx/yyy/zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^drwx' xxx &&
    assert_existent_file 6 xxx/yyy &&
    assert_file_mode 7 '^drwx' xxx/yyy &&
    assert_existent_file 8 xxx/yyy/zzz &&
    assert_file_mode 9 '^d' xxx/yyy/zzz
end_test

start_test mkdir "mkdir makes directory with parents for existent parents"
    mkdir xxx
    mkdir xxx/yyy
    "../$RSUBOX" mkdir -p xxx/yyy/zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx &&
    assert_existent_file 6 xxx/yyy &&
    assert_file_mode 7 '^d' xxx/yyy &&
    assert_existent_file 8 xxx/yyy/zzz &&
    assert_file_mode 9 '^d' xxx/yyy/zzz
end_test

start_test mkdir "mkdir doesn't make directory with parents for existent parents and existent direcoty"
    mkdir xxx
    mkdir xxx/yyy
    mkdir xxx/yyy/zzz
    "../$RSUBOX" mkdir -p xxx/yyy/zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx &&
    assert_existent_file 6 xxx/yyy &&
    assert_file_mode 7 '^d' xxx/yyy &&
    assert_existent_file 8 xxx/yyy/zzz &&
    assert_file_mode 9 '^d' xxx/yyy/zzz
end_test

start_test mkdir "mkdir sets permissions for parents"
    "../$RSUBOX" mkdir -pm 755 xxx/yyy/zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx &&
    assert_existent_file 6 xxx/yyy &&
    assert_file_mode 7 '^d' xxx/yyy &&
    assert_existent_file 8 xxx/yyy/zzz &&
    assert_file_mode 9 '^drwxr-xr-x' xxx/yyy/zzz
end_test

start_test mkdir "mkdir doesn't set permissions for parents and existent directory"
    mkdir xxx
    mkdir xxx/yyy
    mkdir -m 775 xxx/yyy/zzz
    "../$RSUBOX" mkdir -pm 755 xxx/yyy/zzz > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx &&
    assert_existent_file 6 xxx/yyy &&
    assert_file_mode 7 '^d' xxx/yyy &&
    assert_existent_file 8 xxx/yyy/zzz &&
    assert_file_mode 9 '^drwxrwxr-x' xxx/yyy/zzz
end_test

start_test mkdir "mkdir complains on too few arguments"
    "../$RSUBOX" mkdir > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test mkdir "mkdir complains on existent directory"
    mkdir xxx
    "../$RSUBOX" mkdir xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern  3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^d' xxx    
end_test

start_test mkdir "mkdir complains on non-existent directory"
    "../$RSUBOX" mkdir xxx/yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern  3 '^xxx/yyy: ' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test
