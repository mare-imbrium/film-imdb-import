#!/usr/bin/env bash
COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
MYDATABASE=movie.sqlite
MYTABLE=movies
INFILE=movies.list.new

echo creating table $MYTABLE
$COMM $MYDATABASE << !
CREATE TABLE $MYTABLE (
	title VARCHAR, 
    year integer
);
!
./import_table.sh $MYTABLE $INFILE
