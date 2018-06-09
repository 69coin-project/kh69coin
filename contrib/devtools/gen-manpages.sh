#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

KH69COIND=${KH69COIND:-$SRCDIR/kh69coind}
KH69COINCLI=${KH69COINCLI:-$SRCDIR/kh69coin-cli}
KH69COINTX=${KH69COINTX:-$SRCDIR/kh69coin-tx}
KH69COINQT=${KH69COINQT:-$SRCDIR/qt/kh69coin-qt}

[ ! -x $KH69COIND ] && echo "$KH69COIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
69CVER=($($KH69COINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$KH69COIND --version | sed -n '1!p' >> footer.h2m

for cmd in $KH69COIND $KH69COINCLI $KH69COINTX $KH69COINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${69CVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${69CVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m