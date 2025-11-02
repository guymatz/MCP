#!/bin/bash

# Setting up watches.
# Watches established.
# ./ MODIFY matrix_addition.cu
# ./ MODIFY .matrix_addition.cu.swp

while true; do
	## ./ CREATE matrix_addition.cu
	inotifywait -q -m . -e close_write | while read -r dir action filename; do
		if [[ "$filename" =~ .cu$ ]]; then
			bin=${filename%%.*}
			echo $dir $action $filename $bin
			make && ./$bin
		fi
	done
done
