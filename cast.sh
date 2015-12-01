#!/usr/bin/env bash

MYDATABASE="movie.sqlite"
MYTABLE=cast
# where condition uses MYCOL
MYCOL=title
# default cols to print
MYCOLS="title,name, billing, character"

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
    -h|--no-title   Don't print (hide)  title, only if exact name supplied
    -l|--only-titles Print only matching titles for pattern
    --help          Display this message
    -v|--version    Display script version

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
opt_verbose=
opt_debug=
opt_exact=
opt_no_title=
opt_interactive=
ScriptVersion="1.0"
while [[ $1 = -* ]]; do
    case "$1" in

        -v|--version) echo "$0 -- Version $ScriptVersion"; exit 0   ;;

        --exact)   shift
            opt_exact=1
            ;;
        -h|--no-title)   shift
            opt_no_title=1
            ;;
        -V|--verbose)   shift
            opt_verbose=1
            ;;
        -l|--only-titles)
            opt_only_titles=1
            shift
            ;;
        --interactive)        shift
            opt_interactive=1
            ;;
        --debug)        shift
            opt_debug=1
            ;;
        --help)  usage; exit 0   ;;
        *)
            echo "Error: Unknown option: $1" >&2   # rem _
            echo "Use --help for usage"
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


print_only_titles ()
{
PATT="$*"
#echo $PATT
#echo inside print only

IFS=$'\n'
titles=( $( $COMM $MYDATABASE <<!
  select distinct title from $MYTABLE where $MYCOL like "%${PATT}%";
!
) )
#echo Titles are:
if [[ -z "$opt_interactive" ]]; then
    printf '%s\n' "${titles[@]}"
    exit 0
else
#leni=${#titles[@]:0}
select name in "${titles[@]}"; do
    if [[ -z "name" ]]; then
        #echo "Please select from one of numbers above."
        break
    else
        #echo you selected $name
        ANS=$name
        break
    fi  
done
fi
#leni=$( echo -e "${items}" | grep -c . )
}	# ----------  end of function print_only_titles  ----------

function search_pattern() {
PATT="$*"
#echo $PATT

$COMM $MYDATABASE <<!
.mode tabs
.headers on
  select $MYCOLS from $MYTABLE where $MYCOL like "%${PATT}%";
!

}
function search_exact() {
    PATT="$*"
    if [[ -n "$opt_no_title" ]]; then
        MYCOLS="name, billing, character"
    fi
$COMM $MYDATABASE <<!
.mode tabs
.headers on
  select $MYCOLS from $MYTABLE where $MYCOL = "${PATT}";
!

}
if [[ -n "$opt_only_titles" ]]; then
    print_only_titles "$ANS"
    [[ -z "$ANS" ]] && { echo "Error: ANS blank." 1>&2; exit 1; }
    opt_exact=1
fi
echo "== Searching with $ANS" >&2
if [[ -z "$opt_exact" ]]; then
    echo using like search
    search_pattern "$ANS"
else
    #echo using exacccct search
    search_exact "$ANS"
fi
