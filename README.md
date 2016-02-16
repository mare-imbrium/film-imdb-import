# film-imdb-import

This contains programs to convert IMDB dataset into what can be
imported into sqlite.

-----------

The json database has english titles for movies not original jap ones.
whereas the imdb datafiles (e.g. directors) has the foriegn titles.
------------------------------------------------------------------------
# this one will take out the actors for a movie, print the actor and the
movie and role, take out the top nine appearances, and sort by
appearance
grep -o '^[^	]*	.*Shawshank Redemption (1994)[^	]*' actors.dat | awk -F'	' '{ print $1, $NF; }' | grep '<[1-9]>' | sed 's/ </ </' | sort -k2 -t'	'


For other information, we need to link json database with imdb one.

We have newname for actor and director,
we have baretitle in movie.

use check_movie_name to get a movie. it can also have a get_baretitle
for a title.
get newname for a name.
Then get title in json db.

possibly, for each title in json db we can look up baretitle in imdb
matching year and update some link table.


check_movie_name : maybe instead of the complex logic, be stupid and
clear.
--exact
--contains
--starts
--glob / regex

