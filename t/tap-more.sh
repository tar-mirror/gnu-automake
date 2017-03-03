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

# More on TAP support:
#  - more than one TAP-generating test script in $(TESTS)
#  - VPATH builds
#  - use with parallel make (if supported)
#  - basic use of diagnostic messages (lines beginning with "#")
#  - flags for TAP driver defined through AC_SUBST in configure.ac
#  - messages generated by the testsuite harness reference the
#    correct test script(s)
#  - "make distcheck" works

. ./defs || Exit 1

fetch_tap_driver

cat >> configure.ac <<END
AC_SUBST([AM_TEST_LOG_DRIVER_FLAGS], ['--comments'])
AC_OUTPUT
END

cat > Makefile.am << 'END'
TEST_LOG_DRIVER = $(srcdir)/tap-driver
TESTS = 1.test 2.test 3.test
EXTRA_DIST = $(TESTS) tap-driver
END

cat > 1.test <<'END'
#! /bin/sh
echo 1..2
echo ok 1 - mu
if test -f not-skip; then
  echo "not ok 2 zardoz"
else
  echo "ok 2 zardoz # SKIP"
fi
END

cat > 2.test <<'END'
#! /bin/sh
echo 1..3
echo "ok"
echo "not ok # TODO not implemented"
echo "ok 3"
END

cat > 3.test <<END
#! /bin/sh
echo 1..1
echo ok - blah blah blah
echo '# Some diagnostic'
if test -f bail-out; then
  echo 'Bail out! Kernel Panic'
else
  :
fi
END

chmod a+x [123].test

$ACLOCAL
$AUTOCONF
$AUTOMAKE

# Try a VPATH and by default serial build first, and then an in-tree
# and by default parallel build.
for try in 0 1; do

  if test $try -eq 0; then
    # VPATH serial build.
    mkdir build
    cd build
    srcdir=..
    run_make=$MAKE
  elif test $try -eq 1; then
    # In-tree parallel build.
    srcdir=.
    case $MAKE in
      *\ -j*)
        # Degree of parallelism already specified by the user: do
        # not override it.
        run_make=$MAKE
        ;;
      *)
        # Some make implementations (e.g., HP-UX) don't grok '-j',
        # some require no space between '-j' and the number of jobs
        # (e.g., older GNU make versions), and some *do* require a
        # space between '-j' and the number of jobs (e.g., Solaris
        # dmake).  We need a runtime test to see what works.
        echo 'all:' > Makefile
        for run_make in "$MAKE -j3" "$MAKE -j 3" "$MAKE"; do
          $run_make && break
        done
        rm -f Makefile
        ;;
    esac
  else
    fatal_ "internal error, invalid value of '$try' for \$try"
  fi

  $srcdir/configure
  ls -l # For debugging.

  # Success.

  # Use append mode here to avoid dropping output.  See automake bug#11413.
  # Also, use 'echo' here to "nullify" the previous contents of 'stdout',
  # since Solaris 10 /bin/sh would try to optimize a ':' away after the
  # first iteration, even if it is redirected.
  echo " " >stdout
  $run_make check >>stdout || { cat stdout; Exit 1; }
  cat stdout
  count_test_results total=6 pass=4 fail=0 xpass=0 xfail=1 skip=1 error=0
  grep '^PASS: 1\.test 1 - mu$' stdout
  grep '^SKIP: 1\.test 2 zardoz # SKIP$' stdout
  test `$FGREP -c '1.test' stdout` -eq 2
  grep '^PASS: 2\.test 1$' stdout
  grep '^XFAIL: 2\.test 2 # TODO not implemented$' stdout
  grep '^PASS: 2\.test 3$' stdout
  test `$FGREP -c '2.test' stdout` -eq 3
  grep '^PASS: 3\.test 1 - blah blah blah$' stdout
  grep '^# 3\.test: Some diagnostic$' stdout
  test `$FGREP -c '3.test' stdout` -eq 2

  # Failure.

  # Use 'echo' here, since Solaris 10 /bin/sh would try to optimize
  # a ':' away after the first iteration, even if it is redirected.
  echo dummy > not-skip
  echo dummy > bail-out
  # Use append mode here to avoid dropping output.  See automake bug#11413.
  # Also, use 'echo' here to "nullify" the previous contents of 'stdout',
  # since Solaris 10 /bin/sh would try to optimize a ':' away after the
  # first iteration, even if it is redirected.
  echo " " >stdout
  $run_make check >>stdout && { cat stdout; Exit 1; }
  cat stdout
  count_test_results total=7 pass=4 fail=1 xpass=0 xfail=1 skip=0 error=1
  grep '^PASS: 1\.test 1 - mu$' stdout
  grep '^FAIL: 1\.test 2 zardoz$' stdout
  test `$FGREP -c '1.test' stdout` -eq 2
  grep '^PASS: 2\.test 1$' stdout
  grep '^XFAIL: 2\.test 2 # TODO not implemented$' stdout
  grep '^PASS: 2\.test 3$' stdout
  test `$FGREP -c '2.test' stdout` -eq 3
  grep '^PASS: 3\.test 1 - blah blah blah$' stdout
  grep '^# 3\.test: Some diagnostic$' stdout
  grep '^ERROR: 3\.test - Bail out! Kernel Panic$' stdout
  test `$FGREP -c '3.test' stdout` -eq 3

  cd $srcdir

done

$MAKE distcheck

:
