#!/bin/bash

# The purpose of this script is to automate the calls for stable.py for re-aligning alignments created by muscle5

#alignment_file_locations='The location to the aligned files.'
#input_file_locations='The location to the input files.'
#output_file_locations='The location to the output files'

#print_usage() {
#  printf "Usage: ..."
#}

while getopts 'a:i:o:' flag; do
	case "${flag}" in
		a) alignment_file_locations="${OPTARG}" ;;
		i) input_file_locations="${OPTARG}";;
		o) output_file_locations="${OPTARG}";;
	esac
done


for file in "$input_file_locations"/*

do
	base_name="$(basename -- $file)"
	base_name="${base_name%.*}"
	aligned_file=$(find "$alignment_file_locations/" -type f -name "$base_name.*")
	new_ext=".fa"
	output_file="$output_file_locations/$base_name$new_ext"
	python3 stable.py $file $aligned_file > "${output_file}"
done
