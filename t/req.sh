#! /bin/sh
# Copyright (C) 1996-2012 Free Software Foundation, Inc.
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

# Test to make sure macro used in m4 file is included.

. ./defs || exit 1

cat > configure.ac <<EOF
AC_INIT
AM_INIT_GUILE_MODULE
EOF

cat > acinclude.m4 << 'END'
AC_DEFUN([AM_INIT_GUILE_MODULE],[
. $srcdir/../GUILE-VERSION
AM_INIT_AUTOMAKE($PACKAGE, $VERSION)
AC_CONFIG_AUX_DIR(..)
module=[$1]
AC_SUBST(module)])
END

$ACLOCAL

grep 'DEFUN.*INIT_AUTOMAKE' aclocal.m4

:
