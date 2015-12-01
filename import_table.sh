#!/usr/bin/env bash

COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
MYTABLE="$1"
INFILE="$2"
[[ -z "$MYTABLE" ]] && { echo "Error: TABLE blank." 1>&2; exit 1; }

if [[ ! -f "$INFILE" ]]; then
    echo "File: $INFILE not found"
    exit 1
fi
echo "Importing data from $INFILE into table $MYTABLE"
echo
echo -n "checking if $INFILE sorted"
sort --check $INFILE
if [  $? -eq 0 ]; then
    echo "   okay"
else
    echo "   failed"
    echo "Please sort input file"
    exit 1
fi

MYDATABASE="movie.sqlite"

echo "Importing $MYTABLE in $MYDATABASE "


$COMM $MYDATABASE << !
delete from $MYTABLE;

.headers off
.mode tabs
.import $INFILE $MYTABLE
!
echo "$MYTABLE Imported"
$COMM $MYDATABASE << !
 select count(1) from $MYTABLE;
!
wc -l $INFILE
