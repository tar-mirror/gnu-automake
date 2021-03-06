#! /bin/sh
# Copyright (C) 2006-2012 Free Software Foundation, Inc.
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

# Test how well 'missing' finds output file names of various tools.
# PR automake/483.

am_create_testdir=empty
. ./defs || exit 1

get_shell_script missing

# These programs may be invoked by 'missing'.
needed_tools='chmod find sed test touch'
needed_tools_csep=$(echo $needed_tools | sed 's/ /, /g')

cat >configure.ac <<EOF
AC_INIT([missing4], [1.0])
m4_foreach([tool], [$needed_tools_csep],
	   [AC_PATH_PROG(tool, tool, [false])
	    AC_CONFIG_FILES(tool, chmod +x tool)
	   ])
AC_OUTPUT
EOF

for tool in $needed_tools; do
  unindent >$tool.in <<EOF
    #! /bin/sh
    exec @$tool@ "\$@"
EOF
done

$AUTOCONF
./configure

echo output-file > output-file
cp output-file my--output--file-o

save_PATH=$PATH
PATH=.
export PATH
missing --help
missing --version
for tool in autom4te help2man makeinfo; do
  missing --run $tool -o my--output--file-o input
  missing --run $tool --output my--output--file-o input
done
PATH=$save_PATH
export PATH
diff output-file my--output--file-o
test ! -e ./--file-o
test ! -e input
