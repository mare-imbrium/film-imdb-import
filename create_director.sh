#!/usr/bin/env bash
COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
MYDATABASE=movie.sqlite
MYTABLE=director
INFILE=/Users/rahul/Downloads/imdb_data/directors.tsv

echo creating table $MYTABLE
$COMM $MYDATABASE << !
CREATE TABLE $MYTABLE (
	name VARCHAR, 
	newname VARCHAR
);
!
./import_table.sh $MYTABLE $INFILE || exit
echo creating unique index

echo "CREATE UNIQUE INDEX ${MYTABLE}_name on $MYTABLE(name);"
$COMM $MYDATABASE << !
CREATE UNIQUE INDEX ${MYTABLE}_name on $MYTABLE(name);
!
echo Done
