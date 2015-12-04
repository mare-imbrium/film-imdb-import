#!/usr/bin/env bash

COMM="/usr/local/Cellar/sqlite/3.9.2/bin/sqlite3"
$COMM --version
MYTABLE="movie_director"
INFILE="movie_directors.tsv"

if [ $# -eq 0 ]; then 
    MYDATABASE="movie.sqlite"
else
    MYDATABASE="$1"
fi

echo "Imorting movie-director association data into $MYDATABASE $MYTABLE "
echo
echo -n "checking if $INFILE sorted"
sort --check movie_directors.tsv
if [  $? -eq 0 ]; then
    echo "   okay"
else
    echo "   failed"
    echo "Please sort input file"
    exit 1
fi



$COMM $MYDATABASE << !
CREATE TABLE $MYTABLE (
	title VARCHAR, 
	name VARCHAR, 
	year INTEGER
);
.headers off
.mode tabs
.import movie_directors.tsv $MYTABLE
!
echo "$MYTABLE Imported"
sqlite3 $MYDATABASE << !
 select count(1) from $MYTABLE;
!
wc -l $INFILE
