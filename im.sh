#!/usr/bin/env zsh
# ----------------------------------------------------------------------------- #
#         File: im.sh
#  Description: query the datasets for movies directed by, or movies of actor, or starring
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-04 - 19:19
#      License: MIT
#  Last update: 2015-11-28 15:24
# ----------------------------------------------------------------------------- #
#  im.sh  Copyright (C) 2012-2014 j kepler
#
# TODO : case insensitive option -i --ignore-case
# TODO : make a file with only top billed, we really don't need all the actors in each movie
#   single out <1-9>
setopt EXTENDED_GLOB
IMDBHISTFILE=~/.imdbhist
source ~/bin/sh_colors.sh

# format output given file names and pattern.
#  Adds a == before person name, and spaces before the others.
#  replaces TABS with RETURNS
_format(){
    # this can print multiple directors or actors, so selection is tricky
    FILE="$1"
    PATT="$2"
    OLDPATT=$PATT
    if [[ -n "$OPT_INTER" ]]; then
        # resolve actors or directors and if only one, make it selectable
        _resolve_name $FILE $PATT
        [[ -z "$PATT" ]] && { perror "Error: Nothing for $OLDPATT in $FILE." ; return 1; }
        # write command to history file
        [[ -n $PATT ]] && print -s -- "$PATT"
        [[ -n $PATT ]] && echo "$PATT" >> $IMDBHISTFILE
    fi
    #grep "^${PATT}" "$FILE" | sed  's/^/== /' | tr '	' '\n' | sed 's/^\([^=]\)/     \1/'
    items=$( grep "^${PATT}" "$FILE" | sed  's/^/== /' | tr '	' '\n' | sed 's/^\([^=]\)/     \1/')
    if [[ -n "$OPT_INTER" ]]; then
        # the format for films contains role and other info so cannot generalize
        # movies for directors don't contain role but actor and actress do
        OLDCOLS=$COLS
        COLS=1
        select_from $items
        COLS=$OLDCOLS
        if [[ -n "$SEL" ]]; then
            echo you selected $SEL
            echo "---"
            SEL=$( echo $SEL | grep -o ".*(....)")
            SEL=$( print "$SEL" | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g;' )
            echo $SEL
            PATT="$SEL"
            # write command to history file
            [[ -n $PATT ]] && print -s -- "$PATT"
            [[ -n $PATT ]] && echo "$PATT" >> $IMDBHISTFILE
            _starring 
        fi
    else
        echo $items
    fi
    # TODO allow selection from this list
}

# search for either director name or actor or actrass based on $1 (file passed in)
_search(){
    FILE=$1
    echo -n "Enter first few characters of lastname: "
    read lname
    echo -n "Enter first few characters of firstname (esp if not entered lastname): "
    read fname
    [[ -z "${lname}$fname" ]] && { print "Error: name blank." 1>&2; exit 1; }
    #grep -i "^${lname}[^,]*, ${fname}[^	]*	" directors.dat | cut -f1 -d'	'
    items=$(grep -i "^${lname}[^,]*, ${fname}[^	]*	" $FILE | cut -f1 -d'	') 

    [[ -z "${items}" ]] && { print "Error: result of $lname $fname blank." 1>&2; exit 1; }
    echo -ne ${items} | nl
    echo
    echo "Enter choice:"
    read  CHOICE
    echo
    #echo -ne ${items} | grep "^ *${CHOICE}"
    echo -ne ${items} | sed "${CHOICE}!d"
    director=$(echo -ne ${items} | sed "${CHOICE}!d")
    # write command to history file
    [[ -n $director ]] && print -s -- "$director"
    [[ -n $director ]] && echo "$director" >> $IMDBHISTFILE
    _format $FILE $director

}

_choose() {
    PROMPT="$1"
    CHOICES="$2"

    echo "$PROMPT"
    echo "$CHOICES"
    read -k ans
    RESULT="$ans"
}
_resolve_name() {
    FILE="$1"
    PATT="$2"
    items=$(look "$PATT" "$FILE" | cut -f1)
    leni=$( echo -e "${items}" | grep -c . )
    if [[ $leni -gt 1 ]]; then
        select_from "$items"
        PATT="$SEL"
    elif [[ $leni -eq 0 ]]; then
        PATT=
    fi
}
_resolve_film() {
    [[ -z "$PATT" ]] && { print "Error: film name blank." 1>&2; return 1; }
    items=$(grep -i "$PATT" movies.list.new | cut -f1)
    leni=$( echo -e "${items}" | grep -c . )
    if [[ $leni -gt 1 ]]; then
        select_from "$items"
        PATT="$SEL"
    elif [[ $leni -eq 0 ]]; then
        PATT=
    fi
}
# prints in 2 cols and allows selection. But some listings are too wide, so it doesn't make sense.
select_from () {
    INPUT="$*"
    TT=$(echo "$INPUT" | nl) 
    print -rC${COLS} "${(@f)$(print -l -- $TT)}"
    echo -n "> "
    read ANS
    SEL=
    [[ -z "$ANS" ]] && { print "Error: film name blank." 1>&2; return 1; }
    echo -n "You have selected: "
    echo $TT | sed "${ANS}!d" | cut -f2 -d'	'
    SEL=$(echo $TT | sed "${ANS}!d" | cut -f2 -d'	')
}
_select_film(){
    echo -n "Enter part of film name:"
    vared -h -p "Enter part of film name: " PATT
    #read PATT
    [[ -z "$PATT" ]] && { print "Error: film name blank." 1>&2; return 1; }
    TT=$(grep -i "$PATT" movies.list.new | awkc --tab 1 | nl) 
    # need to check for how many returned
    
    leni=$( echo -e "${TT}" | grep -c . )
    (( leni < 1 )) && {
        print "Error: no films for $PATT" 1>&2; return 1;
    }
    print -rC2 "${(@f)$(print -l -- $TT)}"
    echo -n "> "
    read ANS
    [[ -z "$ANS" ]] && { print "Error: film name blank." 1>&2; return 1; }
    echo -n "You have selected: "
    echo $TT | sed "${ANS}!d" | cut -f2 -d'	'
    SEL=$(echo $TT | sed "${ANS}!d" | cut -f2 -d'	')
    _top_billed $SEL
    # starring shows a long list, can't we show the main persons like we once had somewhere.
}
_select_item(){
    items=$*
    TT=$(echo $items | nl)
    print -rC${COLS} "${(@f)$(print -l -- $TT)}"
    echo -n "> "
    read ANS
    echo -n "You have selected: "
    echo $TT | sed "${ANS}!d" | cut -f2 -d'	'
    RESULT=$(echo $TT | sed "${ANS}!d" | cut -f2 -d'	')
}
_top_billed() {
   PATT="$*"
   echo "=== Top Billed for ${PATT} ==== "
   if [[ -z "$PATT" ]]; then
       return 1
   fi
   # get topbilled from cast.sql.
   #grep -h -o "^[^	]*	.*${PATT}[^	]*" $act*.utf-8.dat | awk -F'	' '{ printf("%s\t%s\n", $1, $NF); }' | grep '<[1-9]>' | sed 's/ </	</;s/\[/	\[/' | sort -k4 -t'	' | cut -f1,3,4 -d'	'
   items=$(grep -h -o "^[^	]*	.*${PATT}[^	]*" $act*.utf-8.dat | awk -F'	' '{ printf("%s\t%s\n", $1, $NF); }' | grep '<[1-9]>' | sed 's/ </	</;s/\[/	\[/' | sort -k4 -t'	' | cut -f1,3,4 -d'	')
   OLDCOLS=$COLS
   COLS=1
   _select_item $items
   COLS=$OLDCOLS
   if [[ ! -z "$RESULT" ]]; then
       pdebug "Got $RESULT actress "
       # could be an actor
       # TODO check if male or female by checking index
       _format actors.list.utf-8.dat "$RESULT"
       _format actresses.list.utf-8.dat "$RESULT"
       #also this should also give a list selectable 
       # take out actor;s name and show his movies
   fi

}

_starring() {
    # PATT is pattern of movie. but we need to resolve ambiguities first
    OLDPATT=$PATT
        _resolve_film "$PATT"
        [[ -z "$PATT" ]] && { print "No movies for $OLDPATT" 1>&2; return 1; }
        # write command to history file
        [[ -n $PATT ]] && print -s -- "$PATT"
        [[ -n $PATT ]] && echo "$PATT" >> $IMDBHISTFILE
        #echo "== Actors: "
        #grep "${PATT}" actors.list.utf-8.dat | cut -f1 -d'	'
        #echo "== Actresses: "
        #grep "${PATT}" actresses.list.utf-8.dat | cut -f1 -d'	'
        echo "== Actors for $PATT === "
        OUT=$(grep "${PATT}" actors.list.utf-8.dat | cut -f1 -d'	')
        print -rC${COLS} "${(@f)$(print -l -- $OUT)}"
        echo "== Actresses for $PATT === "
        
        OUT=$(grep "${PATT}" actresses.list.utf-8.dat | cut -f1 -d'	')
        #OUT="=== Actors: ===\n${OUT}\n === Actresses: === \n${OUT1}"
        #echo "...."
        print -rC${COLS} "${(@f)$(print -l -- $OUT)}"

    }
do_field(){
case $FIELD in
    "directed_by")
        #grep "^${PATT}" directors.dat | tr '	' '\n'
        _format directors.list.utf-8.dat "$PATT"
        ;;
    "actor")
        _format actors.list.utf-8.dat "$PATT"
        #grep "^${PATT}" actors.dat | sed  's/^/== /' | tr '	' '\n' | sed 's/^\([^=]\)/     \1/'
        ;;
    "actress")
        _format actresses.list.utf-8.dat "$PATT"
        #grep "^${PATT}" actresses.dat | sed  's/^/== /' | tr '	' '\n' | sed 's/^\([^=]\)/     \1/'
        #grep "^${PATT}" actresses.dat | tr '	' '\n'
        ;;
    "starring")
        _starring "$PATT"
        ;;
esac
}

OPT=${*:-${OPT}}
MYVER=0.0.1
PATT=""
RDEBUG=:
FIELD=""
COLS=3
# filter appends the column and search value (FIELD and PATT)
_FILTER=""
while [[ $1 = -* ]]; do
case "$1" in
    -h|--help)
cat <<!
im.sh  $MYVER  Copyright (C) 2015 rahul kumar
This program lists movies based on certain criteria. 
The output is meant to be further filtered or transformed using cut or grep or awk.
You may filter based on the following criteria:
  -t | --actress
  -a | --actor
  -d | --directed_by
  -s | --starring
Others:
  Show only title
  --brief
  Display modes (see sqlite3 help)
  --mode line|html|csv|tabs|list
  Debug (show some echo statements)
  --debug

!
        exit
        ;;
    --debug)
        RDEBUG=echo
        shift
        ;;
    --source)
        echo "this is to edit the source "
        vim $0
        exit
        ;;
    --actress|--actor|--starring|--directed_by|-t|-a|-s|-d)
        FIELD=$1
        shift

        # if short form used, then expand it.
        if [[ $FIELD = -t ]]; then
            FIELD="--actress"
        fi
        if [[ $FIELD = -a ]]; then
            FIELD="--actor"
        fi
        if [[ $FIELD = -d ]]; then
            FIELD="--directed_by"
        fi
        if [[ $FIELD = -s ]]; then
            FIELD="--starring"
        fi
        # currently we are just overwriting previous, we could append TODO
        PATT=$1

        # remove start of string
        FIELD=${FIELD#--}
        if [[ -z "$PATT" ]]; then
            echo "Please enter a $FIELD"
            read PATT
        else
            shift
        fi
        if [[ -z "$_FILTER" ]]; then
            _FILTER=" $FIELD like '%$PATT%' "
        else
            _FILTER=" $_FILTER and  $FIELD like '%$PATT%' "
        fi
        #echo "QUERY is $FIELD = $PATT"
        $RDEBUG "QUERY is $_FILTER"
        ;;
    *)
        echo reached here wrong option
        shift
    ;;
esac
done
cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/dataset/ || exit

fc -ap $IMDBHISTFILE 20 20
# interactive or not
OPT_INTER=
ctr=0
INDENT2="           "
if [[ -z "$FIELD" ]]; then
    while [[ $ctr < 10 ]]; do
        # MENU
    OPT_INTER=1
    echo
    pbold "Select field to search on:"
    echo
    echo "${INDENT2}d    movies directed by"
    echo "${INDENT2}a    movies of given actor"
    echo "${INDENT2}t    movies of given actress"
    echo "${INDENT2}s    starring"
    echo "${INDENT2}z    search"
    echo "${INDENT2}m    movie search"
    echo "${INDENT2}q    quit"

    echo ""
    echo -n "Enter Choice: "
    read -k ans ; 
    echo
    case $ans in
        m) FIELD="movies"
            _select_film
            continue
            ;;
        d) FIELD="directed_by"
            echo "Enter name in format: Lastname, Firstname"
            ;;
        a) FIELD="actor"
            echo "Enter name in format: Lastname, Firstname"
            ;;
        t) FIELD="actress"
            echo "Enter name in format: Lastname, Firstname"
            ;;
        s) FIELD="starring"
            echo "Enter name of movie (case sensitive)"
            ;;
        z) FIELD="search"
            _choose "Select one:" "d director\na actor\nt actress\n"
            case $RESULT in
                d) FILE="directors.list.utf-8.dat"
                    ;;
                a) FILE="actors.list.utf-8.dat"
                    ;;
                t) FILE="actresses.list.utf-8.dat"
                    ;;
                *) echo "Error in choice: $ans not valid. "
                    exit
                    ;;
            esac
            _search $FILE
            continue
            ;;
        q)
            # this overwrites the file !
            #echo "$PATT" > $IMDBHISTFILE
            exit 1
            ;;
            
        *)
            echo  "Invalid choice. Try --help"
            #echo "$PATT" > $IMDBHISTFILE
            exit 1
            ;;

    esac
    echo
    echo -n "Enter pattern for $FIELD: "
    #read PATT
    vared -h -p "Enter pattern for $FIELD: " PATT
    [[ -z "$PATT" ]] && { print "Error: PATT blank." 1>&2; exit 1; }
    # write command to history file
    [[ -n $PATT ]] && print -s -- "$PATT"
    [[ -n $PATT ]] && echo "$PATT" >> $IMDBHISTFILE
    _FILTER=" $FIELD like '%$PATT%' "
    do_field
    #(( ctr++ ))
done
else
    do_field

fi
#cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/dataset/ || exit
