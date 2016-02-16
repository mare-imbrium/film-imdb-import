#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: fzcast.sh 
# 
#         USAGE: fzcast.sh [pattern]
# 
#   DESCRIPTION: prints cast of movie from the large imdb dataset (imported into movie.sqlite).
#                Allows fuzzy selection using fzf. 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/25/2015 15:23
#      REVISION:  2015-12-25 19:32
#===============================================================================

SQLITE=$(brew --prefix sqlite)/bin/sqlite3

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/dataset || exit 1

STR=$($SQLITE movie.sqlite "SELECT title from movie;" | fzf --query="$1" -1 -0 )
[[ -z "$STR" ]] && { echo "Nothing selected, quitting." 1>&2; exit 1; }
echo $STR
./cast.sh "$STR"
