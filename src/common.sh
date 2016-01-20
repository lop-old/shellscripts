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



BIN_PHP=`which php-cli 2>/dev/null`
if [ -z ${BIN_PHP} ]; then
	if [ -f /usr/bin/php ]; then
		BIN_PHP='/usr/bin/php'
	fi
fi
if [ -z ${BIN_PHP} ]; then
	BIN_PHP=`which php 2>/dev/null`
fi
if [ -z ${BIN_PHP} ]; then
	BIN_PHP='/dev/null'
fi
export BIN_PHP



alias errcho='>&2 echo'
alias pushd='echo -n "cd> ";pushd'
alias popd='echo -n "cd< ";popd'

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
function errcho() {
	echo "$@" 1>&2
}
function echoerr() {
	errcho $@
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
	MAX_SIZE=1
	for ARG in "$@"; do
		local _S=${#ARG}
		if [ $_S -gt $MAX_SIZE ]; then
			MAX_SIZE=$_S
		fi
	done
	local _A=$(($MAX_SIZE+8))
	local _B=$(($MAX_SIZE+2))
	newline
	echo -n " "; eval "printf '*'%.0s {1..$_A}"; echo
	echo -n " "; eval "printf '*'%.0s {1..$_A}"; echo
	echo -n " ** "; eval "printf ' '%.0s {1..$_B}"; echo " **"
	for LINE in "${@}"; do
		local _S=$(($_B-${#LINE}))
		echo -n " **  ${LINE}"; eval "printf ' '%.0s {1..$_S}"; echo "**"
	done
	echo -n " ** "; eval "printf ' '%.0s {1..$_B}"; echo " **"
	echo -n " "; eval "printf '*'%.0s {1..$_A}"; echo
	echo -n " "; eval "printf '*'%.0s {1..$_A}"; echo
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
	errcho 'Timeout waiting for other instance to complete!'
	newline
	exit 1
}



# function valid_ip {
#	local ip=$1
#	local stat=1
#	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
#		OIFS=$IFS
#		IFS='.'
#		ip=($ip)
#		IFS=$OIFS
#		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
#		&& ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
#		stat=$?
#	fi
#	return $stat
# }



function rsync_backup {
	if [ -z "${1}" ] || [ -z "${2}" ]; then
		errcho 'Source and destination arguments are required'
		exit 1
	fi
	# --bwlimit="${bwlimit}" --link-dest="$DST/${1}.1" "$SRC" "$DST/${1}.pre"
	rsync --progress --partial --archive --delete-delay --delete-excluded -Fyth "$@"  || exit 1
}



function latest_version {
	LATEST_FILE=`ls -1Brv ${1} 2>/dev/null | head -n1`
	if [ -z "${LATEST_FILE}" ]; then
		errcho "Failed to find latest version for: ${1}"
		return 1
	fi
	LATEST_VERSION=`echo ${LATEST_FILE} | sed -ne 's/[^0-9]*\(\([0-9]\.\)\{0,4\}[0-9][^.]\).*/\1/p'`
	return 0
}



# search for and load a config
searchConfig() {
	if [ $# == 0 ] || [ -z $1 ]; then
		errcho 'filename argument is required in searchConfig() function'
		return 1
	fi
	local FILENAME=${1}
	local FILEPATH
	local LEVELSDEEP
	local UPDIRS
	if [ $# -lt 2 ]; then
		LEVELSDEEP=0
	else
		LEVELSDEEP=${2}
	fi
	for (( i=0; i<=$LEVELSDEEP; i++ )); do
		UPDIRS=""
		for (( ii=0; ii<$i; ii++ )); do
			UPDIRS+="../"
		done
		FILEPATH="${PWD}/${UPDIRS}${FILENAME}"
		if [ -f "${FILEPATH}" ]; then
			if [ $i -eq 0 ]; then
				echo "Found config in current dir: ${FILEPATH}"
			else
				echo "Found config ${i} dirs up: ${FILEPATH}"
			fi
			source "${FILEPATH}"
			return 0
		fi
	done
	errcho "Config not found: ${FILENAME}"
	return 1
}
