#!/bin/sh
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
if [ "$RSUBOX" = "" ]; then
    RSUBOX=target/debug/rsubox
fi

if [ "$TEST_BLOCK_DEVICE" = "" ]; then
    TEST_BLOCK_DEVICE=/dev/sda
fi

if [ "$TEST_CHAR_DEVICE" = "" ]; then
    TEST_CHAR_DEVICE=/dev/tty0
fi

. ./test_scripts/lib.sh

start_test_suites
. ./test_scripts/basename_tests.sh
. ./test_scripts/cat_tests.sh
. ./test_scripts/chgrp_tests.sh
. ./test_scripts/chmod_tests.sh
. ./test_scripts/chown_tests.sh
. ./test_scripts/cksum_tests.sh
. ./test_scripts/cmp_tests.sh
. ./test_scripts/cp_tests.sh
. ./test_scripts/cut_tests.sh
. ./test_scripts/date_tests.sh
. ./test_scripts/dd_tests.sh
. ./test_scripts/dirname_tests.sh
. ./test_scripts/du_tests.sh
. ./test_scripts/echo_tests.sh
. ./test_scripts/env_tests.sh
. ./test_scripts/expr_tests.sh
. ./test_scripts/false_tests.sh
. ./test_scripts/fold_tests.sh
. ./test_scripts/head_tests.sh
. ./test_scripts/id_tests.sh
. ./test_scripts/link_tests.sh
. ./test_scripts/ln_tests.sh
. ./test_scripts/ls_tests.sh
. ./test_scripts/mkdir_tests.sh
. ./test_scripts/mkfifo_tests.sh
. ./test_scripts/mv_tests.sh
. ./test_scripts/nice_tests.sh
. ./test_scripts/paste_tests.sh
. ./test_scripts/printf_tests.sh
. ./test_scripts/rm_tests.sh
. ./test_scripts/rmdir_tests.sh
. ./test_scripts/sort_tests.sh
. ./test_scripts/tail_tests.sh
. ./test_scripts/tee_tests.sh
. ./test_scripts/test_tests.sh
. ./test_scripts/touch_tests.sh
. ./test_scripts/tr_tests.sh
. ./test_scripts/true_tests.sh
. ./test_scripts/uname_tests.sh
. ./test_scripts/unlink_tests.sh
. ./test_scripts/wc_tests.sh
end_test_suites
