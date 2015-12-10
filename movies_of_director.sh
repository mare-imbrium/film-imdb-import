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
#      REVISION:  2015-12-05 21:07
#===============================================================================

set -o nounset                              # Treat unset variables as an error


opt_detailed=
while [[ $1 = -* ]]; do
    case "$1" in
        -d|--detailed)   shift
            opt_detailed=1
            ;;
        --debug)        shift
            opt_debug=1
            ;;
        -h|--help)
            cat <<!
            $0 Version: 0.0.0 Copyright (C) 2012 rkumar
            Prints movies for a director sorted by year.
            If you use --detailed then the top billed actor is also printed.
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

if [  $# -eq 0 ]; then
    echo "Error: director name required in Lastname, Firstname format" 1>&2
    echo " In some cases, (I) may be required at end of name." 1>&2
    exit 1
fi

SQLITE=$(brew --prefix sqlite)/bin/sqlite3

if [[ -z "$opt_detailed" ]]; then

$SQLITE movie.sqlite <<!
.mode tabs
SELECT 
d.title,
d.year
FROM movie_director d
WHERE 
d.name = "$*"
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
d.name = "$*"
and c.billing = 1
order by d.year
;
!
fi
