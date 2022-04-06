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
start_test id "id prints effecitive user identifier"
    "../$RSUBOX" id -u > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -u`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints effective group identifier"
    "../$RSUBOX" id -g > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -g`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints real user identifier"
    "../$RSUBOX" id -ur > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -ur`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints real group identifier"
    "../$RSUBOX" id -gr > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -gr`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints group identifiers"
    echo -n > ../test_tmp/expected_groups.txt
    for i in `id -G`; do
        echo "$i" >> ../test_tmp/expected_groups.txt
    done
    sort ../test_tmp/expected_groups.txt > ../test_tmp/expected_groups_sorted.txt
    "../$RSUBOX" id -G > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    echo -n > ../test_tmp/groups.txt
    for i in `cat ../test_tmp/stdout.txt`; do
        echo "$i" >> ../test_tmp/groups.txt
    done
    sort ../test_tmp/groups.txt > ../test_tmp/groups_sorted.txt

    assert 1 [ 0 = "$status" ] &&
    assert_compare_files 2 ../test_tmp/expected_groups_sorted.txt ../test_tmp/groups_sorted.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints effecitive user name"
    "../$RSUBOX" id -un > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -un`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints effective group name"
    "../$RSUBOX" id -gn > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -gn`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints real user name"
    "../$RSUBOX" id -urn > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -urn`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints real group name"
    "../$RSUBOX" id -grn > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -grn`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints groups"
    echo -n > ../test_tmp/expected_groups.txt
    for i in `id -Gn`; do
        echo "$i" >> ../test_tmp/expected_groups.txt
    done
    sort ../test_tmp/expected_groups.txt > ../test_tmp/expected_groups_sorted.txt
    "../$RSUBOX" id -Gn > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    echo -n > ../test_tmp/groups.txt
    for i in `cat ../test_tmp/stdout.txt`; do
        echo "$i" >> ../test_tmp/groups.txt
    done
    sort ../test_tmp/groups.txt > ../test_tmp/groups_sorted.txt

    assert 1 [ 0 = "$status" ] &&
    assert_compare_files 2 ../test_tmp/expected_groups_sorted.txt ../test_tmp/groups_sorted.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints user identifier for user"
    user="`id -un`"
    "../$RSUBOX" id -u "$user" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -u "$user"`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints group identifier for user"
    user="`id -un`"
    "../$RSUBOX" id -g "$user" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -g "$user"`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints group identifiers for user"
    user="`id -un`"
    echo -n > ../test_tmp/expected_groups.txt
    for i in `id -G "$user"`; do
        echo "$i" >> ../test_tmp/expected_groups.txt
    done
    sort ../test_tmp/expected_groups.txt > ../test_tmp/expected_groups_sorted.txt
    "../$RSUBOX" id -G "$user" > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    echo -n > ../test_tmp/groups.txt
    for i in `cat ../test_tmp/stdout.txt`; do
        echo "$i" >> ../test_tmp/groups.txt
    done
    sort ../test_tmp/groups.txt > ../test_tmp/groups_sorted.txt

    assert 1 [ 0 = "$status" ] &&
    assert_compare_files 2 ../test_tmp/expected_groups_sorted.txt ../test_tmp/groups_sorted.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints user identifier for root"
    "../$RSUBOX" id -u root > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -u root`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints group identifier for root"
    "../$RSUBOX" id -g root > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 "`id -g root`" ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test id "id prints group identifiers for root"
    echo -n > ../test_tmp/expected_groups.txt
    for i in `id -G root`; do
        echo "$i" >> ../test_tmp/expected_groups.txt
    done
    sort ../test_tmp/expected_groups.txt > ../test_tmp/expected_groups_sorted.txt
    "../$RSUBOX" id -G root > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 
    status="$?"
    echo -n > ../test_tmp/groups.txt
    for i in `cat ../test_tmp/stdout.txt`; do
        echo "$i" >> ../test_tmp/groups.txt
    done
    sort ../test_tmp/groups.txt > ../test_tmp/groups_sorted.txt

    assert 1 [ 0 = "$status" ] &&
    assert_compare_files 2 ../test_tmp/expected_groups_sorted.txt ../test_tmp/groups_sorted.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test
