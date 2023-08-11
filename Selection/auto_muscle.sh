#!/bin/bash

for file in *.pal
do
	base_name="$(basename $file .fa)"
	new_ext=".aligned"
	output_name="$base_name$new_ext"
	muscle5 -super5 $file -output $output_name
done
