#!/bin/bash

# get the variables that you need to get

while test $# -gt 0; do
  case "$1" in
    --tree)
        shift
        tree_file=$1
        shift
        ;;
    --count)
        shift
        count_file=$1
        shift
        ;;
    --output)
        shift
        output_name=$1
        shift
        ;;
    --to)
      shift
      send_to=$1
      shift
      ;;
  esac
done

# TODO this has not been error proofed for directory locations that do not yet exist.
cd "$send_to"

counter=0
while true; do
current_output_file="$output_name"_"$counter"
  if [[ -d "$current_output_file" ]];then
    ((counter++))
    continue
  fi
 # cafe5 -i "$count_file" -t "$tree_file" -o "$current_output_file" 
  echo "$count_file"  "$tree_file" "$current_output_file"
  ((counter++))
done
