#!/bin/bash

# Setting up watches.
# Watches established.
# ./ MODIFY matrix_addition.cu
# ./ MODIFY .matrix_addition.cu.swp

if [[ "$(uname -a)" =~ Darwin ]]; then
	cmd="fswatch . -1"
else
	cmd="inotifywait -q -m . -e close_write"
fi

while true; do
	$cmd | while read _ _ filename; do
		clear
		date
		echo "*********** $filename"
		make $(basename ${filename%%.*}).x && ./$(basename ${filename%%.*}).x
	done
	sleep 1
done
