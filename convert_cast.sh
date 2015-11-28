#!/usr/bin/env bash

COMM="/usr/local/Cellar/sqlite/3.9.2/bin/sqlite3"
$COMM --version
MYTABLE="cast"

if [ $# -eq 0 ]; then 
    MYDATABASE="movie.sqlite"
else
    MYDATABASE="$1"
fi

echo "Creating $MYDATABASE "


$COMM $MYDATABASE << !
CREATE TABLE $MYTABLE (
	title VARCHAR, 
	billing VARCHAR, 
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
exit 

function realthing() {
sqlite3 $MYDATABASE << !
CREATE TABLE cast (
	title VARCHAR, 
	billing VARCHAR, 
	name VARCHAR, 
	character VARCHAR
);
.headers off
.mode tabs
.import movie_cast.tsv cast
!
echo "cast Imported"
}
