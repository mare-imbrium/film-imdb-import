#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: mtest.sh
# 
#         USAGE: ./mtest.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/02/2015 23:40
#      REVISION:  2015-12-04 15:55
#===============================================================================

set -o nounset                              # Treat unset variables as an error

source ~/bin/sh_colors.sh
APPNAME=$( basename $0 )
ext=${1:-"default value"}
today=$(date +"%Y-%m-%d-%H%M")
curdir=$( basename $(pwd))
export TAB=$'\t'

pline() {
    pdone "---------- -------------- ------ ------------ "
}
source ./movieutil.sh

T="Casablanca (1942)"
pinfo "title_equals $T ================== "
title_equals $T 
pline

T="Casablanca"
pinfo "title_equals $T ================== "
title_equals $T 
pline

T="Casablanca"
pinfo "title_starting $T ================== "
title_starting $T 
pline

T="Casablanca"
pinfo "title_containing $T ================== "
title_containing $T 
pline

N="Puri, Om"
pinfo "name_equals $N"
name_equals "$N"
pline
N="Tracy, Spencer"
pinfo "name_equals $N"
name_equals "$N"
pline
N="Fonda"
pinfo name_starting $N
name_starting $N
echo
pline
N="Tracy, Spencer"
pinfo name_starting $N
name_starting $N

pline
N="Om Puri"
pinfo "altname_equals $N"
altname_equals $N
pline
N="Spencer Tracy"
pinfo "altname_equals $N"
altname_equals $N
pline
N="Olivier, Laurence"
pinfo "name_equals $N================== "
name_equals $N
pinfo "movies_of_actor $N================== "
movies_of_actor $N

pline
N="Casablanca (1942)"
pinfo "movie_cast_exact "$N""
movie_cast_exact "$N"| column -t -s$'\t'
pline 
pinfo "title_containing "Where the Red Fern Grows""
title_containing "Where the Red Fern Grows"
pline
N="Where the Red Fern Grows (1974)"
pinfo "movie_cast_exact "$N""
#movie_cast_exact "$N" | column -t -s$'\t'
#movie_cast_exact "$N" | column -t -s,
movie_cast_exact --headers on --columns "name,character,billing" "$N" | csvlook --tabs 

pline
D="Kubrick"
pinfo "director_last_name_equals $D ================== "
director_last_name_equals $D
D="Kubrick, Stanley"
pinfo "director_name_equals $D================== "
director_name_equals "$D"
pinfo "movies_of_director $D ================== "
movies_of_director "$D"
