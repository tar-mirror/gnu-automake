#! /bin/sh
# Copyright (C) 2010-2013 Free Software Foundation, Inc.
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

# Test for regressions in computation of names of .Po files for
# automatic dependency tracking.
# Keep this in sync with sister test 'depcomp8b.sh', which checks the
# same thing for libtool objects.

required=cc
. test-init.sh

cat >> configure.ac << 'END'
AC_PROG_CC
#x AM_PROG_CC_C_O
AC_OUTPUT
END

cat > Makefile.am << 'END'
bin_PROGRAMS = zardoz
zardoz_SOURCES = foo.c sub/bar.c
END

mkdir sub
cat > foo.c << 'END'
int main (void)
{
  extern int bar (void);
  return bar ();
}
END
cat > sub/bar.c << 'END'
int bar (void)
{
  return 0;
}
END

$ACLOCAL
$AUTOMAKE -a
grep include Makefile.in # For debugging.
grep 'include.*\./\$(DEPDIR)/foo\.P' Makefile.in
grep 'include.*\./\$(DEPDIR)/bar\.P' Makefile.in
grep 'include.*/\./\$(DEPDIR)' Makefile.in && exit 1

$AUTOCONF
# Don't reject slower dependency extractors, for better coverage.
./configure --enable-dependency-tracking
$MAKE
cross_compiling || ./zardoz
DISTCHECK_CONFIGURE_FLAGS='--enable-dependency-tracking' $MAKE distcheck

# Try again with subdir-objects option.

sed 's/#x //' configure.ac >configure.tmp
mv -f configure.tmp configure.ac
echo AUTOMAKE_OPTIONS = subdir-objects >> Makefile.am

$ACLOCAL
$AUTOMAKE -a
grep include Makefile.in # For debugging.
grep 'include.*\./\$(DEPDIR)/foo\.P' Makefile.in
grep 'include.*[^a-zA-Z0-9_/]sub/\$(DEPDIR)/bar\.P' Makefile.in
$EGREP 'include.*/(\.|sub)/\$\(DEPDIR\)' Makefile.in && exit 1

$AUTOCONF
# Don't reject slower dependency extractors, for better coverage.
./configure --enable-dependency-tracking
$MAKE
cross_compiling || ./zardoz
DISTCHECK_CONFIGURE_FLAGS='--enable-dependency-tracking' $MAKE distcheck

:
