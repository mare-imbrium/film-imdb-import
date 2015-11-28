#!/usr/bin/env bash

MYDATABASE="movie.sqlite"
MYTABLE=cast
MYCOL=title

COMM=$(brew --prefix sqlite)/bin/sqlite3


#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    cat <<- EOT
    This prints the cast of movies. Data is taken from an sqlite database
    based on IMDB data. It can do an exact search or look for input name
    within the data.
    The name should be in the format: Movie (YYYY).
    e.g. Casablanca (1942)

    Usage :  ${0##/*/} [options] [--] 

    Options: 
    --exact         Exact name has been supplied.
    -h|--help       Display this message
    -v|--version    Display script version

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
opt_verbose=
opt_debug=
opt_exact=
ScriptVersion="1.0"
while [[ $1 = -* ]]; do
    case "$1" in

        -v|--version) echo "$0 -- Version $ScriptVersion"; exit 0   ;;

        --exact)   shift
            opt_exact=1
            ;;
        -V|--verbose)   shift
            opt_verbose=1
            ;;
        --debug)        shift
            opt_debug=1
            ;;
        -h|--help)  usage; exit 0   ;;
        *)
            echo "Error: Unknown option: $1" >&2   # rem _
            echo "Use -h or --help for usage"
            exit 1
            ;;
    esac
done


if [[ -n "$opt_debug" ]]; then
    $COMM --version >&2
fi

if [[ $# -eq 0 ]]; then
    echo -n "Enter movie pattern: "
    read ANS
else
    ANS="$*"
fi
if [[ -z "$ANS" ]]; then
    exit
fi
#echo $ANS

function search_pattern() {
PATT="$*"
#echo $PATT

$COMM $MYDATABASE <<!
.mode tabs
.headers on
  select * from $MYTABLE where $MYCOL like "%${PATT}%";
!

}
function search_exact() {
PATT="$*"

$COMM $MYDATABASE <<!
.mode tabs
.headers on
  select * from $MYTABLE where $MYCOL = "${PATT}";
!

}
echo "== Searching with $ANS" >&2
if [[ -z "$opt_exact" ]]; then
    #echo using like search
    search_pattern "$ANS"
else
    #echo using exacccct search
    search_exact "$ANS"
fi
