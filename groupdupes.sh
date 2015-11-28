#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
#         File: groupdupes.sh
#  Description: this takes a file, tab delimited, with repeating rows.
#     It suppresses printing of duplicates in the first column.
#     It may either print the first column as it changes, in a row of its own
#     like a header, or along with the other columns.
#     -h option makes it print first column separately
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-16 
#      License: MIT
#  Last update: 2015-11-16 23:24
# ----------------------------------------------------------------------------- #
#  groupdupes.sh  Copyright (C) 2012-2014 j kepler
#  Last update: 2015-11-16 23:24
#
#  Example usage:
#    grep "^Ladies in" movie_actresses.dbf | ./groupdupes.sh -h

# use this inside other scripts that do some process
export COLOR_RED="\\033[0;31m"
export COLOR_GREEN="\\033[0;32m"
export COLOR_BLUE="\\033[0;34m"
export COLOR_YELLOW="\\033[1;33m"
export COLOR_WHITE="\\033[1;37m"
export COLOR_DEFAULT="\\033[0m"
export COLOR_BOLD="\\033[1m"
export COLOR_BOLDOFF="\\033[22m"

pbold() {
    echo -e "${COLOR_BOLD}$*${COLOR_BOLDOFF}"
}
# e.g. inform of an action that is about to happen
pinfo() {
    echo -e "${COLOR_BOLD}${COLOR_YELLOW}$*${COLOR_BOLDOFF}${COLOR_DEFAULT}"
}
# print an error in red, or warning.
perror() {
    echo -e "${COLOR_BOLD}${COLOR_RED}$*${COLOR_BOLDOFF}${COLOR_DEFAULT}" <&2
  #echo -e "$0: $*" >&2
}

# inform of action that is over successfully
pdone() {
    text=${*:-"Done."}
    echo -e "${COLOR_BOLD}${COLOR_GREEN}${text}${COLOR_BOLDOFF}${COLOR_DEFAULT}" <&2
}
pheader() {
    echo -ne "${COLOR_BOLD}${COLOR_YELLOW}$*${COLOR_BOLDOFF}${COLOR_DEFAULT}"
}

col1=""
lens1=0
indent=5
blank="    "

# header to print in color
opt_color=1

# have option for which column
# and delimiter, and how many columns.
opt_header=
if [ "$1" == "-h" ]; then
    opt_header=1
fi

while IFS=$'\t' read -r s1 s2 s3 s4; do
  if [ "$s1" == "$col1" ]; then
    s1=$blank
    printf '%*s' $lens1 "$s1" 
  else
    col1="$s1"
    if [[ -n "$opt_header" ]]; then
        lens1=$indent
    else
        lens1=${#s1}
    fi
    # print the header first, on it's own line
    header=$(printf '%*s' $lens1 "$s1")
    if [[ -n "$opt_color" ]]; then
        pheader "$header"
    else
        printf $header
    fi
    
    # if user wants a header then put a newline
    if [[ -n "$opt_header" ]]; then
        printf '\n'
        printf '%*s' $lens1 "$blank"
    fi
  fi
  printf '\t%s\t%s\t%s\n' "$s2" "$s3" "$s4"
done  
printf '\n'
