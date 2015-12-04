#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: movieutil.sh
# 
#         USAGE: ./movieutil.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/01/2015 12:50
#      REVISION:  2015-12-04 15:55
#===============================================================================

set -o nounset                              # Treat unset variables as an error
source ~/bin/sh_colors.sh
APPNAME=$( basename $0 )
ext=${1:-"default value"}
today=$(date +"%Y-%m-%d-%H%M")
curdir=$( basename $(pwd))
#set -euo pipefail # this makes a return 1 in a function to exit the subshell, like an exit
export TAB=$'\t'
#IFS=$'\n\t'

OPT_TEST=
ARG=${1:-"default value"}
if [[ "$ARG" == "--test" ]]; then
    OPT_TEST=1
    name=${2:-"Casablanca"}
fi
# contains various scripts to query movie database.
# To be sourced and used.
#

SQLITE=$(brew --prefix sqlite)/bin/sqlite3

MYDATABASE="movie.sqlite"

# returns one or zero rows for given movie title
# Maybe used to confirm a title.
title_equals ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: Please pass a title with year." 1>&2; return 1; }
    if grep -q "([12][0-9][0-9][0-9])$" <<< "$PATT"; then
        :
    else
        echo "Error: Title requires year in (1978) format" 1>&2; return 1; 
    fi

    MYTABLE="movie"
    MYCOL="title"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL = "${PATT}";
!
}	# ----------  end of function title_equals  ----------

if [[ -n "$OPT_TEST" ]]; then
    PATT="Casablanca"
    pinfo =====  checking title_equals with $PATT
    title_equals "$PATT"
    echo
    PATT="Casablanca (1942)"
    pinfo =====  checking title_equals with $PATT
    title_equals "$PATT"
fi

# this searches for given string anywhere in titles
# returns zero or many rows.
title_containing ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="movie"
    MYCOL="title"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL like "%${PATT}%";
!
}	# ----------  end of function title_containing  ----------

# this one matches from the start but assumes the title is exact, only year is not known.
# NOTE: Year should NOT be mentioned,
# returns zero, or >=1  rows.
title_starting ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="movie"
    MYCOL="title"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL like "${PATT} (%";
!
}	# ----------  end of function title_starting  ----------

if [[ -n "$OPT_TEST" ]]; then
    echo
    PATT="$name"
    pinfo ===== checking title_containing with $PATT
    title_containing "$PATT"
    #PATT="Casablanca (1942)"
    echo
    pinfo ===== checking title_starting with $PATT
    title_starting "$PATT"
    echo
fi


# this one matches from the start but assumes the last name is exact. Should be init upper case (proper case).
# returns zero, or >=1  rows.
last_name_equals ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="actor"
    MYCOL="name"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL GLOB "${PATT}, *";
!
}	# ----------  end of function last_name_equals  ----------

# this fully matches the name, and a (IVX) must be supplied if the db has it
name_equals ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="actor"
    MYCOL="name"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL = "${PATT}";
!
}	# ----------  end of function name_equals  ----------

# this is for those cases where the name in the DB contains a "(IVX)"
#
name_starting ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="actor"
    MYCOL="name"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL GLOB "${PATT}*";
!
}	# ----------  end of function name_starting  ----------
# this fully matches the altname, but no IVX is to be supplied, so multiples can be returned
altname_equals ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="actor"
    MYCOL="newname"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select name from $MYTABLE where $MYCOL = "${PATT}";
!
}	# ----------  end of function altname_equals  ----------

# prints cast of movie and character given exact actor name
# may pass in  column names
# may specify that you want headers (for csvlook)
# may actuall want ordered by year, which we don't have as a separate column here.
movie_cast_exact () {

    opt_headers=off
    opt_columns="name, character"
    while [[ $1 = -* ]]; do
        case "$1" in
            -c|--columns)   shift
                opt_columns=$1
                #echo "columns is $opt_columns" 1>&2
                shift
                ;;
            -H|--headers)   shift
                opt_headers=$1
                #echo "headers is $opt_headers" 1>&2
                shift
                ;;
            *)
                echo "Error: Unknown option: $1" >&2   # rem _
                echo "Use -h or --help for usage"
                exit 1
                ;;
        esac
    done

    PATT="$1"
    [[ -z "$PATT" ]] && { echo "Error: movie blank." 1>&2; return 1; }

    MYTABLE="cast"
    MYCOL="title"
      #echo "Q is: select $opt_columns from $MYTABLE where $MYCOL = ${PATT};" 1>&2
$SQLITE $MYDATABASE <<!
.mode tabs
.headers $opt_headers
      select $opt_columns from $MYTABLE where $MYCOL = "${PATT}";
!
}	# ----------  end of function movie_cast_exact  ----------

# prints cast of movie and character given exact actor name
# may pass in  column names
# may specify that you want headers (for csvlook)
# may actuall want ordered by year, which we don't have as a separate column here.
movies_of_actor () {

    opt_headers=off
    opt_columns="title, character"
    while [[ $1 = -* ]]; do
        case "$1" in
            -c|--columns)   shift
                opt_columns=$1
                #echo "columns is $opt_columns" 1>&2
                shift
                ;;
            -H|--headers)   shift
                opt_headers=$1
                #echo "headers is $opt_headers" 1>&2
                shift
                ;;
            *)
                echo "Error: Unknown option: $1" >&2   # rem _
                echo "Use -h or --help for usage"
                exit 1
                ;;
        esac
    done

    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: movie blank." 1>&2; return 1; }

    MYTABLE="cast"
    MYCOL="name"
      echo "Q is: select $opt_columns from $MYTABLE where $MYCOL = ${PATT};" 1>&2
$SQLITE $MYDATABASE <<!
.mode tabs
.headers $opt_headers
      select $opt_columns from $MYTABLE where $MYCOL = "${PATT}";
!
}	# ----------  end of function movies_of_actor  ----------

#-------------------------------------------------------------------------------
# DIRECTOR queries
#-------------------------------------------------------------------------------
# this one matches from the start but assumes the last name is exact. Should be init upper case (proper case).
# returns zero, or >=1  rows.
director_last_name_equals ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="director"
    MYCOL="name"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL GLOB "${PATT}, *";
!
}	# ----------  end of function director_last_name_equals  ----------

# this fully matches the name, and a (IVX) must be supplied if the db has it
director_name_equals ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="director"
    MYCOL="name"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL = "${PATT}";
!
}	# ----------  end of function director_name_equals  ----------

# this is for those cases where the name in the DB contains a "(IVX)"
#
director_name_starting ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="director"
    MYCOL="name"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select $MYCOL from $MYTABLE where $MYCOL GLOB "${PATT}*";
!
}	# ----------  end of function director_name_starting  ----------

# this fully matches the altname, but no IVX is to be supplied, so multiples can be returned
director_altname_equals ()
{
    PATT="$*"
    [[ -z "$PATT" ]] && { echo "Error: PATT blank." 1>&2; return 1; }

    MYTABLE="director"
    MYCOL="newname"
$SQLITE $MYDATABASE <<!
.mode tabs
.headers off
      select name from $MYTABLE where $MYCOL = "${PATT}";
!
}	# ----------  end of function director_altname_equals  ----------

# prints movies of a director given exact name
# may pass in  column names
# may specify that you want headers (for csvlook)
movies_of_director () 
{

    opt_headers=off
    opt_columns="title"
    while [[ $1 = -* ]]; do
        case "$1" in
            -c|--columns)   shift
                opt_columns=$1
                #echo "columns is $opt_columns" 1>&2
                shift
                ;;
            -H|--headers)   shift
                opt_headers=$1
                #echo "headers is $opt_headers" 1>&2
                shift
                ;;
            *)
                echo "Error: Unknown option: $1" >&2   # rem _
                echo "Use -h or --help for usage"
                exit 1
                ;;
        esac
    done

    PATT="$1"
    [[ -z "$PATT" ]] && { echo "Error: movie blank." 1>&2; return 1; }

    MYTABLE="movie_director"
    MYCOL="name"
      #echo "Q is: select $opt_columns from $MYTABLE where $MYCOL = ${PATT};" 1>&2
$SQLITE $MYDATABASE <<!
.mode tabs
.headers $opt_headers
      select $opt_columns from $MYTABLE where $MYCOL = "${PATT}";
!
}	# ----------  end of function movies_of_director  ----------
