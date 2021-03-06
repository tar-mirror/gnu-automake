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

# Test more basic functionalities of the 'py-compile' script, with
# dummy python sources, but more complex directory layouts.  See also
# related test 'py-compile-basic.sh'.

required=python
. ./defs || exit 1

ocwd=$(pwd) || fatal_ "getting current working directory"

pyfiles="
  foo.py
  ./foo1.py
  ../foo2.py
  ../dir/foo3.py
  $ocwd/foo4.py
  sub/bar.py
  sub/subsub/barbar.py
  __init__.py
  sub/__init__.py
  1.py
  .././_.py
"

lst='
  dir/foo
  dir/foo1
  foo2
  dir/foo3
  foo4
  dir/sub/bar
  dir/sub/subsub/barbar
  dir/__init__
  dir/sub/__init__
  dir/1
  _
'

mkdir dir
cd dir
cp "$am_scriptdir/py-compile" . \
  || fatal_ "failed to fetch auxiliary script py-compile"
mkdir sub sub/subsub
touch $pyfiles
./py-compile $pyfiles
cd "$ocwd"

for x in $lst; do echo $x.pyc; echo $x.pyo; done | sort > exp
find . -name '*.py[co]' | sed 's|^\./||' | sort > got

cat exp
cat got
diff exp got

:
