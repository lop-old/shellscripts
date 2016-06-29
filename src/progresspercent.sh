#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2016 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
## Released under the GPL 3.0
##
## Description: Displays a progress bar in ascii.
##
## Install to location: /usr/bin/shellscripts
##
## Download the original from:
##   http://dl.poixson.com/shellscripts/
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
##===============================================================================
# progresspercent.sh


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
