#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2016 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
## Released under the GPL 3.0
##
## Description: Ask a yes/no question.
##
## Install to location: /usr/bin/shellscripts
##
## Download the original from:
##   http://dl.poixson.com/shellscripts/
##
## Usage: yesno <options> <question> [--timeout N] [--default X]
##
##   Options:
##     --timeout N    Timeout if no input seen in N seconds.
##     --default ANS  Use ANS as the default answer on timeout or
##                    if an empty answer is provided.
##
## Exit status is the answer.
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
# yesno.sh


PWD=`pwd`
# load common utils script
if [ -e "${PWD}/common.sh" ]; then
	source "${PWD}/common.sh"
elif [ -e "/usr/bin/shellscripts/common.sh" ]; then
	source "/usr/bin/shellscripts/common.sh"
else
	wget -O "${PWD}/common.sh" "https://raw.githubusercontent.com/PoiXson/shellscripts/master/pxn/common.sh" \
		|| exit 1
	source "${PWD}/common.sh"
fi


function yesno() {
	# question arg
	if [ $# -lt 1 ] || [ -z "$1" ]; then
		errcho 'Missing question argument.'
		return $NO
	fi
	local question=$1
	shift
	# parse arguments
	local default=$NO
	local timeout=0
	while [ $# -gt 0 ]; do
		case "$1" in
		--default)
			shift
			t=$1
			if [ -z "$t" ]; then
				errcho 'Missing --default value.'
				return $NO
			fi
			if   [[ "$t" == 'y' || "$t" == y* || "$t" == 'Y' || "$t" == Y* ]]; then
				default=$YES
			elif [[ "$t" == 'n' || "$t" == n* || "$t" == 'N' || "$t" == N* ]]; then
				default=$NO
			else
				errcho "Illegal default answer: $default"
				return $NO
			fi
			shift
			;;
		--timeout)
			shift
			timeout=$1
			if [ -z "$timeout" ]; then
				errcho 'Missing --timeout value.'
				return $default
			fi
			if [[ ! "$timeout" =~ ^[0-9][0-9]*$ ]]; then
				errcho "Illegal timeout value: $timeout"
				return $default
			fi
			shift
			;;
		-*)
			errcho "Unrecognized option: $1"
			shift
			return $default
			;;
		*)
			errcho "Unknown argument: $1"
			shift
			return $default
			;;
		esac
	done
	if [ $timeout -gt 0 ] && [ -z "$default" ]; then
		errcho 'Using --timeout requires a --default answer.'
		return $default
	fi
	if [ "$default" == "$YES" ]; then
		local question="${question} [Y/n]"
	elif [ "$default" == "$NO" ]; then
		local question="${question} [y/N]"
	fi
	local answer
	local ok=0
	# ask until answered
	while [[ $ok -eq 0 ]]; do
		newline
		echo -n "$question "
		# no timeout
		if [[ $timeout -eq 0 ]]; then
			read -p "$*" answer
		# with timeout
		else
			if ! read -t $timeout -p "$*" answer; then
				newline
				return $default
			fi
		fi
		# empty answer
		if [ -z "$answer" ]; then
			if [ ! -z "$default" ]; then
				return $default
			fi
		fi
		timeout=0
		if [[ "$answer" == 'y' || "$answer" == y* || "$answer" == 'Y' || "$answer" == Y* ]]; then
			newline
			return $YES
		fi
		if [[ "$answer" == 'n' || "$answer" == n* || "$answer" == 'N' || "$answer" == N* ]]; then
			newline
			return $NO
		fi
		warning "Valid answers are: y/n or yes/no";
	done
}


function yesno_demo() {
	if yesno "Test bad timeout value? "; then
		yesno "Hello? " --timeout none
	fi
	if yesno "Test timeout without default value? "; then
		yesno "Hello? " --timeout 10
	fi
	if yesno "Test bad default value? "; then
		yesno "Hello? " --default
	fi
	if yesno "Yes or no? [yn] "; then
		echo "You answered yes"
	else
		echo "You answered no"
	fi
	if yesno "Yes or no? (default: yes) " --default yes ; then
		echo "You answered yes"
	else
		echo "You answered no"
	fi
	if yesno "Yes or no? (default: no) " --default no ; then
		echo "You answered yes"
	else
		echo "You answered no"
	fi
	if yesno "Yes or no? (timeout: 5, default: no) " --timeout 5 --default no ; then
		echo "You answered yes"
	else
		echo "You answered no"
	fi
	if yesno "Yes or no? (timeout: 5, default: yes) " --timeout 5 --default yes ; then
		echo "You answered yes"
	else
		echo "You answered no"
	fi
	echo "Done testing."
}


# running script directly
if [[ $(basename "$0" .sh) == 'yesno' ]]; then
	# demo
	if [ $# -eq 0 ]; then
		yesno_demo
		exit $NO
	fi
	if [ $# -lt 1 ]; then
		errcho "Missing question argument: yesno <question> [--timeout N] [--default X]"
		exit $NO
	fi
	# yesno <question> [--timeout N] [--default X]
	if yesno "$@" ; then
		exit $YES
	fi
	exit $NO
fi
