#!/usr/bin/env bash
source ~/bin/sh_colors.sh
# takes file and adds the year as last column so we can sort on year
pinfo "Removing rows that have ???? in year. How did they get in !!"
fgrep -v '(????' directors.topbilled.dbf | sponge directors.topbilled.dbf
pinfo "REmoving everything after the date as that is messing up 130K rows"
sed 's/\(([12][0-9][0-9][0-9])\).*$/\1/;s/\(([12][0-9][0-9][0-9]\/[IVXL]*)\).*$/\1/' directors.topbilled.dbf > directors.dbf
echo "NEXT TWO SHOULD MATCH ..."
wc -l directors.topbilled.dbf directors.dbf
grep -m 1 "Birdman:" directors.dbf
grep -m 1 "Babel (2006" directors.dbf
echo
echo enter
read
pinfo "Adding year at end of each record ... "
# BUG what about cases where the year has /I in it they are lost
# Birdman: and Babel (2006/I) are lost.
# Also in many cases year is not at end, there is other stuff in bracket like Birdman
#sed  's/(\(....\))$/(\1)	\1/' directors.topbilled.dbf > directors.dbf
sed  's/(\([12][[0-9][0-9][0-9]\))/(\1)	\1/;s/(\([12][[0-9][0-9][0-9]\)\(\/[IVXL]*\))/(\1\2)	\1/' directors.dbf | sponge directors.dbf
echo "NEXT TWO SHOULD MATCH ..."
wc -l directors.topbilled.dbf directors.dbf
ct1=$( wc -l directors.topbilled.dbf | cut -f1 -d' ')
ct2=$( wc -l directors.dbf | cut -f1 -d' ')
if [[ $ct1 -ne $ct2 ]]; then
    i=$((ct1 - ct2))
    echo -e "Mismatch in number of lines." 1<&2
    echo -e "Mismatch $i lines." 1<&2
else
    echo "Both contain same number of lines. $ct1 and $ct2."
fi
noyear=$( grep -v '[12][0-9][0-9][0-9]$' movie_directors.tsv | wc -l )
grep -v '[12][0-9][0-9][0-9]$' movie_directors.tsv | head
echo "$noyear rows don't have year at end !!!"
echo enter
read
pdone 
head  directors.dbf
pinfo "Switching columns: Movie, director, year"
# WHY are we switching, since we always search by director
#awk -F$'\t' '{ print $2, $1, $3; }' OFS=$'\t' directors.dbf > t.t
cp directors.dbf t.t
#pdone
#head t.t
#pinfo "Sorting on movie ..."
#sort -k1 -t'	' t.t > t.tt
#pdone Sorting complete on movie
pinfo "Sorting on director ..."
sort -k1 -t'	' t.t > t.tt
pdone "Sorting finished on director name"
look "Hitchcock, Alfred" t.tt
echo ...
echo "grepping for Babel which was (2006/I)"
grep "Babel (2006" t.tt
echo
echo "Looking for Birdman: which has some bracketed text at end after date"
grep "Birdman:" t.tt
echo ...
look "González Iñárritu, Alejandro" t.tt

mv t.tt movie_directors.tsv
look "Ozu, Y" movie_directors.tsv
wc -l movie_directors.tsv
ct3=$( wc -l movie_directors.tsv | cut -f1 -d' ')
echo 
echo "rows in original was $ct1 , Final has $ct3 "
echo
echo checking for rows that do not have year at end
noyear=$( grep -v '[12][0-9][0-9][0-9]$' movie_directors.tsv | wc -l )
echo "$noyear rows don't have year at end !!!"

if [[ $noyear -gt 0 ]]; then
    grep -v '[12][0-9][0-9][0-9]$' movie_directors.tsv | head
    echo "Errors in data, pls correct before importing"
else
    echo pls import into sqlite using ./import_movie_directors.sh
fi
