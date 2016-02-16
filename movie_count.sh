#!/usr/bin/env bash 


SQLITE=$(brew --prefix sqlite)/bin/sqlite3

$SQLITE movie.sqlite <<!
.timer on
.mode tabs
SELECT 
    name, count(1)
    from cast
    where billing = 1
    group by name
    having count(1) > 30
    ;
!
