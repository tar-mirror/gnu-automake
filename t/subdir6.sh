#! /bin/sh
# Copyright (C) 2002-2012 Free Software Foundation, Inc.
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

# Test to make sure config headers in subdirectories are cleaned.

. ./defs || Exit 1

cat >> configure.ac << 'END'
AM_CONFIG_HEADER([sub/config.h:sub/config.hin])
AC_OUTPUT
END

touch Makefile.am
mkdir sub

$ACLOCAL
$AUTOCONF
touch sub/config.hin
$AUTOMAKE
./configure
test -f sub/stamp-h1
$MAKE clean
test -f sub/stamp-h1
$MAKE distclean
test -f sub/stamp-h1 && Exit 1

:
