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
	newline
	# parse arguments
	local question=""
	local default=""
	local timeout=-1
	while [ $# -gt 0 ]; do
		case "$1" in
		--default)
			shift
			local t="$1"
			if [ -z $t ]; then
				errcho "Missing --default value."
				return "$NO"
			fi
			if   [[ "$t" == "y" ]] || [[ "$t" == "Y" ]] || [[ "$t" == y* ]] || [[ "$t" == Y* ]]; then
				local default="$YES"
			elif [[ "$t" == "n" ]] || [[ "$t" == "N" ]] || [[ "$t" == n* ]] || [[ "$t" == N* ]]; then
				local default="$NO"
			else
				errcho "Illegal default answer: ${default}"
				return "$NO"
			fi
			shift
		;;
		--timeout)
			shift
			local timeout="$1"
			if [ -z $timeout ]; then
				errcho "Missing --timeout value."
				return "$default"
			fi
			if [[ ! "$timeout" == ?(-)+([0-9]) ]]; then
				errcho "Illegal timeout value: ${timeout}"
				if [ -z $default ]; then
					return "$NO"
				else
					return "$default"
				fi
			fi
			shift
		;;
		-*)
			errcho "Unrecognized option: $1"
			shift
			if [ -z $default ]; then
				return "$NO"
			else
				return "$default"
			fi
		;;
		*)
			local question="${question}${1} "
			shift
		;;
		esac
	done
	if [[ -z $question ]]; then
		errcho "Missing question argument."
	fi
	if [[ $timeout -gt 0 ]] && [[ -z $default ]]; then
		errcho "Using --timeout requires a --default answer."
		if [ -z $default ]; then
			return "$NO"
		else
			return "$default"
		fi
	fi
	local options=""
	if [ "$default" == "$YES" ]; then
		local options="[Y/n] "
	elif [ "$default" == "$NO" ]; then
		local options="[y/N] "
	else
		local options="[y/n] "
	fi
	# display question
	function display_question() {
		if [ $timeout -lt 0 ]; then
			echo -n "${question}${options}"
		else
			echo -n " <${timeout}> ${question}${options}"
		fi
	}
	# ask until answered
	while true; do
		local answer=""
		# no timeout
		if [[ $timeout -lt 0 ]]; then
			display_question
			read answer
			local result=$?
			newline
		# with timeout
		else
			display_question
			read -t 1 answer
			local result=$?
			# 1 second timeout
			if [ $result -eq 142 ]; then
				let timeout=timeout-1
				if [ $timeout -le 0 ]; then
					echo -ne "\r"
					display_question
					newline
					newline
					return "$default"
				fi
			fi
		fi
		# if empty answer, return default
		if [ -z $answer ]; then
			if [ $result -eq 142 ]; then
				echo -ne "\r"
			else
				if [ ! -z $default ]; then
					newline
					return "$default"
				fi
			fi
		# handle answer value
		else
			newline
			if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]] || [[ "$answer" == y* ]] || [[ "$answer" == Y* ]]; then
				return "$YES"
			fi
			if [[ "$answer" == "n" ]] || [[ "$answer" == "N" ]] || [[ "$answer" == n* ]] || [[ "$answer" == N* ]]; then
				return "$NO"
			fi
			warning "Valid answers are: y/n or yes/no";
		fi
	done
}


function yesno_demo() {
	clear
	local count_right=0
	local count_wrong=0
	# test 1
	newline
	echo " === Test 1 === "
	yesno "Yes or no?"
	result=$?
	if [ $result -eq $YES ]; then
		echo "You answered yes!"
	else
		echo "You answered no!"
	fi
	# test --timeout
	newline
	echo " === Test --timeout === "
	yesno "Test bad timeout value?" --default y
	result=$?
	if [ $result -eq $YES ]; then
		yesno "This should fail?" --timeout none
	fi
	# test --default
	newline
	echo " === Test --default === "
	yesno "Yes or no? (default: yes)" --default yes
	result=$?
	if [ $result -eq $YES ]; then
		let count_right=count_right+1
		echo "You answered right!"
	else
		let count_wrong=count_wrong+1
		echo "You answered WRONG!"
	fi
	yesno "Yes or no? (default: no)" --default no
	result=$?
	if [ $result -eq $YES ]; then
		let count_wrong=count_wrong+1
		echo "You answered WRONG!"
	else
		let count_right=count_right+1
		echo "You answered right!"
	fi
	yesno "Test bad default value?" --default y
	result=$?
	if [ $result -eq $YES ]; then
		yesno "This should fail?" --default
	fi
	yesno "Test timeout without default value?" --default y
	result=$?
	if [ $result -eq $YES ]; then
		yesno "This should take 10 seconds to timeout?" --timeout 10
	fi
	# allow timeout test
	newline
	echo " === Allow the rest to timeout === "
	yesno "Yes or no? (timeout: 5, default: yes)" --timeout 3 --default yes
	result=$?
	if [ $result -eq $YES ]; then
		let count_right=count_right+1
		echo "You answered right!"
	else
		let count_wrong=count_wrong+1
		echo "You answered WRONG!"
	fi
	yesno "Yes or no? (timeout: 5, default: no)" --timeout 3 --default no
	result=$?
	if [ $result -eq $YES ]; then
		let count_wrong=count_wrong+1
		echo "You answered WRONG!"
	else
		let count_right=count_right+1
		echo "You answered right!"
	fi
	# finished
	newline
	newline
	echo "Finished testing!"
	if [ $count_wrong -gt 0 ]; then
		echo "Error! At least ${count_wrong} tests have failed!"
		newline
		exit 1
	fi
	newline
}


# running script directly
if [[ $(basename "$0" .sh) == 'yesno' ]]; then
	# demo
	if [ $# -eq 1 ]; then
		if [[ "$1" == "--test" ]] || [[ "$1" == "--demo" ]]; then
			yesno_demo
			exit 1
		fi
	fi
	if [ $# -lt 1 ]; then
		errcho "Missing question argument: yesno <question> [--timeout N] [--default X]"
		exit 1
	fi
	# yesno <question> [--timeout N] [--default X]
	yesno $@
	result=$?
	if [ $result -eq $YES ]; then
		exit "$YES"
	fi
	exit "$NO"
fi
