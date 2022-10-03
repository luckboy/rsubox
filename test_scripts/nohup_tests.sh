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
start_test nohup "nohup executes echo program"
    "../$RSUBOX" nohup echo abcdef ghijkl > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 'abcdef ghijkl' ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test nohup "nohup complains on non-existent program"
    "../$RSUBOX" nohup ./xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 127 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\./xxx: ' ../test_tmp/stderr.txt
end_test

start_test nohup "nohup complains on non-executable program"
    echo xxx > xxx
    "../$RSUBOX" nohup ./xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 126 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^\./xxx: ' ../test_tmp/stderr.txt
end_test
