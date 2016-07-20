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
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
## =============================================================================
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

progress_percent "$@"
