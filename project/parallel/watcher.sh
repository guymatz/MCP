#!/bin/bash

# Setting up watches.
# Watches established.
# ./ MODIFY matrix_addition.cu
# ./ MODIFY .matrix_addition.cu.swp

SIZE=${1-3}
echo SIZE is $SIZE

if [[ "$(uname -a)" =~ Darwin ]]; then
	cmd="fswatch . -1"
else
	cmd="inotifywait -q -m . -e close_write"
fi

while true; do
	$cmd | while read filename; do
		clear
		date
		echo "*********** $filename"
		make clean && make $(basename ${filename%%.*}).x && ./$(basename ${filename%%.*}).x $SIZE
	done
	sleep 1
done
