#!/bin/bash

for file in *

do
  base_name="$(basename -- $file)"
  base_name="${base_name%.*}"
  count_name="$base_name.count"
  perl verify_count.pl $file > $count_name
done
