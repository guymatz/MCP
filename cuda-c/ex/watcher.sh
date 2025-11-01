#!/bin/bash

# Setting up watches.
# Watches established.
# ./ MODIFY matrix_addition.cu
# ./ MODIFY .matrix_addition.cu.swp

while true; do
	## ./ CREATE matrix_addition.cu
	inotifywait -m . -e close_write | while read -r d a f; do
		if echo $f | grep -q ".cu$" ; then
			bin=${f%%.*}
			echo $a $f $bin
			make && ./$bin
		fi
	done
done
