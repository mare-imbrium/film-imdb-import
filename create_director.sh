#!/usr/bin/env bash
COMM=$( brew --prefix sqlite)/bin/sqlite3
$COMM --version
MYDATABASE=movie.sqlite
MYTABLE=director
INFILE=/Users/rahul/Downloads/imdb_data/directors.tsv

echo creating table $MYTABLE
$COMM $MYDATABASE << !
DROP TABLE $MYTABLE ;

CREATE TABLE $MYTABLE (
	name VARCHAR, 
	newname VARCHAR
);
!
./import_table.sh $MYTABLE $INFILE || exit
echo "$MYTABLE Imported"
echo creating index - cannot create unique index since duplicates exist with different cases

echo "CREATE INDEX ${MYTABLE}_name on $MYTABLE(name COLLATE NOCASE);"
echo "CREATE INDEX ${MYTABLE}_newname on $MYTABLE(newname COLLATE NOCASE);"
$COMM $MYDATABASE << !
CREATE INDEX ${MYTABLE}_name on $MYTABLE(name COLLATE NOCASE);
CREATE INDEX ${MYTABLE}_newname on $MYTABLE(newname COLLATE NOCASE);
!
echo Done
echo "Running one or two checks ..."
$COMM $MYDATABASE << !
 select count(1) from $MYTABLE;
     select * from $MYTABLE where name = "Hitchcock, Alfred (I)";
     select * from $MYTABLE where newname = "Alfred Hitchcock";
     select * from $MYTABLE where name LIKE  "Deford, Randy";
!
