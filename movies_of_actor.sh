#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: movies_of_actor.sh
# 
#         USAGE: ./movies_of_actor.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/05/2015 19:51
#      REVISION:  2015-12-05 20:48
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [  $# -eq 0 ]; then
    echo "Error: Actor name required in Lastname, Firstname format" 1>&2
    exit 1
fi

SQLITE=$(brew --prefix sqlite)/bin/sqlite3

$SQLITE movie.sqlite <<!
.mode tabs
SELECT 
c.title,
c.billing,
c.character,
m.year
FROM cast c, movie m
WHERE c.title = m.title
AND
c.name = "$*"
order by m.year
;
!

