#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: runscript.sh
# 
#         USAGE: ./runscript.sh 
# 
#   DESCRIPTION: runs scripts created by genscript.sh. compares output to expected
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/09/2015 21:06
#      REVISION:  2015-12-10 12:12
#===============================================================================


if [  $# -eq 0 ]; then
    echo "Give name of script to run" 1>&2
    exit 1
fi
SCRIPTFILE=$PWD/$1
if [[ ! -f "$SCRIPTFILE" ]]; then
    echo "File: $SCRIPTFILE not found"
    exit 1
fi
passed=0
failed=0
counter=0
FACTUAL=$PWD/actual
FEXPECT=$PWD/expect
cd ..
pwd
while IFS='' read line
do
    #echo -e "$line"
    case $line in
        ">>> END")
            #echo INSIDE END
            eval "$cmd" > $FACTUAL 2>/dev/null
            if [[ ! -s "$FACTUAL" ]]; then
                echo "NO RESULT" > $FACTUAL
            fi
            mydiff=$(diff $FACTUAL $FEXPECT)
            if [[ -n "$mydiff" ]]; then
                echo
                echo "$cmd:----"
                echo -e "$mydiff"
                echo "------------"
                echo
                (( failed++ ))
            else
                #echo -en "."
                (( passed++ ))
            fi
            > $FEXPECT
            cmd=""
            ;;
        ">>> "*)
            #echo INSIDE BLANK COMMAND
            cmd=${line#>>> }
            (( counter++ ))
            ;;
        *)
            #echo INSIDE else writing to $FEXPECT
            echo "$line" >> $FEXPECT
    esac
    echo -en "\rTotal: $counter	Failed: $failed	Passed: $passed   "
done < $SCRIPTFILE
echo
echo "Total tests:  $counter"
echo "FAILED tests: $failed"
echo "PASSED tests: $passed"
rm $FACTUAL $FEXPECT
