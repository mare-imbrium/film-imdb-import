#!/usr/bin/env bash


if [ $# -eq 0 ]; then 
   MYDATABASE="movie.sqlite"
else
   MYDATABASE=$1
fi

echo "Creating $MYDATABASE"

sqlite3 $MYDATABASE << !

CREATE TABLE movie_actresses (
	title VARCHAR, 
	billing VARCHAR, 
	name VARCHAR, 
	character VARCHAR
);
.headers off
.mode tabs
.import movie_actresses.dbf movie_actresses
!
echo "actresses Imported"


CREATE TABLE movie_actor (
	title VARCHAR, 
	billing VARCHAR, 
	name VARCHAR, 
	character VARCHAR
);
.headers off
.mode tabs
.import movie_actors.dbf movie_actor
!
echo "actors Imported"
