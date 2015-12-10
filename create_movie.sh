#!/usr/bin/env bash
COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
echo "WARNING !!!"
echo "This must be run after movie_cast.tsv and movie.tsv has been generated"
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
$COMM $MYDATABASE <<!
    CREATE INDEX ${MYTABLE}_title on $MYTABLE(title COLLATE NOCASE);
    CREATE INDEX ${MYTABLE}_baretitle on $MYTABLE(baretitle COLLATE NOCASE);
!
echo checking ...
$COMM $MYDATABASE <<!
   select count(1) from $MYTABLE ;
       select * from $MYTABLE where title GLOB "Casablanca *";
       select * from $MYTABLE where baretitle = "Herz aus Glas";
       select * from $MYTABLE where baretitle = "Casablanca";
       select * from $MYTABLE where baretitle = "Life of Pi";
!

wc -l $INFILE
