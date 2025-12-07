#!/bin/bash

# Setting up watches.
# Watches established.
# ./ MODIFY matrix_addition.cu
# ./ MODIFY .matrix_addition.cu.swp

while true; do
	## ./ CREATE matrix_addition.cu
	inotifywait -q -m . -e close_write | while read -r dir action filename; do
		if [[ "$filename" =~ .cpp$ ]]; then
            clear
            echo "*********** $filename"
            g++ batcher-odd-even-serial.cpp -o batcher-odd-even-serial.x && ./batcher-odd-even-serial.x 
		fi
	done
done
