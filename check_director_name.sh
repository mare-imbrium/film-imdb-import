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

name=
ORIGNAME=$name
MYTABLE=director
MYDATABASE=movie.sqlite
SQLITE=$(brew --prefix sqlite)/bin/sqlite3
name_search() {
    name="$*"
    RESULT=
    if [[ -z "$MYOPERATOR" ]]; then
        MYOPERATOR="="
    fi
    RESULT=$( $SQLITE $MYDATABASE "select name from $MYTABLE where name $MYOPERATOR \"$name\";")
}
newname_search() {
    name="$*"
    RESULT=
    if [[ -z "$MYOPERATOR" ]]; then
        MYOPERATOR="="
    fi
    RESULT=$( $SQLITE $MYDATABASE "select name from $MYTABLE where newname $MYOPERATOR \"$name\";")
}
ascii_name_search() {
    name="$*"
    RESULT=
    if [[ -z "$MYOPERATOR" ]]; then
        MYOPERATOR="="
    fi
    RESULT=$( $SQLITE $MYDATABASE "select name from ascii_director where ascii_name $MYOPERATOR \"$name\";")
}

check() {
#-------------------------------------------------------------------------------
# Exact search first
#-------------------------------------------------------------------------------
if [[ -n "$OPT_EXACT" ]]; then 
	MYOPERATOR=
	name_search "$name"
	[[ -n "$RESULT" ]] && { echo "$RESULT" ; exit 0; }
	echo -e "No match for $name" 1<&2
	exit 1
fi

OPT_HASCOMMA=
if [[ $name == *,* ]]; then
	OPT_HASCOMMA=1
fi
#-------------------------------------------------------------------------------
# GLOB search, user specifies by placing * at end
#-------------------------------------------------------------------------------
if [[ "${name: -1}" == '*' ]]; then
	MYOPERATOR=GLOB
	name_search "$name"
	[[ -n "$RESULT" ]] && { echo "$RESULT" ; exit 0; }
	# check newname if no comma present
    if [[ -z "$OPT_HASCOMMA" ]]; then
		MYOPERATOR=GLOB
		newname_search "$name"
		[[ -n "$RESULT" ]] && { echo "$RESULT" ; exit 0; }
	fi
    exit 1
fi
#-------------------------------------------------------------------------------
# LIKE search , user specifies LIKE by placing % at start or end
#-------------------------------------------------------------------------------
OPT_LIKE=
if [[ "$name" =~ ^% ]]; then OPT_LIKE=1; fi
if [[ "$name" =~ %$ ]]; then OPT_LIKE=1; fi
if [[ -n "$OPT_LIKE" ]]; then
    MYOPERATOR=LIKE
    name_search "$name"
    [[ -n "$RESULT" ]] && { echo "$RESULT" ; exit 0; }
fi
MYOPERATOR=
# exact search even though not specified
name_search "$name"
[[ -n "$RESULT" ]] && { echo "$RESULT" ; exit 0; }
[[ -n "$OPT_EXACT" ]] && { exit 1; }

#-------------------------------------------------------------------------------
# NEWNAME search , user may have given in FIRST NAME LASTNAME format without comma.
#-------------------------------------------------------------------------------

# switch last and first and check newname, if name already in newname format then okay
newname=$( echo "$name" | sed "s/^\([^,]*\), *\(.*\)/\2 \1/")

OPT_LOWERCASE=
if ! [[ "$name" =~ [A-Z] ]]; then OPT_LOWERCASE=1 ; OPT_LIKE=1; fi

if [[ -n "$OPT_LIKE" ]]; then
    MYOPERATOR=LIKE
fi

#echo "newname search for $MYOPERATOR $newname"
newname_search $newname
[[ -n "$RESULT" ]] && { echo "$RESULT" ; exit 0; }

#-------------------------------------------------------------------------------
# Roman numbering search. We add a (I) and check.
#-------------------------------------------------------------------------------

#echo "checking after adding (I)"
romanname="$ORIGNAME (I)"
name_search "$romanname"
[[ -n "$RESULT" ]] && { echo "$RESULT" ; exit 0; }

# last ditch 2015-12-06 - indexes are nocase so lets try like
#echo trying nocase like. esp useful if user enters in lower case or doesn't know case of middle name
names=$( $SQLITE movie.sqlite "select name from director where newname LIKE \"$ORIGNAME\" OR name LIKE \"$ORIGNAME\";")
[[ -n "$names" ]] && { echo "$names" ; exit 0; }


#-------------------------------------------------------------------------------
# Check ascii_director since the name in the database maybe with accents / diacritics.
#-------------------------------------------------------------------------------

RESULT=$( $SQLITE movie.sqlite "select name from ascii_director where ascii_newname LIKE \"$ORIGNAME\" OR ascii_name LIKE \"$ORIGNAME\";")
[[ -n "$RESULT" ]] && { echo "$RESULT" ; exit 0; }
exit 1
}

OPT_EXACT=
OPT_IC=
OPT_AKA=
while [[ $1 = -* ]]; do
    case "$1" in
        -x|--exact)   shift
            OPT_EXACT=1
            ;;
        -i|--ignorecase)   shift
            OPT_IC=1
            ;;
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        --stdin)        shift
            OPT_STDIN=1
            break
            ;;
        -h|--help)
            cat <<-!
			$0 Version: 0.0.0 Copyright (C) 2015 jkepler
			This program checks given input against director names to see if it is correct.
            It prints the correct name if it can locate.
            --exact | -x user is supplying exact name in LastName, Firstname format, don't attempt LIKE or ascii search.

            --stdin  name of user will be read from STDIN

            The next searches for exact match.
            $0 --exact "Kurosawa, Akira"
			$0 --exact "Kurosawa, Jun (I)"
			The next will fail since it requires a "(I)"
			$0 --exact "Kurosawa, Jun"
			The next works since exact search has not been asked for:
			$0 "Kurosawa, Jun"

			The next does a GLOB search (case sensitive)
            $0 "Kurosawa, A*"
			The next does a LIKE search (case insensitive)
            $0 "Kurosawa, A%"
			The next does a LIKE search (case insensitive) due to entire argument being in lower case
            $0 "kurosawa, a"

			The next checks the ascii_names table to see if this name has been stored with accents/diacritics.
			$0 "Francois Truffaut"
			!
            exit
            ;;
        *)
            echo "Error: Unknown option: $1" >&2 
            echo "Use -h or --help for usage"
            exit 1
            ;;
    esac
done

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/dataset || exit 1
if [[ ! -f "movie.sqlite" ]]; then
    echo "File: movie.sqlite not found"
    exit 1
fi

if [[ -n "$OPT_STDIN" ]]; then
    while IFS='' read name
    do
        check "$name"
    done 
    exit 0
fi
if [  $# -eq 0 ]; then
    echo "Error: director name required in Lastname, Firstname format" 1>&2
    exit 1
else
    name="$*"
    check $name
fi
#echo "Got name : $name" 1>&2

