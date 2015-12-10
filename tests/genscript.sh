#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: genscript.sh
# 
#         USAGE: ./genscript.sh test-01.sh
# 
#   DESCRIPTION: run this on a file with commands, and this generates a script file
#       which is run by runscript.sh
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/09/2015 19:54
#      REVISION:  2015-12-10 11:43
#===============================================================================

source ~/bin/sh_colors.sh
file=${1:-"tests-01.sh"}
file="$PWD/$file"
if [[ ! -f "$file" ]]; then
    echo "File: $file not found"
    exit 1
fi
OFILE=$(echo $file | sed 's/\.sh$/.script/' )
echo output to $OFILE
rm $OFILE
CURDIR=${PWD}
cd ..
pwd
while IFS='' read cmd
do
    echo -en "$cmd"
    echo -e ">>> $cmd" >> $OFILE
    RES=$( eval $cmd 2>/dev/null)
    if [[ -z "$RES" ]]; then
        args=$(echo "$cmd" | cut -f2- -d' ')
        perror "ERROR: no result for $args"
        echo -e "NO RESULT" >> $OFILE
    else
        echo -e "$RES" >> $OFILE
        pdone ". Passed"
    fi
    echo ">>> END" >> $OFILE
done < $file

pinfo "Generated $OFILE. \nPls rename it to avoid overwriting"
