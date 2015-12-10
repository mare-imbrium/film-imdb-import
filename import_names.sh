#!/usr/bin/env bash
COMM=$(brew --prefix sqlite)/bin/sqlite3

$COMM --version
MYTABLE="actor"
INFILE="/Users/rahul/Downloads/imdb_data/names.tsv"

if [[ ! -f "$INFILE" ]]; then
    echo "File: $INFILE not found"
    exit 1
fi
echo "importing data of actors and actresses from $INFILE into table $MYTABLE"
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

echo "Creating $MYDATABASE "


$COMM $MYDATABASE << !
DROP TABLE $MYTABLE;

CREATE TABLE $MYTABLE (
	name VARCHAR, 
	newname VARCHAR,
    gender CHAR(1)
);
.headers off
.mode tabs
.import $INFILE $MYTABLE
!
echo "$MYTABLE Imported"
echo "Creating index on name -- ideally should be UNIQUE but original data has errors preventing unique nocase index"
$COMM $MYDATABASE << !
CREATE INDEX actor_name on actor(name COLLATE NOCASE);
!
echo "Creating index on newname"
$COMM $MYDATABASE << !
CREATE INDEX actor_newname on actor(newname COLLATE NOCASE);
!
echo "Running one or two checks ..."
$COMM $MYDATABASE << !
 select count(1) from $MYTABLE;
     select * from $MYTABLE where name = "Tracy, Spencer (I)";
     select * from $MYTABLE where newname = "Dharmendra";
!
echo "Checking for duplicate names (ignoring case)"
echo "These are errors in the original data"
$COMM $MYDATABASE << !
     select name, count(1) from actor group by upper(name) having count(1) > 1;
!

wc -l $INFILE
