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
start_test chmod "chmod changes file permissions for one file"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod 644 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx
end_test

start_test chmod "chmod changes file permissions for two files"
    echo xxx > xxx
    echo yyy > yyy
    chmod 664 xxx yyy
    "../$RSUBOX" chmod 644 xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx &&
    assert_existent_file 6 yyy &&
    assert_file_mode 7 '^-rw-r--r--' yyy
end_test

start_test chmod "chmod changes file permissions"
    echo xxx > xxx
    ln -s zzz yyy
    echo zzz > zzz
    chmod 664 xxx yyy
    mkdir -m 775 tst
    "../$RSUBOX" chmod g-w xxx yyy tst > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx &&
    assert_existent_file 6 zzz &&
    assert_file_mode 7 '^-rw-r--r--' zzz &&
    assert_existent_file 8 tst &&
    assert_file_mode 9 '^drwxr-xr-x' tst
end_test

start_test chmod "chmod recursively changes file permissions"
    mkdir -m 775 tst
    echo xxx > tst/xxx
    chmod 664 tst/xxx
    mkdir -m 775 tst/test
    echo yyy > tst/test/yyy
    echo zzz > tst/test/zzz
    chmod 664 tst/test/yyy tst/test/zzz
    ln -s xxx tst2
    echo xxx > xxx
    mkdir -m 775 tst3
    echo xxx > tst3/xxx
    ln -s ../yyy tst3/yyy
    echo yyy > yyy
    chmod 664 tst3/xxx yyy
    "../$RSUBOX" chmod -R g-w tst tst2 tst3 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 tst &&
    assert_file_mode 5 '^drwxr-xr-x' tst &&
    assert_existent_file 6 tst/xxx &&
    assert_file_mode 7 '^-rw-r--r--' tst/xxx &&
    assert_existent_file 8 tst/test &&
    assert_file_mode 9 '^drwxr-xr-x' tst/test &&
    assert_existent_file 10 tst/test/yyy &&
    assert_file_mode 11 '^-rw-r--r--' tst/test/yyy &&
    assert_existent_file 12 tst/test/zzz &&
    assert_file_mode 13 '^-rw-r--r--' tst/test/zzz &&
    assert_existent_file 14 xxx &&
    assert_file_mode 15 '^-rw-r--r--' xxx &&
    assert_existent_file 16 tst3 &&
    assert_file_mode 17 '^drwxr-xr-x' tst3 &&
    assert_existent_file 18 tst3/xxx &&
    assert_file_mode 19 '^-rw-r--r--' tst3/xxx &&
    assert_existent_file 20 yyy &&
    assert_file_mode 21 '^-rw-rw-r--' yyy
end_test

start_test chmod "chmod changes file permissions for numeric mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod 644 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx
end_test

start_test chmod "chmod adds reading permissions for symbolic mode"
    echo xxx > xxx
    chmod 600 xxx
    "../$RSUBOX" chmod go+r xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx
end_test

start_test chmod "chmod adds reading and writing permissions for symbolic mode"
    echo xxx > xxx
    chmod 444 xxx
    "../$RSUBOX" chmod ug+rw xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r--' xxx
end_test

start_test chmod "chmod adds executing permissions for symbolic mode"
    echo xxx > xxx
    chmod 644 xxx
    "../$RSUBOX" chmod ug+x xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwxr-xr--' xxx
end_test

start_test chmod "chmod adds searching permissions for directory and symbolic mode"
    mkdir -m 644 xxx
    "../$RSUBOX" chmod a+X xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^drwxr-xr-x' xxx
end_test

start_test chmod "chmod doesn't add searching permissions for file and symbolic mode"
    echo xxx > xxx
    chmod 644 xxx
    "../$RSUBOX" chmod a+X xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx
end_test

start_test chmod "chmod adds searching permissions for executable file and symbolic mode"
    echo xxx > xxx
    chmod 645 xxx
    "../$RSUBOX" chmod ug+X xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwxr-xr-x' xxx
end_test

start_test chmod "chmod adds set-user/group-ID permissions for symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod ug+s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwSrwSr--' xxx
end_test

start_test chmod "chmod doesn't add set-user/group-ID permission for other permissions and symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod o+s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r--' xxx
end_test

start_test chmod "chmod adds sticky bit permission for symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod o+t xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r-T' xxx
end_test

start_test chmod "chmod doesn't add sticky bit permission for user and group permissions and symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod ug+t xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r--' xxx
end_test

start_test chmod "chmod adds reading and writing permissions for no who and symbolic mode"
    echo xxx > xxx
    chmod 644 xxx
    saved_mask="`umask`"
    umask 2
    "../$RSUBOX" chmod +rw xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt
    status="$?"
    umask "$saved_mask"

    assert 1 [ 0 = "$status" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r--' xxx
end_test

start_test chmod "chmod deletes reading permissions for symbolic mode"
    echo xxx > xxx
    chmod 644 xxx
    "../$RSUBOX" chmod go-r xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-------' xxx
end_test

start_test chmod "chmod deletes reading and writing permissions for symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod go-rw xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw------' xxx
end_test

start_test chmod "chmod deletes executing permissions for symbolic mode"
    echo xxx > xxx
    chmod 755 xxx
    "../$RSUBOX" chmod a-x xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx
end_test

start_test chmod "chmod deletes writing permissions for no who and symbolic mode"
    echo xxx > xxx
    chmod 666 xxx
    saved_mask="`umask`"
    umask 2
    "../$RSUBOX" chmod -- -w xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt
    status="$?"
    umask "$saved_mask"

    assert 1 [ 0 = "$status" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-r--r--rw-' xxx
end_test

start_test chmod "chmod deletes searching permissions for directory and symbolic mode"
    mkdir -m 755 xxx
    "../$RSUBOX" chmod go-X xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^drwxr--r--' xxx
end_test

start_test chmod "chmod doesn't delete searching permissions for file and symbolic mode"
    echo xxx > xxx
    chmod 644 xxx
    "../$RSUBOX" chmod go-X xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx
end_test

start_test chmod "chmod deletes searching permissions for executable file and symbolic mode"
    echo xxx > xxx
    chmod 755 xxx
    "../$RSUBOX" chmod go-X xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwxr--r--' xxx
end_test

start_test chmod "chmod deletes set-user/group-ID permissions for symbolic mode"
    echo xxx > xxx
    chmod 7664 xxx
    "../$RSUBOX" chmod ug-s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r-T' xxx
end_test

start_test chmod "chmod doesn't delete set-user/group-ID permission for other permissions and symbolic mode"
    echo xxx > xxx
    chmod 7664 xxx
    "../$RSUBOX" chmod o-s xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwSrwSr-T' xxx
end_test

start_test chmod "chmod deletes sticky bit permission for symbolic mode"
    echo xxx > xxx
    chmod 7664 xxx
    "../$RSUBOX" chmod o-t xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwSrwSr--' xxx
end_test

start_test chmod "chmod doesn't add sticky bit permission for user and group permissions and symbolic mode"
    echo xxx > xxx
    chmod 7664 xxx
    "../$RSUBOX" chmod ug-t xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwSrwSr-T' xxx
end_test

start_test chmod "chmod sets reading permissions for symbolic mode"
    echo xxx > xxx
    chmod 611 xxx
    "../$RSUBOX" chmod go=r xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx
end_test

start_test chmod "chmod sets reading and writing permissions for symbolic mode"
    echo xxx > xxx
    chmod 554 xxx
    "../$RSUBOX" chmod ug=rw xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r--' xxx
end_test

start_test chmod "chmod sets reading and executing permissions for symbolic mode"
    echo xxx > xxx
    chmod 700 xxx
    "../$RSUBOX" chmod go=rx xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwxr-xr-x' xxx
end_test

start_test chmod "chmod sets reading and searching permissions for directory and symbolic mode"
    mkdir -m 644 xxx
    "../$RSUBOX" chmod a=rX xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^dr-xr-xr-x' xxx
end_test

start_test chmod "chmod sets reading permissions and doesn't set searching permissions for file and symbolic mode"
    echo xxx > xxx
    chmod 644 xxx
    "../$RSUBOX" chmod a=rX xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-r--r--r--' xxx
end_test

start_test chmod "chmod sets reading and searching permissions for executable file and symbolic mode"
    echo xxx > xxx
    chmod 645 xxx
    "../$RSUBOX" chmod ug=rX xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-r-xr-xr-x' xxx
end_test

start_test chmod "chmod sets reading and set-user/group-ID permissions for symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod ug=rs xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-r-Sr-Sr--' xxx
end_test

start_test chmod "chmod sets reading permission and doesn't set set-user/group-ID permission for other permissions and symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod o=rs xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r--' xxx
end_test

start_test chmod "chmod sets reading and sticky bit permissions for symbolic mode"
    echo xxx > xxx
    chmod 660 xxx
    "../$RSUBOX" chmod o=rt xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r-T' xxx
end_test

start_test chmod "chmod sets reading permissions and doesn't add sticky bit permission for user and group permissions and symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod ug=rt xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-r--r--r--' xxx
end_test

start_test chmod "chmod sets user permissions as group permissions for symbolic mode"
    echo xxx > xxx
    chmod 644 xxx
    "../$RSUBOX" chmod g=u xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r--' xxx
end_test

start_test chmod "chmod sets group permissions as other permissions for symbolic mode"
    echo xxx > xxx
    chmod 764 xxx
    "../$RSUBOX" chmod o=g xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwxrw-rw-' xxx
end_test

start_test chmod "chmod sets other permissions as group permissions for symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod g=o xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-r--r--' xxx
end_test

start_test chmod "chmod doesn't set set-user-ID permission as group permissions for symbolic mode"
    echo xxx > xxx
    chmod 4644 xxx
    "../$RSUBOX" chmod g=u xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwSrw-r--' xxx
end_test

start_test chmod "chmod doesn't set set-group-ID permission as user permissions for symbolic mode"
    echo xxx > xxx
    chmod 2664 xxx
    "../$RSUBOX" chmod u=g xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rwSr--' xxx
end_test

start_test chmod "chmod doesn't set sticky bit permission as user and group permissions for symbolic mode"
    echo xxx > xxx
    chmod 1666 xxx
    "../$RSUBOX" chmod ug=o xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-rwT' xxx
end_test

start_test chmod "chmod sets user permissions for no who and symbolic mode"
    echo xxx > xxx
    chmod 644 xxx
    saved_mask="`umask`"
    umask 2
    "../$RSUBOX" chmod =u xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt
    status="$?"
    umask "$saved_mask"

    assert 1 [ 0 = "$status" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-r--' xxx
end_test

start_test chmod "chmod changes file permissions for many first clauses and symbolic mode"
    echo xxx > xxx
    chmod 664 xxx
    "../$RSUBOX" chmod u+x,go+X xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rwxrwxr-x' xxx
end_test

start_test chmod "chmod changes file permissions for many second clauses and symbolic mode"
    echo xxx > xxx
    chmod 444 xxx
    "../$RSUBOX" chmod u+w,go=u xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 5 '^-rw-rw-rw-' xxx
end_test

start_test chmod "chmod complains on too few arguments"
    "../$RSUBOX" chmod 755 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test chmod "chmod complains on too few arguments for no mode"
    "../$RSUBOX" chmod > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test chmod "chmod complains on invalid mode"
    echo xxx > xxx
    "../$RSUBOX" chmod YYY xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid mode' ../test_tmp/stderr.txt
end_test

start_test chmod "chmod complains on empty mode"
    echo xxx > xxx
    "../$RSUBOX" chmod '' xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Invalid mode' ../test_tmp/stderr.txt
end_test

start_test chmod "chmod complains on non-existent file"
    "../$RSUBOX" chmod 755 xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test
