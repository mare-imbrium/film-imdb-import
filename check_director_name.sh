#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: ./check_director_name.sh
# 
#         USAGE: ./check_director_name.sh "Tracy, Spencer (I)"
# 
#   DESCRIPTION: Tries to find director by name supplied. First checks name, then reverses and checks against newname.
#                Then adds (I) and sees if match. Then uses LIKE to check both name and newname
#                If name ends with '*' then uses GLOB.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/05/2015 19:51
#      REVISION:  2015-12-07 00:15
#===============================================================================

set -o nounset                              # Treat unset variables as an error
name=

if [  $# -eq 0 ]; then
    echo "Error: director name required in Lastname, Firstname format" 1>&2
    exit 1
else
    name="$*"
fi
#echo "Got name : $name" 1>&2
ORIGNAME=$name
SQLITE=$(brew --prefix sqlite)/bin/sqlite3

if [[ "${name: -1}" == '*' ]]; then
    name=$( $SQLITE movie.sqlite "select name from director where name GLOB \"$name\";")
    if [[ -n "$name" ]]; then
        echo "$name"
        exit 0
    fi
    exit 1
fi
# exact search
count=$( $SQLITE movie.sqlite "select count(1) from director where name = \"$name\";")

if [[ $count -eq 1 ]]; then
    echo "$name";
    exit 0
fi
# switch last and first and check newname, if name already in newname format then okay
newname=$( echo "$name" | sed "s/^\([^,]*\), *\(.*\)/\2 \1/")
#echo "trying with $newname"
count=$( $SQLITE movie.sqlite "select count(1) from director where newname = \"$newname\";")
if [[ $count -eq 1 ]]; then
    name=$( $SQLITE movie.sqlite "select name from director where newname = \"$newname\";")
    echo "$name"
    exit 0
elif [[ $count -gt 1 ]]; then
    #echo "More than one by newname"
    name=$( $SQLITE movie.sqlite "select name from director where newname = \"$newname\";")
    echo "$name"
    exit $count
fi
#echo "checking after adding (I)"
countname="$ORIGNAME (I)"
count=$( $SQLITE movie.sqlite "select count(1) from director where name = \"$countname\";")

if [[ $count -eq 1 ]]; then
    name=$( $SQLITE movie.sqlite "select name from director where name = \"$countname\";")
    echo "$name";
    exit 0
elif [[ $count -gt 1 ]]; then
    echo "MORE THAN ONE IN (I) CASE" 1>&2
    name=$( $SQLITE movie.sqlite "select name from director where name = \"$countname\";")
    echo "$name";
    exit 99
fi
# last ditch 2015-12-06 - indexes are nocase so lets try like
#echo trying nocase like. esp useful if user enters in lower case or doesn't know case of middle name
names=$( $SQLITE movie.sqlite "select name from director where newname LIKE \"$ORIGNAME\" OR name LIKE \"$ORIGNAME\";")
leni=$( echo -e "${names}" | grep -c . )
if (( $leni > 0 )); then
    echo "$names"
    exit 0
fi
names=$( $SQLITE movie.sqlite "select name from ascii_director where ascii_newname LIKE \"$ORIGNAME\" OR ascii_name LIKE \"$ORIGNAME\";")
leni=$( echo -e "${names}" | grep -c . )
if (( $leni > 0 )); then
    echo "$names"
    exit 0
fi
exit 1
