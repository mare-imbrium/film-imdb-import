#!/usr/bin/env bash
COMM=$(brew --prefix sqlite)/bin/sqlite3
$COMM --version
MYTABLE="movie_director"
# tsv file was created by addyear.sh
INFILE="movie_directors.tsv"

if [ $# -eq 0 ]; then 
    MYDATABASE="movie.sqlite"
else
    MYDATABASE="$1"
fi

echo "Importing movie-director association data into $MYDATABASE $MYTABLE "
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



echo "Importing data ..."
$COMM $MYDATABASE << !
DROP TABLE $MYTABLE;

CREATE TABLE $MYTABLE (
	name VARCHAR, 
	title VARCHAR, 
	year INTEGER
);
.headers off
.mode tabs
.import movie_directors.tsv $MYTABLE
!
echo "$MYTABLE Imported"
echo
echo "Creating indexes on name and year..."
sqlite3 $MYDATABASE << !
    CREATE INDEX ${MYTABLE}_name on $MYTABLE(name COLLATE NOCASE);
    CREATE INDEX ${MYTABLE}_year on $MYTABLE(year COLLATE NOCASE);
!
echo done
sqlite3 $MYDATABASE << !
 select count(1) from $MYTABLE;
 select * from movie_director where name like "Gonz_lez I__rritu, Alejandro" order by year;
!
wc -l $INFILE
