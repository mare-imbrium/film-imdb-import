#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: fzaka.sh 
# 
#         USAGE: fzaka.sh [pattern]
# 
#   DESCRIPTION: prints other titles of a movie from aka-titles table
#                Allows fuzzy selection using fzf. 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/25/2015 15:23
#      REVISION:  2015-12-25 20:09
#===============================================================================

SQLITE=$(brew --prefix sqlite)/bin/sqlite3

OPT_VERBOSE=
OPT_DEBUG=
OPT_REVERSE=
MYCOL1=title
MYCOL2=aka
while [[ $1 = -* ]]; do
    case "$1" in
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -r|--reverse)        shift
            OPT_REVERSE=1
            MYCOL1=aka
            MYCOL2=title
            ;;
        -h|--help)
            cat <<-!
            $0 Version: 0.0.0 Copyright (C) 2015 jkepler
            This program prints the other titles of a movie, useful for foreign movies.
!
            # no shifting needed here, we'll quit!
            exit
            ;;
        --edit)
            echo "this is to edit the file generated if any "
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

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/dataset || exit 1

STR=$($SQLITE movie.sqlite "SELECT ${MYCOL2} from aka_title;" | fzf --query="$1" -1 -0 )
[[ -z "$STR" ]] && { echo "Nothing selected, quitting." 1>&2; exit 1; }
echo "== $STR"
MYTABLE=aka_title
MYDATABASE=movie.sqlite
# movie director movie_director actor title directed_by starring name
if [[ -n "$OPT_DEBUG" ]]; then
    echo "select $MYCOL1 , type from $MYTABLE where $MYCOL2 = ${STR};"
fi
$SQLITE $MYDATABASE <<!
.mode tabs
  select $MYCOL1 , type from $MYTABLE where $MYCOL2 = "${STR}";
!
  #select $MYCOL1 , type from $MYTABLE where $MYCOL2 LIKE "${STR}%";
