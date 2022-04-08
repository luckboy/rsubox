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
start_test grep "grep prints line from stdin"
    (echo abcdef; echo ghijkl) | "../$RSUBOX" grep abcdef > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_content 2 abcdef ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from more stdin"
    cat ../test_fixtures/test_grep.txt | "../$RSUBOX" grep 'com[a-z]*' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from one file"
    "../$RSUBOX" grep 'p[ei][a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bee forecast overall mouth perfect foreigner' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'piece reliable serve march prejudice bill' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from two files"
    "../$RSUBOX" grep 'com[a-z]*' ../test_fixtures/test_grep.txt ../test_fixtures/test_grep2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 '../test_fixtures/test_grep.txt:burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 '../test_fixtures/test_grep.txt:coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 '../test_fixtures/test_grep2.txt:youth lump communication inquiry queue' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file and stdin"
    echo community | "../$RSUBOX" grep 'com[a-z]*' ../test_fixtures/test_grep.txt - > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 '../test_fixtures/test_grep.txt:burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 '../test_fixtures/test_grep.txt:coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 '(standard input):community' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints line from one file for two files"
    "../$RSUBOX" grep 'matrix' ../test_fixtures/test_grep.txt ../test_fixtures/test_grep2.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 '../test_fixtures/test_grep.txt:burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for two patterns"
    "../$RSUBOX" grep "`printf 'matrix\ndive'`" ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for two patterns with empty line"
    "../$RSUBOX" grep "`printf 'matrix\n\ndive'`" ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for tree patterns and -e options"
    "../$RSUBOX" grep -e "`printf 'matrix\njet'`" -e 'complication' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for tree patterns, empty line and -e options"
    "../$RSUBOX" grep -e "`printf 'matrix\n\njet'`" -e 'complication' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for tree patterns and -f options"
    echo forecast > patterns1.txt
    echo jet >> patterns1.txt
    echo complication > patterns2.txt
    "../$RSUBOX" grep -f patterns1.txt -f patterns2.txt ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bee forecast overall mouth perfect foreigner' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for tree patterns, empty line and -f options"
    echo forecast > patterns1.txt
    echo >> patterns1.txt
    echo jet >> patterns1.txt
    echo complication > patterns2.txt
    "../$RSUBOX" grep -f patterns1.txt -f patterns2.txt ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bee forecast overall mouth perfect foreigner' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for tree patterns, -e option and -f option"
    echo complication > patterns.txt
    "../$RSUBOX" grep -e "`printf 'matrix\n\njet'`" -f patterns.txt ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 3 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 6 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep doesn't prints lines from file"
    "../$RSUBOX" grep 'xxx[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for basic regular expression"
    "../$RSUBOX" grep 'm[ao][a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'bee forecast overall mouth perfect foreigner' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'piece reliable serve march prejudice bill' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep doesn't prints lines from file for basic regular expression"
    "../$RSUBOX" grep 'yyy[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints line from file for fixed string"
    "../$RSUBOX" grep -F 'straight' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'corruption straight swop aquarium copy' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep doesn't prints lines from file for fixed string"
    "../$RSUBOX" grep -F 'com[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for extended regular expression"
    "../$RSUBOX" grep -E '(bee|swop)' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'bee forecast overall mouth perfect foreigner' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'corruption straight swop aquarium copy' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep doesn't prints lines from file for extended regular expression"
    "../$RSUBOX" grep '(xxx|yyy)' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for no output option"
    "../$RSUBOX" grep 'com[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for no output option and -n option"
    "../$RSUBOX" grep -n 'com[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 '3:burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 '8:coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints number of lines from file for -c option"
    "../$RSUBOX" grep -c 'com[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 '2' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints file from file for -l option"
    "../$RSUBOX" grep -l 'com[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 '../test_fixtures/test_grep.txt' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints file from stdin for -l option"
    cat ../test_fixtures/test_grep.txt | "../$RSUBOX" grep -l 'com[a-z]*' > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 '(standard input)' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep doesn't print lines from file for -q option and success"
    "../$RSUBOX" grep -q 'com[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep doesn't print lines from file for -q option and failure"
    "../$RSUBOX" grep -q 'xxx[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 1 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for -i option and regular expresion"
    "../$RSUBOX" grep -i 'COM[A-Z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'coffee complication quit command position capture' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints line from file for -i option and fixed string"
    "../$RSUBOX" grep -F -i 'CAPTIVATE' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for -x option and regular expresion"
    "../$RSUBOX" grep -x 'b[a-z]*.*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'bee forecast overall mouth perfect foreigner' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints line from file for -x option and fixed string"
    "../$RSUBOX" grep -F -x 'seed applied dive jet vain' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for -ix options and regular expresion"
    "../$RSUBOX" grep -ix 'B[A-Z]*.*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 2 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'burn captivate matrix notion comedy paint' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 'bee forecast overall mouth perfect foreigner' ../test_tmp/stdout.txt &&
    assert_file_size 5 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints line from file for -ix options and fixed string"
    "../$RSUBOX" grep -F -ix 'SEED applied DIVE jet vain' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 1 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_size 4 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for inverted match"
    "../$RSUBOX" grep -v 'com[a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 6 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'This file contains random words for grep program:' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 '' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'bee forecast overall mouth perfect foreigner' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_line 7 5 'corruption straight swop aquarium copy' ../test_tmp/stdout.txt &&
    assert_file_line 8 6 'piece reliable serve march prejudice bill' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep prints lines from file for inverted match"
    "../$RSUBOX" grep -v -e 'com[a-z]*' -e 'p[ei][a-z]*' ../test_fixtures/test_grep.txt > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 0 = "$?" ] &&
    assert_file_line_count 2 4 ../test_tmp/stdout.txt &&
    assert_file_line 3 1 'This file contains random words for grep program:' ../test_tmp/stdout.txt &&
    assert_file_line 4 2 '' ../test_tmp/stdout.txt &&
    assert_file_line 5 3 'seed applied dive jet vain' ../test_tmp/stdout.txt &&
    assert_file_line 6 4 'corruption straight swop aquarium copy' ../test_tmp/stdout.txt &&
    assert_file_size 7 0 ../test_tmp/stderr.txt
end_test

start_test grep "grep complains on non-existent file"
    "../$RSUBOX" grep xxx xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_content_pattern 3 '^xxx: ' ../test_tmp/stderr.txt
end_test

start_test grep "grep complains on non-existent file for -s option"
    "../$RSUBOX" grep -s xxx xxx  > ../test_tmp/stdout.txt 2> ../test_tmp/stderr.txt 

    assert 1 [ 2 = "$?" ] &&
    assert_file_size 2 0 ../test_tmp/stdout.txt &&
    assert_file_size 3 0 ../test_tmp/stderr.txt
end_test
