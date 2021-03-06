#!/usr/bin/env bash

COMM=$(brew --prefix sqlite)/bin/sqlite3

$COMM --version
MYTABLE="cast"
echo "Updating $MYTABLE with data of movie and actors / actresses association from IMDB data files"
echo
echo -n "checking if movie_cast.tsv sorted"
sort --check movie_cast.tsv
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
	title VARCHAR, 
	billing INTEGER, 
	name VARCHAR, 
	character VARCHAR
);
.headers off
.mode tabs
.import movie_cast.tsv $MYTABLE
!
echo "$MYTABLE Imported"
sqlite3 $MYDATABASE << !
 select count(1) from $MYTABLE;
!
echo "Creating index on title"
sqlite3 $MYDATABASE << !
CREATE INDEX ${MYTABLE}_title on $MYTABLE(title) ;
!
echo "Creating index on name"
sqlite3 $MYDATABASE << !
CREATE INDEX ${MYTABLE}_name on $MYTABLE(name) ;
!
wc -l movie_cast.tsv

