#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: ./check_actor_name.sh
# 
#         USAGE: ./check_actor_name.sh "Tracy, Spencer (I)"  => "Tracy, Spencer (I)"
#         USAGE: ./check_actor_name.sh "Spencer Tracy"   => "Tracy, Spencer (I)"
#         USAGE: echo "Spencer Tracy" | ./check_actor_name.sh --stdin "Spencer Tracy"   => "Tracy, Spencer (I)"
# 
#   DESCRIPTION: Tries to find actor by name supplied. First checks name, then reverses and checks against newname.
#                Then adds (I) and sees if match. Then uses LIKE to check both name and newname
#                If name ends with '*' then uses GLOB.
#
#                If --stdin supplied then takes name from STDIN 2015-12-24 
#                This is especially useful in a pipeline along with imdb.sh which uses normal format for name.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: rkumar
#  ORGANIZATION: 
#       CREATED: 12/05/2015 19:51
#      REVISION:  2015-12-07 00:15
#===============================================================================

set -o nounset                              # Treat unset variables as an error
name=
check() {
    ORIGNAME=$name
    SQLITE=$(brew --prefix sqlite)/bin/sqlite3

    if [[ "${name: -1}" == '*' ]]; then
        name=$( $SQLITE movie.sqlite "select name from actor where name GLOB \"$name\";")
        if [[ -n "$name" ]]; then
            echo "$name"
            exit 0
        fi
        exit 1
    fi
    count=$( $SQLITE movie.sqlite "select count(1) from actor where name = \"$name\";")

    if [[ $count -eq 1 ]]; then
        echo "$name";
        exit 0
    fi
    # switch last and first and check newname, if name already in newname format then okay
    newname=$( echo "$name" | sed "s/^\([^,]*\), *\(.*\)/\2 \1/")
    #echo "trying with $newname"
    count=$( $SQLITE movie.sqlite "select count(1) from actor where newname = \"$newname\";")
    if [[ $count -eq 1 ]]; then
        name=$( $SQLITE movie.sqlite "select name from actor where newname = \"$newname\";")
        echo "$name"
        exit 0
    elif [[ $count -gt 1 ]]; then
        #echo "More than one by newname"
        name=$( $SQLITE movie.sqlite "select name from actor where newname = \"$newname\";")
        echo "$name"
        exit $count
    fi
    #echo "checking after adding (I)"
    countname="$ORIGNAME (I)"
    count=$( $SQLITE movie.sqlite "select count(1) from actor where name = \"$countname\";")

    if [[ $count -eq 1 ]]; then
        name=$( $SQLITE movie.sqlite "select name from actor where name = \"$countname\";")
        echo "$name";
        exit 0
    elif [[ $count -gt 1 ]]; then
        echo "MORE THAN ONE IN (I) CASE" 1>&2
        name=$( $SQLITE movie.sqlite "select name from actor where name = \"$countname\";")
        echo "$name";
        exit 99
    fi
    # last ditch 2015-12-06 - indexes are nocase so lets try like
    #echo trying nocase like. esp useful if user enters in lower case or doesn't know case of middle name
    names=$( $SQLITE movie.sqlite "select name from actor where newname LIKE \"$ORIGNAME\" OR name LIKE \"$ORIGNAME\";")
    leni=$( echo -e "${names}" | grep -c . )
    if (( $leni > 0 )); then
        echo "$names"
        exit 0
    fi
    names=$( $SQLITE movie.sqlite "select name from ascii_actor where ascii_newname LIKE \"$ORIGNAME\" OR ascii_name LIKE \"$ORIGNAME\";")
    leni=$( echo -e "${names}" | grep -c . )
    if (( $leni > 0 )); then
        echo "$names"
        exit 0
    fi
    exit 1
}

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/dataset || exit 1
if [[ ! -f "movie.sqlite" ]]; then
    echo "File: movie.sqlite not found"
    exit 1
fi

if [  $# -eq 0 ]; then
    echo "Error: Actor name required in Lastname, Firstname format" 1>&2
    exit 1
fi
if [[ "$1" == "--stdin" ]]; then
    while IFS='' read name
    do
        check "$name"
    done 
else
    name="$*"
    check $name
fi
#echo "Got name : $name" 1>&2
