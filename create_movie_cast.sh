#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: create_movie_cast.sh
# 
#         USAGE: ./create_movie_cast.sh [--check]
# 
#   DESCRIPTION: generate movie_cast.tsv file
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: jkepler
#  ORGANIZATION: 
#       CREATED: 12/03/2015 19:58
#      REVISION:  2015-12-03 20:30
#===============================================================================

#set -o nounset                              # Treat unset variables as an error

source ~/bin/sh_colors.sh

ScriptVersion="1.0"
OUTFILE="movie_cast.tsv"


check ()
{
    errors=0
    list="actors actresses"
    for stub in $list; do
        echo "$stub"
        out="movie_$stub.dbf"
        infile="$stub.topbilled.dbf"
        if [[ ! -f "$infile" ]]; then
            echo "File: $infile not found" 1>&2
            (( errors++ ))
        fi
        if [[  -f "$out" ]]; then
            pdone "Target File: $out found" 1>&2
            if [ $out -ot  $infile ]; then
                pinfo "$out is older than $infile and needs to be regenerated"
                (( errors++ ))
            else
                pdone "$out seems to be up-to-date"
            fi
            if [ $OUTFILE -ot  $infile ]; then
                pinfo "$OUTFILE is older than $infile and needs to be regenerated"
                (( errors++ ))
            else
                pdone "$OUTFILE seems to be up-to-date"
            fi
        fi
    done
    if [[ $errors -eq 0 ]]; then
        pdone "Nothing to do."
    else
        pinfo "You have ${errors} errors or notifications"
    fi
}	# ----------  end of function check  ----------
while [[ $1 = -* ]]; do
    case "$1" in
        --check)
            check;
            exit
            ;;
        -V|--verbose)   shift
            opt_verbose=1
            ;;
        --debug)        shift
            opt_debug=1
            ;;
        -h|--help)
            cat <<!
            $0 Version: 0.0.0 Copyright (C) 2012 rkumar
            This program creates the file movie_cast.tsv that is imported into movie.sqlite
            run --check first to see that you have files required.
!
            exit
            ;;
        *)
            echo "Error: Unknown option: $1" >&2   # rem _
            echo "Use -h or --help for usage"
            exit 1
            ;;
    esac
done

echo Starting generation process.
pinfo "calling ./resortdbf.sh --actors"
./resortdbf.sh --actors

pinfo "calling ./resortdbf.sh --actresses"
./resortdbf.sh --actresses

echo "sort movie_actresses.dbf movie_actors.dbf > $OUTFILE"
sort movie_actresses.dbf movie_actors.dbf > $OUTFILE
wc -l $OUTFILE
echo "You may remove movie_actresses.dbf and movie_actors.dbf after checking $OUTFILE for correctness"
