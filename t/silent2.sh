#!/bin/sh
# Copyright (C) 2009-2012 Free Software Foundation, Inc.
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

# Check silent-rules mode, without libtool, non-fastdep case
# (so that, with GCC, we also cover the other code paths in depend2).

# Please keep this file in sync with 'silent.sh'.

required=gcc
. ./defs || exit 1

mkdir sub

cat >>configure.ac <<'EOF'
AM_SILENT_RULES
AC_CONFIG_FILES([sub/Makefile])
AC_PROG_CC
AM_PROG_CC_C_O
AC_OUTPUT
EOF

cat > Makefile.am <<'EOF'
# Need generic and non-generic rules.
bin_PROGRAMS = foo bar
bar_CFLAGS = $(AM_CFLAGS)
SUBDIRS = sub
EOF

cat > sub/Makefile.am <<'EOF'
AUTOMAKE_OPTIONS = subdir-objects
# Need generic and non-generic rules.
bin_PROGRAMS = baz bla
bla_CFLAGS = $(AM_CFLAGS)
EOF

cat > foo.c <<'EOF'
int main ()
{
  return 0;
}
EOF
cp foo.c bar.c
cp foo.c sub/baz.c
cp foo.c sub/bla.c

$ACLOCAL
$AUTOMAKE --add-missing
$AUTOCONF

./configure am_cv_CC_dependencies_compiler_type=gcc --enable-silent-rules
$MAKE >stdout || { cat stdout; exit 1; }
cat stdout
$EGREP ' (-c|-o)' stdout && exit 1
grep 'mv ' stdout && exit 1
grep 'CC .*foo\.' stdout
grep 'CC .*bar\.' stdout
grep 'CC .*baz\.' stdout
grep 'CC .*bla\.' stdout
grep 'CCLD .*foo' stdout
grep 'CCLD .*bar' stdout
grep 'CCLD .*baz' stdout
grep 'CCLD .*bla' stdout

$MAKE clean
$MAKE V=1 >stdout || { cat stdout; exit 1; }
cat stdout
grep ' -c' stdout
grep ' -o foo' stdout
$EGREP '(CC|LD) ' stdout && exit 1

:
