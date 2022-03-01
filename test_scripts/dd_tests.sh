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
start_test dd "dd copies from standard input to standard output"
    "../$RSUBOX" dd < ../test_fixtures/test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test.txt ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
end_test

start_test dd "dd copies file"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&    
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd copies file for block size 256"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy bs=256 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "18+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "18+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd copies file for block size 2bx4k"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy bs=2bx4k > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&    
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd copies file for block size 4k"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy bs=4k > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "1+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "1+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd copies number of blocks"
    cp ../test_fixtures/test.txt xxx
    dd if=../test_fixtures/test.txt of=../test_tmp/expected.txt count=5 2> /dev/null
    "../$RSUBOX" dd if=xxx of=yyy count=5 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "5+0 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "5+0 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd copies number of blocks that is greater than number of file blocks"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy count=12 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd skips file"
    cp ../test_fixtures/test.txt xxx
    dd if=../test_fixtures/test.txt of=../test_tmp/expected.txt skip=2 2> /dev/null
    "../$RSUBOX" dd if=xxx of=yyy skip=2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "7+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "7+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd seeks file"
    cp ../test_fixtures/test.txt xxx
    dd if=../test_fixtures/test.txt of=../test_tmp/expected.txt seek=2 2> /dev/null
    "../$RSUBOX" dd if=xxx of=yyy seek=2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd seeks file with data"
    cp ../test_fixtures/test.txt xxx
    echo yyy > ../test_tmp/expected.txt
    dd if=../test_fixtures/test.txt of=../test_tmp/expected.txt seek=2 2> /dev/null
    echo yyy > yyy
    "../$RSUBOX" dd if=xxx of=yyy seek=2 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd reads blocks instead skips file"
    cp ../test_fixtures/test.txt xxx
    dd if=../test_fixtures/test.txt of=../test_tmp/expected.txt skip=2 2> /dev/null
    "../$RSUBOX" dd if=xxx of=yyy skip=2 conv=readskip > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "7+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "7+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd reads blocks instead seeks file"
    cp ../test_fixtures/test.txt xxx
    dd if=../test_fixtures/test.txt of=../test_tmp/expected.txt seek=2 2> /dev/null
    "../$RSUBOX" dd if=xxx of=yyy seek=2 conv=readskip > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd reads blocks instead seeks file with data"
    cp ../test_fixtures/test.txt xxx
    echo yyy > ../test_tmp/expected.txt
    dd if=../test_fixtures/test.txt of=../test_tmp/expected.txt seek=2 2> /dev/null
    echo yyy > yyy
    "../$RSUBOX" dd if=xxx of=yyy seek=2 conv=readskip > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd doesn't truncate file for no seek operand"
    echo xxx > xxx
    echo yyyyyy > yyy
    echo xxx > ../test_tmp/expected.txt
    echo yy >> ../test_tmp/expected.txt
    "../$RSUBOX" dd if=xxx of=yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd truncates file for seek operand"
    echo xxx > xxx
    echo yyyyyy > yyy
    "../$RSUBOX" dd if=xxx of=yyy seek=0 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_file_content 9 xxx yyy
end_test

start_test dd "dd copies file for input block size that is greater than output block size"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy ibs=1k > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "4+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd copies file for input block size that is less than output block size"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy obs=1k > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "4+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd converts ASCII to EBCDIC"
    cp ../test_fixtures/ascii.bin xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=ebcdic > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/ebcdic.bin yyy
end_test

start_test dd "dd converts ASCII to different EBCDIC (IBM)"
    cp ../test_fixtures/ascii.bin xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=ibm > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/ibm.bin yyy
end_test

start_test dd "dd converts EBCDIC to ASCII"
    cp ../test_fixtures/ebcdic.bin xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=ascii > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/ascii.bin yyy
end_test

start_test dd "dd converts to lower case"
    cp ../test_fixtures/ascii.bin xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=lcase > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/lcase.bin yyy
end_test

start_test dd "dd converts to upper case"
    cp ../test_fixtures/ascii.bin xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=ucase > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/ucase.bin yyy
end_test

start_test dd "dd converts to lower case for EBCDIC"
    cp ../test_fixtures/ebcdic.bin xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=ascii,lcase,ebcdic > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/ebcdic_lcase.bin yyy
end_test

start_test dd "dd converts to upper case for EBCDIC"
    cp ../test_fixtures/ebcdic.bin xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=ascii,ucase,ebcdic > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_fixtures/ebcdic_ucase.bin yyy
end_test

start_test dd "dd converts for block conversion"
    echo 123456789012345678901234567890 > xxx
    echo 12345678901234567890123456789012345 >> xxx
    echo 1234567890123456789012345 >> xxx
    echo -n '123456789012345678901234567890                                  ' > ../test_tmp/expected.txt
    echo -n '12345678901234567890123456789012345                             ' >> ../test_tmp/expected.txt
    echo -n '1234567890123456789012345                                       ' >> ../test_tmp/expected.txt
    "../$RSUBOX" dd if=xxx of=yyy conv=block cbs=64 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd converts for block conversion and one truncated record"
    echo 12345678901234567890123456789012345 > xxx
    echo 1234567890123456789012345678901234567890123456789012345678901234567890 >> xxx
    echo 123456789012345678901234567890 >> xxx
    echo -n '12345678901234567890123456789012345                             ' > ../test_tmp/expected.txt
    echo -n '1234567890123456789012345678901234567890123456789012345678901234' >> ../test_tmp/expected.txt
    echo -n '123456789012345678901234567890                                  ' >> ../test_tmp/expected.txt
    "../$RSUBOX" dd if=xxx of=yyy conv=block cbs=64 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 3 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_file_line 6 3 "1 truncated record" ../test_tmp/stderr.txt
    assert_existent_file 7 xxx &&
    assert_existent_file 8 yyy &&
    assert_file_mode 9 '^-' yyy &&
    assert_compare_files 10 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd converts for block conversion for two truncated records"
    echo 1234567890123456789012345678901234567890123456789012345678901234567890 > xxx
    echo 12345678901234567890123456789012345 >> xxx
    echo 123456789012345678901234567890123456789012345678901234567890123456789012345 >> xxx
    echo -n '1234567890123456789012345678901234567890123456789012345678901234' > ../test_tmp/expected.txt
    echo -n '12345678901234567890123456789012345                             ' >> ../test_tmp/expected.txt
    echo -n '1234567890123456789012345678901234567890123456789012345678901234' >> ../test_tmp/expected.txt
    "../$RSUBOX" dd if=xxx of=yyy conv=block cbs=64 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 3 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_file_line 6 3 "2 truncated records" ../test_tmp/stderr.txt
    assert_existent_file 7 xxx &&
    assert_existent_file 8 yyy &&
    assert_file_mode 9 '^-' yyy &&
    assert_compare_files 10 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd converts for block conversion"
    echo -n '123456789012345678901234567890     67890                        ' > xxx
    echo -n '12345678901234567890123456789012345    0123456789012345678901234' >> xxx
    echo -n '12345678 012345    012345                                       ' >> xxx
    echo '123456789012345678901234567890     67890' > ../test_tmp/expected.txt
    echo '12345678901234567890123456789012345    0123456789012345678901234' >> ../test_tmp/expected.txt
    echo '12345678 012345    012345' >> ../test_tmp/expected.txt
    "../$RSUBOX" dd if=xxx of=yyy conv=unblock cbs=64 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd swaps byte pairs"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=swab > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&    
    assert_compare_files 9 ../test_fixtures/test_swab.txt yyy
end_test

start_test dd "dd copies file for no error conversion"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=noerror> ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&    
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd doesn't truncate file for seek operand and no trunc conversion" 
    echo xxx > xxx
    echo yyyyyy > yyy
    echo xxx > ../test_tmp/expected.txt
    echo yy >> ../test_tmp/expected.txt
    "../$RSUBOX" dd if=xxx of=yyy seek=0 conv=notrunc > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "0+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "0+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&
    assert_compare_files 9 ../test_tmp/expected.txt yyy
end_test

start_test dd "dd copies file for no error conversion"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=noerror > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&    
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd copies file for sync conversion"
    cp ../test_fixtures/test.txt xxx
    "../$RSUBOX" dd if=xxx of=yyy conv=sync > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_line_count 3 2 ../test_tmp/stderr.txt &&
    assert_file_line 4 1 "9+1 records in" ../test_tmp/stderr.txt &&
    assert_file_line 5 2 "9+1 records out" ../test_tmp/stderr.txt
    assert_existent_file 6 xxx &&
    assert_existent_file 7 yyy &&
    assert_file_mode 8 '^-' yyy &&    
    assert_compare_files 9 ../test_fixtures/test.txt yyy
end_test

start_test dd "dd complains on operand without argument"
    echo -n | "../$RSUBOX" dd xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "No operand argument" ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on invalid operand"
    echo -n | "../$RSUBOX" dd xxx=yyy  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "Invalid operand" ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on input block size that is zero"
    echo -n | "../$RSUBOX" dd ibs=0  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "Input block size is zero" ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on output block size that is zero"
    echo -n | "../$RSUBOX" dd obs=0  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "Output block size is zero" ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on conversion block size that is zero"
    echo -n | "../$RSUBOX" dd cbs=0  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "Conversion block size is zero" ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on overflow"
    echo -n | "../$RSUBOX" dd bs=2147483648x2147483648x4 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "Overflow" ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on non-integer count argument"
    echo -n | "../$RSUBOX" dd count=xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on non-integer skip argument"
    echo -n | "../$RSUBOX" dd skip=xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on non-integer seek argument"
    echo -n | "../$RSUBOX" dd seek=xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^invalid digit' ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on invalid conversion"
    echo -n | "../$RSUBOX" dd conv=xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "Invalid conversion" ../test_tmp/stderr.txt
end_test

start_test dd "dd complains on non-existent input file"
    "../$RSUBOX" dd if=xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test
