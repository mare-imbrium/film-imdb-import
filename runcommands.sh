#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: runcommands.sh
# 
#         USAGE: ./runcommands.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/12/2015 20:01
#      REVISION:  2015-12-12 20:31
#===============================================================================
source ~/bin/sh_colors.sh


OPT_VERBOSE=
OPT_DEBUG=
OPT_BRIEF=
while [[ $1 = -* ]]; do
    case "$1" in
        -B|--brief)   shift
            OPT_BRIEF=1
            ;;
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -h|--help)
            cat <<-!
	$0 Version: 0.0.0 Copyright (C) 2015 jkepler
	This program does the following:.. TODO
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

if [ $# -eq 0 ]
then
    echo "I got no filename" 1>&2
    exit 1
else
    echo "Got $*" 1>&2
    #echo "Got $1"
    if [[ ! -f "$1" ]]; then
        echo "$1 not found" 1>&2
        exit 1
    fi
fi
if [  $# -eq 0 ]; then
    echo -e "Pass file name." 1<&2
else
    IFILE="$1"
fi
if [[ ! -f "$IFILE" ]]; then
    echo "File: $IFILE not found"
    exit 1
fi
while IFS='' read line
do
    VAR=$( echo "$line" | cut -f2- -d' ' )
    RESULT=$( eval "$line" 2>/dev/null )
    status=$?

    if [[ -z "$OPT_BRIEF" ]]; then
        pinfo "$VAR"
        echo -e "$RESULT"
    fi
    if [  $status -eq 0 ]; then
          echo "      OK:  $VAR"
    else
        perror "  FAILED: $VAR"
    fi
done < "$IFILE"
