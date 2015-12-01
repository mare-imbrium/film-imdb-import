#!/usr/bin/env bash
COMM=$(brew --prefix sqlite)/bin/sqlite3

$COMM --version
MYTABLE="actor"
INFILE="/Users/rahul/Downloads/imdb_data/names.tsv"

if [[ ! -f "$INFILE" ]]; then
    echo "File: $INFILE not found"
    exit 1
fi
echo "importing data of actors and actresses from $INFILE into table $MYTABLE"
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

if [ $# -eq 0 ]; then 
    MYDATABASE="movie.sqlite"
else
    MYDATABASE="$1"
fi

echo "Creating $MYDATABASE "


$COMM $MYDATABASE << !
CREATE TABLE $MYTABLE (
	name VARCHAR, 
    offset integer,
    gender CHAR(1),
	newname VARCHAR
);
.headers off
.mode tabs
.import $INFILE $MYTABLE
!
echo "$MYTABLE Imported"
$COMM $MYDATABASE << !
 select count(1) from $MYTABLE;
!
wc -l $INFILE
