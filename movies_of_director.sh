#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: movies_of_director.sh
# 
#         USAGE: ./movies_of_director.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: --detailed
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/05/2015 19:51
#      REVISION:  2015-12-26 12:33
#===============================================================================


movies_for() {
SQLITE=$(brew --prefix sqlite)/bin/sqlite3

if [[ -z "$OPT_DETAILED" ]]; then

$SQLITE movie.sqlite <<!
.mode tabs
SELECT 
d.title,
d.year
FROM movie_director d
WHERE 
d.name = "${name}"
order by d.year
;
!

else

$SQLITE movie.sqlite <<!
.mode tabs
SELECT 
d.title,
c.name,
d.year
FROM movie_director d,
cast c
WHERE 
c.title = d.title and
d.name = "${name}"
and c.billing = 1
order by d.year
;
!
fi
}

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/dataset || exit 1
if [[ ! -f "movie.sqlite" ]]; then
    echo "File: movie.sqlite not found"
    exit 1
fi

OPT_DETAILED=
while [[ $1 = -* ]]; do
    case "$1" in
        -d|--detailed)   shift
            OPT_DETAILED=1
            ;;
        --verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        --stdin)        shift
            OPT_STDIN=1
            ;;
        -h|--help)
            cat <<!
            $0 Version: 0.0.0 Copyright (C) 2012 rkumar
            Prints movies for a director sorted by year.
            If you use --detailed then the top billed actor is also printed.
            --stdin     takes director name from STDIN
!
            # no shifting needed here, we'll quit!
            exit
            ;;
        *)
            echo "Error: Unknown option: $1" >&2   # rem _
            echo "Use -h or --help for usage"
            exit 1
            ;;
    esac
done

if [[ -n "$OPT_STDIN" ]]; then
    while IFS='' read name
    do
        movies_for "$name"
    done 
    #echo "Error: Actor name required in Lastname, Firstname format" 1>&2
    exit 0
fi
if [  $# -eq 0 ]; then
    echo "Error: director name required in Lastname, Firstname format" 1>&2
    echo " In some cases, (I) may be required at end of name." 1>&2
    exit 1
fi
name="$*"
movies_for "$name"

