#!/bin/bash

# use the following setup to define longer flags in bash


while test $# -gt 0; do
  case "$1" in
    --msa_input)
        shift
        msa_input=$1
        shift
        ;;
    --cds_mirrors)
        shift
        cds_mirrors=$1
        shift
        ;;
    --output_path)
        shift
        output_path=$1
        shift
        ;;
  esac
done


for file in $msa_input/*

do

  # extract the base name of the file
  base_name="$(basename -- $file)"
  base_name="${base_name%.*}"

  # make the output file name (with full path)

  output_file="${output_path}/${base_name}.tmsa"

  # name of the cds file
  cds_file="${cds_mirrors}/${base_name}."* # this is assuming that the mirror cds folder has one (proper) cds file for each input msa file.
  
  pal2nal.pl $file $cds_file -output fasta > "$output_file"

done
