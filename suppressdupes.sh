#!/usr/bin/env bash
#  Last update: 2015-11-16 10:16

appId=""
lens1=0

while IFS=$'\t' read -r s1 s2 s3 s4; do
  if [ "$s1" == "$appId" ]; then
    s1="...."
  else
    appId="$s1"
    lens1=${#s1}
  fi
  printf '\n   %*s\t%s\t%s\t%s' $lens1 "$s1" "$s2" "$s3" "$s4"
done  
printf '\n'
