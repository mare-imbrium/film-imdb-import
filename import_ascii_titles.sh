#!/usr/bin/env bash
COMM=$(brew --prefix sqlite)/bin/sqlite3

$COMM --version
MYTABLE="ascii_aka_title"
# i thin we will put in ascii version of titles from both movies and aka-titles
MYTABLE="ascii_title"
INFILE="/Users/rahul/Downloads/imdb_data/ascii_titles.tsv"

if [[ ! -f "$INFILE" ]]; then
    echo "File: $INFILE not found"
    exit 1
fi
echo "importing data of ascii titles from $INFILE into table $MYTABLE"
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
    ascii_title VARCHAR,
	title VARCHAR
);
.headers off
.mode tabs
.import $INFILE $MYTABLE
!
echo "$MYTABLE Imported"
echo
echo "Creating index on name -- ideally should be UNIQUE but original data has errors preventing unique nocase index"
$COMM $MYDATABASE << !
CREATE INDEX ${MYTABLE}_ascii_title on $MYTABLE(ascii_title COLLATE NOCASE);
!
echo "Running one or two checks ..."
$COMM $MYDATABASE << !
 select count(1) from $MYTABLE;
     select * from $MYTABLE where ascii_title GLOB "Tokyo monogatari *";
         select * from $MYTABLE where ascii_title = "Bande a part (1964)";
!

wc -l $INFILE
