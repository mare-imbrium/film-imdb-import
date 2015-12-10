#!/usr/bin/env bash
COMM=$(brew --prefix sqlite)/bin/sqlite3

$COMM --version
MYTABLE="ascii_director"
INFILE="/Users/rahul/Downloads/imdb_data/ascii_directors.tsv"

if [[ ! -f "$INFILE" ]]; then
    echo "File: $INFILE not found"
    exit 1
fi
echo "importing data of director from $INFILE into table $MYTABLE"
echo
echo -n "checking if $INFILE sorted"
sort --check $INFILE
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

echo "Creating $MYTABLE "


$COMM $MYDATABASE << !
DROP TABLE $MYTABLE;

CREATE TABLE $MYTABLE (
    ascii_name VARCHAR,
	ascii_newname VARCHAR,
	name VARCHAR
);
.headers off
.mode tabs
.import $INFILE $MYTABLE
!
echo "$MYTABLE Imported"
echo
echo "Creating index on name -- ideally should be UNIQUE but original data has errors preventing unique nocase index"
$COMM $MYDATABASE << !
CREATE INDEX ascii_director_ascii_name on ascii_director(ascii_name COLLATE NOCASE);
!
echo "Creating index on newname"
$COMM $MYDATABASE << !
CREATE INDEX ascii_director_ascii_newname on ascii_director(ascii_newname COLLATE NOCASE);
!
echo "Running one or two checks ..."
$COMM $MYDATABASE << !
 select count(1) from $MYTABLE;
     select * from $MYTABLE where ascii_name = "Gonzalez Inarritu, Alejandro";
     select * from $MYTABLE where ascii_newname = "Alejandro Gonzalez Inarritu";
     select * from $MYTABLE where ascii_newname = "Francois Truffaut";
     select * from $MYTABLE where ascii_newname = "Yasujiro Ozu";
!

wc -l $INFILE
