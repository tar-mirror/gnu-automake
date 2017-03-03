#! /bin/sh
# Copyright (C) 2011-2012 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Older versions of prove and TAP::Harness (e.g., 3.17) didn't recognize
# a "Bail out!" directive that was preceded by whitespace, but more modern
# versions (e.g., 3.23) do.  So we leave this behaviour undefined for the
# perl implementation of the Automake TAP driver, but expect the latter,
# "more modern" behaviour in our awk TAP driver.

am_tap_implementation=shell
. ./defs || Exit 1

. "$am_testauxdir"/tap-setup.sh || fatal_ "sourcing tap-setup.sh"

cat > a.test <<END
1..1
ok 1
 Bail out!
END

cat > b.test <<END
1..1
ok 1 # SKIP
${tab}Bail out!
END

cat > c.test <<END
1..1
  ${tab}  ${tab}${tab}Bail out!   FUBAR! $tab
END

cat >> exp <<END
PASS: a.test 1
ERROR: a.test - Bail out!
SKIP: b.test 1
ERROR: b.test - Bail out!
ERROR: c.test - Bail out! FUBAR!
END

TESTS='a.test b.test c.test' $MAKE -e check >stdout \
  && { cat stdout; Exit 1; }
cat stdout

count_test_results total=5 pass=1 fail=0 xpass=0 xfail=0 skip=1 error=3

LC_ALL=C sort exp > t
mv -f t exp

# We need the sort below to account for parallel make usage.
grep ': [abcde]\.test' stdout \
  | sed "s/[ $tab]*#[ $tab]*SKIP.*//" \
  | LC_ALL=C sort > got

cat exp
cat got
diff exp got

:
