#! /bin/sh
# Copyright (C) 2003-2012 Free Software Foundation, Inc.
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

# Test missing with version mismatches.

. ./defs || exit 1

cat >>configure.ac <<'EOF'
AC_OUTPUT
EOF

: > Makefile.am

get_shell_script missing

$ACLOCAL
$AUTOCONF
$AUTOMAKE --add-missing

# Make sure we do use missing, even if the user exported AUTOCONF.
# (We cannot export this new value, because it would be used by Automake
# when tracing, and missing is no good for this.)
MYAUTOCONF="./missing --run $AUTOCONF"
unset AUTOCONF

./configure AUTOCONF="$MYAUTOCONF"
$MAKE
$sleep
# Hopefully the install version of Autoconf cannot compete with this one...
echo 'AC_PREREQ(9999)' >> aclocal.m4
$MAKE distdir

# Try version number suffixes if we can add them safely.
case $MYAUTOCONF in *autoconf)
  ./configure AUTOCONF="${MYAUTOCONF}6789"
  $MAKE
  $sleep
  # Hopefully the install version of Autoconf cannot compete with this one...
  echo 'AC_PREREQ(9999)' >> aclocal.m4
  $MAKE distdir
esac

# Run again, but without missing, to ensure that timestamps were updated.
export AUTOMAKE ACLOCAL
./configure AUTOCONF="$MYAUTOCONF"
$MAKE

# Make sure $MAKE fails when timestamps aren't updated and missing is not used.
$sleep
touch aclocal.m4
$MAKE && exit 1

:
