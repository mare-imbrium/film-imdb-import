#!/usr/bin/env bash
COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
MYDATABASE=movie.sqlite
MYTABLE=aka_titles
INFILE=/Users/rahul/Downloads/imdb_data/aka-titles.tsv

echo creating table $MYTABLE
$COMM $MYDATABASE << !
CREATE TABLE $MYTABLE (
	title VARCHAR, 
	aka VARCHAR,
    type VARCHAR
);
!
./import_table.sh $MYTABLE $INFILE
