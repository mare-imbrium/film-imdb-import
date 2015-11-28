#!/usr/bin/env bash
#  Last update: 2015-11-15 10:00
ic=""
if [[ -n "$1" ]]; then
    if [[ "$1" == "-i" ]]; then
        shift
        ic="-i"
    fi
fi
film="$*"
echo "Printing actors for film: ${film}"
echo " this removes the name, we need to show it if user enters a part or uses -i or several results come"
echo "Need to get actresses in too"
if [[ -z "$film" ]]; then
    echo "Enter name of film:"
    read film
fi
time (grep $ic  "	${film}" ma.dbf | sed 's/	.*(....)//;s/\(<.>\)$/	\1/;s/\[/		[/') | sort -k4 -t'	'


# ma.dbf is a sort of topbilled on film after joining lines with --normalize. i first removed  all TV etc from actors
