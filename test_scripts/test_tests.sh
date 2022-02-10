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
start_test test "test tests some condition"
    "../$RSUBOX" test 2 -eq 2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests some condition for bracket"
    "../$RSUBOX" [ 2 -eq 2 ] > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests no condition"
    "../$RSUBOX" test > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests no condition for bracket"
    "../$RSUBOX" [ ] > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical-OR operator"
    "../$RSUBOX" test abc -o abc > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical-OR operator for one false"
    "../$RSUBOX" test abc -o '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical-OR operator for two falses"
    "../$RSUBOX" test '' -o '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical-OR operators"
    "../$RSUBOX" test abc -o abc -o '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical-AND operator"
    "../$RSUBOX" test abc -a abc > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical-AND operator for one false"
    "../$RSUBOX" test abc -a '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical-AND operator for two falses"
    "../$RSUBOX" test '' -a '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical-AND operators"
    "../$RSUBOX" test abc -a abc -a '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical operators"
    "../$RSUBOX" test '' -a abc -o abc > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical operators and parentheses"
    "../$RSUBOX" test '' -a \( abc -o abc \) > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical negation operator for true"
    "../$RSUBOX" test ! abc > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical negation operator for false"
    "../$RSUBOX" test ! '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests expression with logical negation operators"
    "../$RSUBOX" test ! ! '' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests block device condition for block device"
    "../$RSUBOX" test -b "$TEST_BLOCK_DEVICE" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests block device condition for other file"
    echo xxx > xxx
    "../$RSUBOX" test -b xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests block device condition for non-existent file"
    "../$RSUBOX" test -b xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests character device condition for character device"
    "../$RSUBOX" test -c "$TEST_CHAR_DEVICE" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests character device condition for other file"
    echo xxx > xxx
    "../$RSUBOX" test -c xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests character device condition for non-existent file"
    "../$RSUBOX" test -c xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests directory condition for directory"
    mkdir xxx
    "../$RSUBOX" test -d xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests directory condition for other file"
    echo xxx > xxx
    "../$RSUBOX" test -d xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests directory condition for non-existent file"
    "../$RSUBOX" test -d xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests existent condition for existent file"
    echo xxx > xxx
    "../$RSUBOX" test -e xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests existent condition for non-existent file"
    "../$RSUBOX" test -e xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests regular file condition for regular file"
    echo xxx > xxx
    "../$RSUBOX" test -f xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests regular file condition for other file"
    "../$RSUBOX" test -f "$TEST_BLOCK_DEVICE" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests regular file condition for non-existent file"
    "../$RSUBOX" test -f xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests set-group-ID condition for file with set-group-ID flag"
    echo xxx > xxx
    chmod 2655 xxx
    "../$RSUBOX" test -g xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests set-group-ID condition for file without set-group-ID flag"
    echo xxx > xxx
    "../$RSUBOX" test -g xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests set-group-ID condition for non-existent file"
    "../$RSUBOX" test -g xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests symbolic link condition for symbolic link and -h operator"
    echo xxx > xxx
    ln -s xxx yyy
    "../$RSUBOX" test -h yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests symbolic link condition for symbolic link with non-existent target and -h operator"
    ln -s xxx yyy
    "../$RSUBOX" test -h yyy  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests symbolic link condition for other file and -h operator"
    echo xxx > xxx
    "../$RSUBOX" test -h xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests symbolic link condition for non-existent file and -h operator"
    "../$RSUBOX" test -h xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests symbolic link condition for symbolic link and -L operator"
    echo xxx > xxx
    ln -s xxx yyy
    "../$RSUBOX" test -L yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests symbolic link condition for symbolic link with non-existent target and -L operator"
    ln -s xxx yyy
    "../$RSUBOX" test -L yyy  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests symbolic link condition for other file and -L operator"
    echo xxx > xxx
    "../$RSUBOX" test -L xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests symbolic link condition for non-existent file and -L operator"
    "../$RSUBOX" test -L xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests non-zero string length condition for string with non-zero length"
    "../$RSUBOX" test -n xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests non-zero string length condition for string with zero length"
    "../$RSUBOX" test -n ''  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests fifo condition for fifo"
    mkfifo xxx
    "../$RSUBOX" test -p xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests fifo condition for other file"
    echo xxx > xxx
    "../$RSUBOX" test -p xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests fifo condition for non-existent file"
    "../$RSUBOX" test -p xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests readable file condition for readable file"
    echo xxx > xxx
    chmod 444 xxx
    "../$RSUBOX" test -r xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests readable file condition for non-readable file"
    echo xxx > xxx
    chmod 222 xxx
    "../$RSUBOX" test -r xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests readable file condition for non-existent file"
    "../$RSUBOX" test -r xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests socket condition for other file"
    echo xxx > xxx
    "../$RSUBOX" test -S xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests socket condition for non-existent file"
    "../$RSUBOX" test -S xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests size greater than zero condition for file with size that is greater than zero"
    echo xxx > xxx
    "../$RSUBOX" test -s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests size greater than zero condition for file with size that is zero"
    echo -n > xxx
    "../$RSUBOX" test -s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests size greater than zero condition for non-existent file"
    "../$RSUBOX" test -s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests terminal file descriptor condition for file descriptor that is terminal"
    "../$RSUBOX" test -t 0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests terminal file descriptor condition for file descriptor that isn't terminal"
    "../$RSUBOX" test -t 3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests set-user-ID condition for file with set-user-ID flag"
    echo xxx > xxx
    chmod 4655 xxx
    "../$RSUBOX" test -u xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests set-user-ID condition for file without set-user-ID flag"
    echo xxx > xxx
    "../$RSUBOX" test -u xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests set-user-ID condition for non-existent file"
    "../$RSUBOX" test -u xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests writable file condition for writable file"
    echo xxx > xxx
    chmod 222 xxx
    "../$RSUBOX" test -w xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests writable file condition for non-writable file"
    echo xxx > xxx
    chmod 444 xxx
    "../$RSUBOX" test -w xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests writable file condition for non-existent file"
    "../$RSUBOX" test -w xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests executable file condition for executable file"
    echo xxx > xxx
    chmod 111 xxx
    "../$RSUBOX" test -x xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests executable file condition for non-executable file"
    echo xxx > xxx
    chmod 444 xxx
    "../$RSUBOX" test -x xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests executable file condition for non-existent file"
    "../$RSUBOX" test -x xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests zero string length condition for string with zero length"
    "../$RSUBOX" test -z ''  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests zero string length condition for string with non-zero length"
    "../$RSUBOX" test -z xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests non-empty string condition for non-empty string"
    "../$RSUBOX" test xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests non-empty string condition for empty string"
    "../$RSUBOX" test ''  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests string equation condition for strings which are equal"
    "../$RSUBOX" test xxx = xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests string equation condition for strings which are unequal"
    "../$RSUBOX" test xxx = yyy  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests string inequation condition for strings which are unequal"
    "../$RSUBOX" test xxx != yyy  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests string inequation condition for strings which are equal"
    "../$RSUBOX" test xxx != xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests number equation condition for numbers which are equal"
    "../$RSUBOX" test 2 -eq 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests number equation condition for numbers which are unequal"
    "../$RSUBOX" test 1 -eq 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests number inequation condition for numbers which are unequal"
    "../$RSUBOX" test 1 -ne 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests number inequation condition for numbers which are equal"
    "../$RSUBOX" test 2 -ne 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests less number condition for first number that is less than second number"
    "../$RSUBOX" test 1 -lt 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests less number condition for numbers which are equal"
    "../$RSUBOX" test 2 -lt 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests greater or equal number condition for first numbers which are equal"
    "../$RSUBOX" test 2 -ge 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests greater or equal number condition for first number that is less than second number"
    "../$RSUBOX" test 1 -ge 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests greater number condition for first number that is greater than second number"
    "../$RSUBOX" test 2 -gt 1  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests greater number condition for numbers which are equal"
    "../$RSUBOX" test 2 -gt 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests less or equal number condition for first numbers which are equal"
    "../$RSUBOX" test 2 -le 2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests less or equal number condition for first number that is greater than second number"
    "../$RSUBOX" test 2 -le 1  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test tests condition with negative numbers"
    "../$RSUBOX" test -1 -gt -2  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test test "test complains on uknown binary operator"
    "../$RSUBOX" test 1 -xx 1 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Syntax error' ../test_tmp/stderr.txt
end_test

start_test test "test complains on unclosed parentheses"
    "../$RSUBOX" test \( xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Unclosed parentheses' ../test_tmp/stderr.txt
end_test

start_test test "test complains on unclosed bracket"
    "../$RSUBOX" [ xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Unclosed bracket' ../test_tmp/stderr.txt
end_test

start_test test "test complains on bracket and some string"
    "../$RSUBOX" [ xxx ] xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Syntax error' ../test_tmp/stderr.txt
end_test

start_test test "test complains on bracket and some string for no condition"
    "../$RSUBOX" [ ] xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Syntax error' ../test_tmp/stderr.txt
end_test

start_test test "test complains on no argument"
    "../$RSUBOX" test xxx = > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'No argument' ../test_tmp/stderr.txt
end_test

start_test test "test complains on non-integer argument"
    "../$RSUBOX" test xxx -eq xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test test "test complains on overflow"
    "../$RSUBOX" test 1 -eq 9223372036854775808 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^number too large' ../test_tmp/stderr.txt
end_test
