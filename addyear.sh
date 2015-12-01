#!/usr/bin/env bash
source ~/bin/sh_colors.sh
# takes file and adds the year as last column so we can sort on year
pinfo "Adding year at end of each record ... "
sed -n 's/(\(....\))$/(\1)	\1/p' directors.topbilled.dbf > directors.dbf

pdone 
head  directors.dbf
pinfo "Switching columns: Movie, director, year"
awk -F$'\t' '{ print $2, $1, $3; }' OFS=$'\t' directors.dbf > t.t
pdone
head t.t
pinfo "Sorting on movie ..."
sort -k1 -t'	' t.t > t.tt
pdone Sorting complete on movie
look "Casablanca" t.tt
echo ...
mv t.tt movie_directors.tsv
look "Hitori musuko" movie_directors.tsv
wc -l movie_directors.tsv
echo pls import into sqlite
