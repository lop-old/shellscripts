#!/bin/bash


function progress_percent() {
	let width=25
	if [[ -z "$1" ]] || [[ -z "$2" ]]; then
		echo 'Missing required argument!'
		exit 1
	fi
	TOTAL=$1
	CURRENT=$2
	let val=$CURRENT*$width
	let val=$val/$TOTAL
	echo -n '['
	for ((i=1; $i<=$width; i++)); do
		if [ $i -le $val ]; then
			echo -n '='
		else
			echo -n ' '
		fi
	done
	echo ']'
}

progress_percent $@
