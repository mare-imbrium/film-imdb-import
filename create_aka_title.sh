#!/usr/bin/env bash
COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
MYDATABASE=movie.sqlite
MYTABLE=aka_title
INFILE=/Users/rahul/Downloads/imdb_data/aka-titles.tsv

echo creating table $MYTABLE
$COMM $MYDATABASE << !
DROP TABLE $MYTABLE ;

CREATE TABLE $MYTABLE (
	title VARCHAR, 
	aka VARCHAR,
    type VARCHAR
);
!
./import_table.sh $MYTABLE $INFILE
echo $MYTABLE imported
echo Creating indexes
$COMM $MYDATABASE << !
   CREATE INDEX ${MYTABLE}_title on ${MYTABLE}(title COLLATE NOCASE);
   CREATE INDEX ${MYTABLE}_aka on ${MYTABLE}(aka COLLATE NOCASE);
!
$COMM $MYDATABASE "SELECT COUNT(1) FROM $MYTABLE ; "
