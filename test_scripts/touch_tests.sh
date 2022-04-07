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
start_test touch "touch updates access time and modification time of file"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -t 201004101526.37 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2010 xxx &&
    assert_file_mtime 8 2010 xxx
end_test

start_test touch "touch updates access time and modification time of file without century for 1970 year"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -t 7002091425.36 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 1970 xxx &&
    assert_file_mtime 8 1970 xxx
end_test

start_test touch "touch updates access time and modification time of file without century for 1970 year"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -t 7002091425.36 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 1970 xxx &&
    assert_file_mtime 8 1970 xxx
end_test

start_test touch "touch updates access time and modification time of file without century for 2000 year"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -t 0002091425.36 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2000 xxx &&
    assert_file_mtime 8 2000 xxx
end_test

start_test touch "touch updates access time and modification time of file without seconds"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -t 201004101526 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2010 xxx &&
    assert_file_mtime 8 2010 xxx
end_test

start_test touch "touch updates access time and modification time of file without time"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx
end_test

start_test touch "touch updates access times and modification times of two files"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    touch -at 200301010000.00 yyy
    touch -mt 200401010000.00 yyy
    "../$RSUBOX" touch -t 201004101526.37 xxx yyy > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2010 xxx &&
    assert_file_mtime 8 2010 xxx &&
    assert_existent_file 9 yyy &&
    assert_file_mode 10 '^-' yyy &&
    assert_file_atime 11 2010 yyy &&
    assert_file_mtime 12 2010 yyy
end_test

start_test touch "touch updates access time and modification time of directory"
    mkdir test
    touch -at 200101010000.00 test
    touch -mt 200201010000.00 test
    "../$RSUBOX" touch -t 201004101526.37 test > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 test &&
    assert_file_mode 6 '^d' test &&
    assert_file_atime 7 2010 test &&
    assert_file_mtime 8 2010 test
end_test

start_test touch "touch updates access time of file"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -at 201004101526.37 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2010 xxx &&
    assert_file_mtime 8 2002 xxx
end_test

start_test touch "touch updates modification time of file"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -mt 201004101526.37 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2001 xxx &&
    assert_file_mtime 8 2010 xxx
end_test

start_test touch "touch updates access time and modification time of file with options"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -amt 201004101526.37 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2010 xxx &&
    assert_file_mtime 8 2010 xxx
end_test

start_test touch "touch updates access time and modification time of file for reference file"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    touch -at 200301010000.00 yyy
    touch -mt 200401010000.00 yyy
    "../$RSUBOX" touch -r yyy xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2003 xxx &&
    assert_file_mtime 8 2004 xxx
end_test

start_test touch "touch updates access time of file for reference file"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    touch -at 200301010000.00 yyy
    touch -mt 200401010000.00 yyy
    "../$RSUBOX" touch -ar yyy xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2003 xxx &&
    assert_file_mtime 8 2002 xxx
end_test

start_test touch "touch updates modification time of file for reference file"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    touch -at 200301010000.00 yyy
    touch -mt 200401010000.00 yyy
    "../$RSUBOX" touch -mr yyy xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2001 xxx &&
    assert_file_mtime 8 2004 xxx
end_test

start_test touch "touch updates access time and modification time of file with options for reference file"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    echo yyy > yyy
    touch -at 200301010000.00 yyy
    touch -mt 200401010000.00 yyy
    "../$RSUBOX" touch -amr yyy xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2003 xxx &&
    assert_file_mtime 8 2004 xxx
end_test

start_test touch "touch creates file"
    "../$RSUBOX" touch -t 201004101526.37 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2010 xxx &&
    assert_file_mtime 8 2010 xxx
end_test

start_test touch "touch updates access time and modification time of file with -c option"
    echo xxx > xxx
    touch -at 200101010000.00 xxx
    touch -mt 200201010000.00 xxx
    "../$RSUBOX" touch -ct 201004101526.37 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_existent_file 4 xxx &&
    assert_file_mode 6 '^-' xxx &&
    assert_file_atime 7 2010 xxx &&
    assert_file_mtime 8 2010 xxx
end_test

start_test touch "touch doesn't create file with -c option"
    "../$RSUBOX" touch -ct 201004101526.37 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt &&
    assert_non_existent_file 4 xxx
end_test

start_test touch "touch complains on too few arguments"
    "../$RSUBOX" touch > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few arguments' ../test_tmp/stderr.txt
end_test

start_test touch "touch complains on invalid date length"
    "../$RSUBOX" touch -t 21004101526 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "Invalid date" ../test_tmp/stderr.txt
end_test

start_test touch "touch complains on non-digit characters of date"
    "../$RSUBOX" touch -t 2010xx101526 xxx > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 "Invalid date" ../test_tmp/stderr.txt
end_test
