#!/usr/bin/env bash
COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
MYDATABASE=movie.sqlite
MYTABLE=dirs
INFILE=/Users/rahul/Downloads/imdb_data/directors.tsv

echo creating table $MYTABLE
$COMM $MYDATABASE << !
CREATE TABLE $MYTABLE (
	name VARCHAR, 
	newname VARCHAR
);
!
./import_table.sh $MYTABLE $INFILE
