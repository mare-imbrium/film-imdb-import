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
#      REVISION:  2015-12-17 19:29
#===============================================================================

OPT_VERBOSE=
OPT_DEBUG=
OPT_BRIEF=
MY_COL="c.title, c.billing, c.character"
while [[ $1 = -* ]]; do
    case "$1" in
        -b|--brief)   shift
            OPT_BRIEF=1
            MY_COL="c.title"
            ;;
        -l|--long)   shift
            OPT_LONG=1
            MY_COL="c.title, c.billing, c.character"
            ;;
        --by-year)   shift
            OPT_ORDERED=1
            ;;
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -h|--help)
            cat <<-!
		$0 Version: 1.0 Copyright (C) 2015 jkepler
		Prints movies for an actor, sorted by year.
        -b | --brief   prints only title
        -l | --long    prints title, billing, character
        --by-year ordered by year. This listing takes time.
!
            # no shifting needed here, we'll quit!
            exit
            ;;
        --source)
            echo "this is to edit the source "
            vim $0
            exit
            ;;
        *)
            echo "Error: Unknown option: $1" >&2   
            echo "Use -h or --help for usage" 1>&2
            exit 1
            ;;
    esac
done

if [  $# -eq 0 ]; then
    echo "Error: Actor name required in Lastname, Firstname format" 1>&2
    exit 1
fi

SQLITE=$(brew --prefix sqlite)/bin/sqlite3

if [[ -z "$OPT_ORDERED" ]]; then
$SQLITE movie.sqlite <<!
.mode tabs
SELECT 
$MY_COL
FROM cast c
WHERE 
c.name = "$*"
;
!
else
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
fi
