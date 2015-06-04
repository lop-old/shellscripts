#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Common methods and utilities for pxn shell scripts.
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
# common.sh



# ensure path is set
if [[ ":${PATH}:" != *:/usr/bin/shellscripts:* ]]; then
	export PATH="/usr/bin/shellscripts:$PATH"
fi


alias errcho='>&2 echo'


# export PXN_DATA="/files"
# export PXN_BACKUPS="/backups"
# export PXN_WORKSPACE="/zwork"
# source ${PXN_SCRIPTS}/aliases.sh

export YES=1
export NO=0



# Define a few colors
COLOR_BLACK='\e[0;30m'
COLOR_BLUE='\e[0;34m'
COLOR_GREEN='\e[0;32m'
COLOR_CYAN='\e[0;36m'
COLOR_RED='\e[0;31m'
COLOR_PURPLE='\e[0;35m'
COLOR_BROWN='\e[0;33m'
COLOR_LIGHTGRAY='\e[0;37m'
COLOR_DARKGRAY='\e[1;30m'
COLOR_LIGHTBLUE='\e[1;34m'
COLOR_LIGHTGREEN='\e[1;32m'
COLOR_LIGHTCYAN='\e[1;36m'
COLOR_LIGHTRED='\e[1;31m'
COLOR_LIGHTPURPLE='\e[1;35m'
COLOR_YELLOW='\e[1;33m'
COLOR_WHITE='\e[1;37m'
COLOR_RESET='\e[0m'



# if [ "${0}" != *"bash" ]; then
# trap ctrl_c INT
# function ctrl_c() {
#	newline
#	echo "*** Trapped CTRL-C ***"
#	newline
#	exit 1
# }
# fi



# debug mode
if [ -e /usr/bin/shellscripts/debug ] || [ -e debug ]; then
	DEBUG=true
fi
if [ "$DEBUG" = true ]; then
	echo "[ DEBUG Mode ]"
	# Print commands when executed
	set -x
	# Variables that are not set are errors
	set -u
fi



function newline() {
	echo -ne "\n"
}
function echoerr() {
	echo "$@" 1>&2
}
function warning() {
	echo "[WARNING] $@"
}
#function ask() {
#	echo -n "$@" '[Y/n] '; read -n 1 reply
#	newline
#	case "$reply" in
#		n*|N*) return 1 ;;
#		*) return 0 ;;
#	esac
#}
function title() {
	local i=$((${#1}+8))
	local j=$((${#1}+4))
	local c=${#}
	newline
	echo -n " "; eval "printf '*'%.0s {1..$i}"; echo
	echo -n " "; eval "printf '*'%.0s {1..$i}"; echo
	echo -n " **"; eval "printf ' '%.0s {1..$j}"; echo "**"
	for line in "${@}"; do
		echo " **  ${line}  **"
	done
	echo -n " **"; eval "printf ' '%.0s {1..$j}"; echo "**"
	echo -n " "; eval "printf '*'%.0s {1..$i}"; echo
	echo -n " "; eval "printf '*'%.0s {1..$i}"; echo
	newline
	newline
}



# sleep
function sleepdot() {
	sleep 1;echo -n "."
	sleep 1;echo -n "."
	sleep 1;echo ""
}
function sleepdotdot() {
	sleep 2;echo -n " ."
	sleep 2;echo -n " ."
	sleep 2;echo -n " ."
	sleep 2;echo -n " ."
	sleep 2;echo ""
}



function get_lock() {
	if [ -z $1 ]; then
		LOCK_NAME="$0"
	else
		LOCK_NAME="$1"
	fi
	for i in {1..20} ; do
		LOCK_COUNT=`lsof -t $LOCK_NAME | wc -l`
		if [ $LOCK_COUNT -le 1 ]; then
			return 0
		fi
		echo -n " [${i}] Another instance is running."; sleepdotdot
		newline
	done
	newline
	echo "Timeout waiting for other instance to complete!"
	newline
	exit 1
}



function rsync_backup {
	if [ -z "${1}" ] || [ -z "${2}" ]; then
		echo "Source and destination arguments are required"
		exit 1
	fi
	# --bwlimit="${bwlimit}" --link-dest="$DST/${1}.1" "$SRC" "$DST/${1}.pre"
	rsync --progress --archive --delete-delay -Fyth "$@"  || exit 1
}



function latest_version {
	LATEST_FILE=`ls -1Brv ${1} 2>/dev/null | head -n1`
	if [ -z "${LATEST_FILE}" ]; then
		>&2 echo "Failed to find latest version for: ${1}"
		return 1
	fi
	LATEST_VERSION=`echo ${LATEST_FILE} | sed -ne 's/[^0-9]*\(\([0-9]\.\)\{0,4\}[0-9][^.]\).*/\1/p'`
	return 0
}

