#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: fzdir.sh
# 
#         USAGE: ./fzdir.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/25/2015 15:23
#      REVISION:  2016-01-03 19:48
#===============================================================================

SQLITE=$(brew --prefix sqlite)/bin/sqlite3

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/dataset || exit 1

STR=$($SQLITE movie.sqlite "SELECT name from director;" | fzf --query="$1" -1 -0 )
[[ -z "$STR" ]] && { echo "Nothing selected, quitting." 1>&2; exit 1; }
echo -e "$STR" 1<&2
movies_of_director.sh "$STR"
