#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: check_movie_title.sh
# 
#         USAGE: ./check_movie_title.sh [--exact] "title"
# 
#   DESCRIPTION: this is a copy of the check_movie_title.sh which seems to do a lot of work
#                and tries to be very intelligent. this version tries to do just what it is told to do.
#
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/08/2015 19:25
#      REVISION:  2015-12-12 12:11
#===============================================================================

# Steps
# -----
# input can be full title with year, or baretitle
#   user can say --exact, --contains, --starts-with, --ignore-case, --glob
#    or --aka --reverse-aka
#
#  Some options are mutually exclusive: exact, contains startwith glob so we should keep in one variable, not several.
# 
#
#
#  DO exact check. if user asked for --exact then return 0 or 1 here itself.
#     IN exact check aka_title too.
#  Should be check for -i flag and do a LIKE then (or if all LC then assume LIKE)
#  If ends with * then GLOB
#
#  Has year been entered? If not, do a check against baretitle
#
#  Check against aka title at some stage
#  if fails check ascii_titles.
#
#  However, in case of --exact, we may need to check aka_titles too.
#

MYTABLE=movie
print_result() {
    [[ -n "$RESULT" ]] && { echo "$RESULT" ; 
    if [[ -n "$OPT_INTERACTIVE" ]]; then
        echo "$RESULT" >> ~/.HISTFILE_MOVIETITLE
    fi
    exit 0; }

}
# defaults to an equal search but can be used for GLOB or LIKE
title_search() {
    _name="$*"
    RESULT=
    if [[ -z "$MYOPERATOR" ]]; then
        MYOPERATOR="="
    fi
    [[ -z "$MYCOL" ]] && { MYCOL=title ; }
    RESULT=$( $SQLITE $MYDATABASE "select title from $MYTABLE where $MYCOL $MYOPERATOR \"$_name\";")
}
exact_search() {
    _name="$*"
    RESULT=
    RESULT=$( $SQLITE $MYDATABASE "select title from $MYTABLE where title = \"$_name\";")
}
aka_title_search_exact() {
    _name="$*"
    RESULT=
    RESULT=$( $SQLITE $MYDATABASE "select distinct(title) from aka_title where aka = \"$_name\";")
}
aka_title_search() {
    # TODO maybe here we should check operator for * and %. But what if user wants exact
    var="$*"
    RESULT=
    if [[ -z "$MYOPERATOR" ]]; then
        MYOPERATOR="="
    fi
    RESULT=$( $SQLITE movie.sqlite "select distinct(title) from aka_title where aka $MYOPERATOR \"${var}\";")
}
reverse_aka_title_search() {
    # TODO maybe here we should check operator for * and %. But what if user wants exact
    var="$*"
    RESULT=
    if [[ -z "$MYOPERATOR" ]]; then
        MYOPERATOR="="
    fi
    RESULT=$( $SQLITE movie.sqlite "select distinct(aka) from aka_title where title $MYOPERATOR \"${var}\";")
}
ascii_title_search() {
    # TODO maybe here we should check operator for * and %. But what if user wants exact
    # TODO only called from baretitle what if user gives year
    var="$*"
    RESULT=
    if [[ -z "$MYOPERATOR" ]]; then
        MYOPERATOR="="
    fi
    RESULT=$( $SQLITE movie.sqlite "select distinct(title) from ascii_title where ascii_title $MYOPERATOR \"${var}\";")
}
baretitle_search() {
    # NOTE this will probably be the most used so should be thought out carefully
    # BUG What if used specified contains
    if [[ -n "$OPT_LOWERCASE" ]]; then
        # do a like search NEXT IS REDUNDANT SHD BE IN ELSE
        #RESULT=$( $SQLITE $MYDATABASE "select title from $MYTABLE where baretitle = \"$name\";")
        #print_result
        # maybe a case issue
        RESULT=$( $SQLITE $MYDATABASE "select title from $MYTABLE where baretitle LIKE \"$name\";")
        print_result
        RESULT=$( $SQLITE $MYDATABASE "select title from $MYTABLE where baretitle LIKE \"${name}%\";")
        print_result
        aka_title_search_like "$name"
        print_result
        MYOPERATOR=LIKE
        ascii_title_search "${name}%"
        print_result
    else
        RESULT=$( $SQLITE $MYDATABASE "select title from $MYTABLE where baretitle = \"$name\";")
        print_result
        # do a glob search
        RESULT=$( $SQLITE $MYDATABASE "select title from $MYTABLE where baretitle GLOB \"${name}*\";")
        print_result
        MYOPERATOR=GLOB
        aka_title_search "${name}*"
        print_result
        ascii_title_search "${name}*"
        print_result
        RESULT=$( $SQLITE $MYDATABASE "select title from $MYTABLE where baretitle GLOB \"*${name}*\";")
        print_result
    fi
    return 1
}

aka_title_search_like() {
    name="$*"
    RESULT=$( $SQLITE $MYDATABASE <<!
    SELECT 
        distinct(title)
        FROM aka_title
        WHERE aka LIKE "%$name%"
        and (type LIKE '%English%' OR type LIKE '%imdb display%')
        ;
!
)
}
MYDATABASE=movie.sqlite

# OPT_SEARCH - EXACT STARTS CONTAINS , GLOB LIKE??
OPT_SEARCH=
OPT_EXACT=
OPT_IC=
OPT_AKA=
OPT_REVERSE_AKA=
OPT_CONTAINS=
OPT_STARTS_WITH=
OPT_REGEX=
OPT_LOWERCASE=
MYOPERATOR=
OPT_PRE=
OPT_POST=
while [[ $1 = -* ]]; do
    case "$1" in
        -x|--exact)   shift
            OPT_SEARCH=EXACT
            OPT_EXACT=1
            MYOPERATOR="="
            # user is specifying exact name and does not wish us to GLOB or LIKE 
            ;;
        --starts-with|--starts)   shift
            OPT_SEARCH=STARTS
            OPT_STARTS_WITH=1
            MYOPERATOR="GLOB"
            OPT_PRE=
            OPT_POST='*'
            ;;
        --contains)   shift
            OPT_SEARCH=CONTAINS
            OPT_CONTAINS=1
            MYOPERATOR="LIKE"
            OPT_PRE=%
            OPT_POST='%'
            ;;
        --aka)   shift
            OPT_AKA=1
            # user knows English name, but most tables use the original foreign name
            ;;
        --reverse-aka)   shift
            # user knows original foreign name but wishes to know English names
            OPT_REVERSE_AKA=1
            ;;
        --check-ascii|--ascii)   shift
            # user knows partial name in ascii but not accents
            OPT_ASCII=1
            ;;
        -i|--ignore-case)   shift
            #OPT_IC=1
            OPT_LOWERCASE=1
            MYOPERATOR="LIKE"
            ;;
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        -I|--interactive)   shift
            # prompt if no movies given, also saves movie name to hist file so usable in other commands
            OPT_INTERACTIVE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -h|--help)
            cat <<-!
			$0 Version: 0.0.0 Copyright (C) 2015 jkepler
			This program checks given input against movie titles to see if it is correct.
            It prints the correct title if it can locate.
            --exact | -x user is supplying exact title with year, don't attempt LIKE or ascii search.

            The next searches movie and aka-title for exact match and returns actual Japanese title
            $0 --exact "The Life of Oharu (1952)"
            $0 --exact "Casablanca (1942)"
            The next forces a check against aka table (use this if you know only the English name of a 
              foreign movie.
            $0 --aka "The Only Son"

            The next is useful if you know the foreign name of a film and wish to know the other names.
            $0 --reverse-aka "Higanbana"

            The next does a GLOB search against movie and aka-title and returns actual Japanese title
            $0 "The Life of Oharu *"

            If no movie is specified on CL, then ask. This uses readline, and allows selection from history file.
            $0 --interactive
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

if [  $# -eq 0 ]; then
    if [[ -n "$OPT_INTERACTIVE" ]]; then
        name=$(rlwrap -pYellow -S 'Movie name? ' -H ~/.HISTFILE_MOVIETITLE -P "" -o cat)
    else
        echo "Error: Title required in Title, (Year) format" 1>&2
        exit 1
    fi
else
    name="$*"
fi
#echo "Got name : $name" 1>&2
ORIGNAME=$name
SQLITE=$(brew --prefix sqlite)/bin/sqlite3

if [[ "$OPT_SEARCH" == "EXACT" ]]; then
    exact_search "$name"
    if [[ -n "$RESULT" ]]; then
        print_result
        exit 0
    else
        aka_title_search_exact "$name"
        if [[ -n "$RESULT" ]]; then
            print_result
            exit 0
        fi
    fi
    # user asked for exact search, since exact not found, we quit with error
    exit 1
fi
# user forcing aka check since there are already english movies by that name
# # TODO what if user specifies AKA and CONTAINS or STARTS or LIKE/LOWERCASE
mypatt="${OPT_PRE}${name}${OPT_POST}"
if [[ -n "$OPT_AKA" ]]; then
    aka_title_search "$mypatt"
    print_result
    #echo exiting aka titles failing $name
    # if the user did not specify any special case then lets try -- what if it is a baretitle
    if [[ -z "$OPT_SEARCH" ]]; then
        MYOPERATOR="GLOB"
        # WARN should this be name or mypatt
        echo -e "   AKA echcking GLOB for $name" 1<&2
        aka_title_search "${name}*"
        print_result
        echo -e "   ASCII echcking GLOB for $name, $MYOPERATOR" 1<&2
        MYOPERATOR="GLOB"
        ascii_title_search "${name}*"
        print_result
        exit 1
    fi
fi
if [[ -n "$OPT_REVERSE_AKA" ]]; then
    reverse_aka_title_search "$mypatt"
    print_result
    # if the user did not specify any special case then lets try -- what if it is a baretitle
    if [[ -z "$OPT_SEARCH" ]]; then
        MYOPERATOR="GLOB"
        # WARN should this be name or mypatt
        reverse_aka_title_search "${name}*"
        print_result
        exit 1
    fi
fi
if [[ -n "$OPT_ASCII" ]]; then
    # user specifies that we need to check ascii version of foreign name
    ascii_title_search "$mypatt"
    print_result
    exit 1
fi
if [[ "${name: -1}" == '*' ]]; then
    MYOPERATOR="GLOB"
    title_search "$name"
    print_result
    # check aka_title
    MYOPERATOR="GLOB"
    aka_title_search "$name"
    print_result
    #  TODO ascii search ?
    exit 1
fi
# check if baretitle
OPT_BARETITLE=
if [[ $name = *\([0-9][0-9]* ]]; then
    OPT_BARETITLE=
else
    #echo "$name does not contain year" 1>&2
    OPT_BARETITLE=1
fi
if ! [[ "$name" =~ [A-Z] ]]; then OPT_LOWERCASE=1 ; fi
if [[ -n "$OPT_LOWERCASE" ]]; then
    # full title, but lowercase so try like search on full title
    MYOPERATOR=LIKE
fi
# --- this should take care of various other cases

if [[ -n "$OPT_BARETITLE" ]]; then
    MYCOL=baretitle
    #baretitle_search "$mypatt"
    title_search "${mypatt}"
    print_result
    # TODO if nothing specified at least check that movie may be exact without year GLOB
    # do we check aka and ascii
    # they both have year, so we have to glob or like
    aka_title_search_like "$name"
    print_result
    # BUG what if user has said --contains or --startswith
    ascii_title_search "${mypatt}"
    print_result

    MYOPERATOR=LIKE
    ascii_title_search "${name}%"
    print_result
    exit 1
fi
# BUG baretitle did an ascii search and aka, but if year passed then we don't ???
title_search "$mypatt"
print_result

# next already done if user says ignore-case
if [[ -n "$OPT_LOWERCASE" ]]; then
    # full title, but lowercase so try like search on full title
    MYOPERATOR=LIKE
    title_search "$mypatt"
    print_result
fi
exit

if [[ "$name" =~ ^% ]]; then OPT_LIKE=1; fi
if [[ "$name" =~ %$ ]]; then OPT_LIKE=1; fi
if [[ -n "$OPT_LIKE" ]]; then
    MYOPERATOR=LIKE
    title_search "$name"
    print_result
fi
#if [[ "$name" =~ [A-Z] ]]; then echo "$name contains uppercase" 1>&2 ; fi
#if [[ "$name" =~ ^[A-Z] ]]; then echo "$name starts uppercase" 1>&2 ; fi
if ! [[ "$name" =~ [A-Z] ]]; then OPT_LOWERCASE=1 ; fi

if [[ -n "$OPT_BARETITLE" ]]; then
    baretitle_search "$mypatt"
    print_result
fi
if [[ -n "$OPT_LOWERCASE" ]]; then
    # full title, but lowercase so try like search on full title
    MYOPERATOR=LIKE
    title_search "$mypatt"
    print_result
fi
# we seem to have failed everywhere but we haven't check aka_title


exit
# We try various other tables and columns looking for a possible match
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
