#!/usr/bin/env bash
COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
echo "WARNING !!!"
echo "This must be run after movie_cast.tsv and movie.tsv has been generated"
# movie,tsv was created by create_movie_list.sh in imdb_data.
echo
MYDATABASE=movie.sqlite
MYTABLE=movie
# egrep -v '^"|\(TV\)|\(V\)|\(VG\)' movies.list.utf-8 > movies.list.new
# However, it has every movie in it, even those for which we have no cast
# So i now take movies from movie_cast.tsv, I still repeat the year at end without brackets
#cut -f1 movie_cast.tsv | sort -u | gsed 's/(\([0-9]\{4\}\))$/(\1)	\1/' > movie.list
INFILE=/Users/rahul/Downloads/imdb_data/movie.tsv

echo creating table $MYTABLE
$COMM $MYDATABASE <<!
DROP TABLE $MYTABLE;

CREATE TABLE $MYTABLE (
	title VARCHAR, 
    year integer,
    baretitle VARCHAR
);
!
./import_table.sh $MYTABLE $INFILE || exit 1
echo $MYTABLE imported

echo creating indexes on title and baretitle
# index on year is needed since we print movies of an actor sorted on year
$COMM $MYDATABASE <<!
    CREATE INDEX ${MYTABLE}_title on $MYTABLE(title COLLATE NOCASE);
    CREATE INDEX ${MYTABLE}_baretitle on $MYTABLE(baretitle COLLATE NOCASE);
    CREATE INDEX ${MYTABLE}_year on $MYTABLE(year);
!

echo checking ...
$COMM $MYDATABASE <<!
   select count(1) from $MYTABLE ;
       select * from $MYTABLE where title GLOB "Casablanca *";
       select * from $MYTABLE where baretitle = "Herz aus Glas";
       select * from $MYTABLE where baretitle = "Casablanca";
       select * from $MYTABLE where baretitle = "Life of Pi";
           select * from $MYTABLE where title = "Babel (2006/I)";
           select * from $MYTABLE where title LIKE "Birdman: %";
!
echo checking for blank year
$COMM $MYDATABASE <<!
   select count(1) from $MYTABLE where year = "";
!

wc -l $INFILE
