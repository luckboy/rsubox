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
start_test od "od dumps from stdin"
    echo 12345678901234567890 | "../$RSUBOX" od > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_dumped.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file"
    echo 12345678901234567890 > test.txt
    "../$RSUBOX" od test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_dumped.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for duplication"
    echo 123456789012345612345678901234561234567890123456abc > test.txt
    "../$RSUBOX" od test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_dumped_dup.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for duplication and -v option"
    echo 123456789012345612345678901234561234567890123456abc > test.txt
    "../$RSUBOX" od -v test.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_dumped_dup_v.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps two files"
    echo 12345678901234567890 > test1.txt
    echo abcdef > test2.txt
    "../$RSUBOX" od test1.txt test2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_dumped_2_files.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps big file"
    "../$RSUBOX" od ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for decimal skip"
    "../$RSUBOX" od -j 16 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_j16.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for octal skip"
    "../$RSUBOX" od -j 020 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_j16.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for hexdecimal skip"
    "../$RSUBOX" od -j 0x10 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_j16.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for decimal count"
    "../$RSUBOX" od -N 32 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_N32.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for octal count"
    "../$RSUBOX" od -N 040 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_N32.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for hexdecimal count"
    "../$RSUBOX" od -N 0x20 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_N32.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for octal offset"
    "../$RSUBOX" od ../test_fixtures/ascii.bin 20 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_j16.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for decimal offset"
    "../$RSUBOX" od ../test_fixtures/ascii.bin 16. > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_j16.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for octal offset with plus"
    "../$RSUBOX" od ../test_fixtures/ascii.bin +20 > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_j16.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for decimal offset with plus"
    "../$RSUBOX" od ../test_fixtures/ascii.bin +16. > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_j16.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for none address base"
    "../$RSUBOX" od -A n ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_An.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for decimal address base"
    "../$RSUBOX" od -A d ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_Ad.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for octal address base"
    "../$RSUBOX" od -A o ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_Ao.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for hexdecimal address base"
    "../$RSUBOX" od -A x ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_Ax.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for many types"
    "../$RSUBOX" od -t d1x2o8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_td1x2o8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for a type"
    "../$RSUBOX" od -t a ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_ta.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for c type"
    "../$RSUBOX" od -t c ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tc.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for d type"
    "../$RSUBOX" od -t d ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_td4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for d1 type"
    "../$RSUBOX" od -t d1 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_td1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for d2 type"
    "../$RSUBOX" od -t d2 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_td2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for d4 type"
    "../$RSUBOX" od -t d4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_td4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for d8 type"
    "../$RSUBOX" od -t d8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_td8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o type"
    "../$RSUBOX" od -t o ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o1 type"
    "../$RSUBOX" od -t o1 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o2 type"
    "../$RSUBOX" od -t o2 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o4 type"
    "../$RSUBOX" od -t o4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o8 type"
    "../$RSUBOX" od -t o8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for u type"
    "../$RSUBOX" od -t u ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tu4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for u1 type"
    "../$RSUBOX" od -t u1 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tu1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for u2 type"
    "../$RSUBOX" od -t u2 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tu2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for u4 type"
    "../$RSUBOX" od -t u4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tu4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for u8 type"
    "../$RSUBOX" od -t u8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tu8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for x type"
    "../$RSUBOX" od -t x ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tx4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for x1 type"
    "../$RSUBOX" od -t x1 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tx1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for x2 type"
    "../$RSUBOX" od -t x2 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tx2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for x4 type"
    "../$RSUBOX" od -t x4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tx4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for x8 type"
    "../$RSUBOX" od -t x8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tx8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for oC type"
    "../$RSUBOX" od -t oC ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for oS type"
    "../$RSUBOX" od -t oS ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for oI type"
    "../$RSUBOX" od -t oI ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for oL type"
    "../$RSUBOX" od -t oL ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for -b option"
    "../$RSUBOX" od -b ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for -c option"
    "../$RSUBOX" od -c ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tc.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for -d option"
    "../$RSUBOX" od -d ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tu2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for -o option"
    "../$RSUBOX" od -o ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for -s option"
    "../$RSUBOX" od -s ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_td2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for -x option"
    "../$RSUBOX" od -x ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_tx2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

if [ x"$TEST_NO_IEEE754" = x"" ]; then
    start_test od "od dumps file for f type"
        "../$RSUBOX" od -t f ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_tf8.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test

    start_test od "od dumps file for f4 type"
        "../$RSUBOX" od -t f4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_tf4.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test

    start_test od "od dumps file for f8 type"
        "../$RSUBOX" od -t f8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_tf8.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test

    start_test od "od dumps file for fF type"
        "../$RSUBOX" od -t fF ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_tf4.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test

    start_test od "od dumps file for fD type"
        "../$RSUBOX" od -t fD ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_tf8.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test

    start_test od "od dumps file for fL type"
        "../$RSUBOX" od -t fL ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_tf8.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test
fi

start_test od "od dumps file for o1 type and little endian"
    "../$RSUBOX" od -L -t o1 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o2 type and little endian"
    "../$RSUBOX" od -L -t o2 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o4 type and little endian"
    "../$RSUBOX" od -L -t o4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o8 type and little endian"
    "../$RSUBOX" od -L -t o8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_to8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test


start_test od "od dumps file for o1 type and big endian"
    "../$RSUBOX" od -B -t o1 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_B_to1.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o2 type and big endian"
    "../$RSUBOX" od -B -t o2 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_B_to2.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o4 type and big endian"
    "../$RSUBOX" od -B -t o4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_B_to4.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test od "od dumps file for o8 type and big endian"
    "../$RSUBOX" od -B -t o8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_compare_files 2 ../test_fixtures/test_od_ascii_B_to8.txt ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

if [ x"$TEST_NO_IEEE754" = x"" ]; then
    start_test od "od dumps file for f4 type and little endian"
        "../$RSUBOX" od -L -t f4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_tf4.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test

    start_test od "od dumps file for f8 type and little endian"
        "../$RSUBOX" od -L -t f8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_tf8.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test

    start_test od "od dumps file for f4 type and big endian"
        "../$RSUBOX" od -B -t f4 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_B_tf4.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test

    start_test od "od dumps file for f8 type and big endian"
        "../$RSUBOX" od -B -t f8 ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

        assert 1 [ 0 = "$?" ] &&
        assert_compare_files 2 ../test_fixtures/test_od_ascii_B_tf8.txt ../test_tmp/stdout.txt &&
        assert_file_size 3 0 ../test_tmp/stderr.txt
    end_test
fi

start_test od "od complains on too few data for one block"
    "../$RSUBOX" od -j 1b ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few data' ../test_tmp/stderr.txt
end_test

start_test od "od complains on too few data for one kilobyte"
    "../$RSUBOX" od -j 1k ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few data' ../test_tmp/stderr.txt
end_test

start_test od "od complains on too few data for one megabyte"
    "../$RSUBOX" od -j 1m ../test_fixtures/ascii.bin > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content 3 'Too few data' ../test_tmp/stderr.txt
end_test

start_test od "od complains on non-existent file"
    "../$RSUBOX" od xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 != "$?" ] &&
    assert_file_content 2 '0000000' ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test
