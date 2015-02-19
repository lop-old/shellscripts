#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: pings a remote host until it's able to connect with ssh
##
## Install to location: /usr/local/bin/pxn
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
# pingssh.sh
clear



# find host in ~/.ssh/config file
function find_in_ssh_config() {
	# file ~/.ssh/config not found
	if [ ! -e ~/.ssh/config ]; then
		echo "File ~/.ssh/config not found"
		return 0
	fi
	SEARCH=${1}
	FOUND_HOST=""
	FOUND_PORT=""
	FOUND_USER=""
	while read LINE; do
		if [ -z "$LINE" ]; then
			continue
		fi
		# host
		if [[ $LINE == "Host"* ]]; then
			# already found host
			if [ ! -z "$FOUND_HOST" ]; then
				break
			fi
			# parse line
			IFS=' ' read -ra ARRAY <<< "$LINE"
			# found correct host
			if [ ${ARRAY[1]} == $SEARCH ]; then
				FOUND_HOST=${ARRAY[1]}
			fi
		fi
		if [ -z $FOUND_HOST ]; then
			continue
		fi
		# port
		if [[ $LINE == "Port"* ]]; then
			# parse line
			IFS=' ' read -ra ARRAY <<< "$LINE"
			FOUND_PORT=${ARRAY[1]}
		fi
		# user
		if [[ $LINE == "User"* ]]; then
			# parse line
			IFS=' ' read -ra ARRAY <<< "$LINE"
			FOUND_USER=${ARRAY[1]}
		fi
	done < ~/.ssh/config
	if [ -z "$FOUND_HOST" ]; then
		return 1
	else
		return 0
	fi
}



REMOTE_HOST="${1}"
# host not set
if [ -z $REMOTE_HOST ]; then
	echo "Remote host argument is required"
	exit 1
fi

# parse user@host
if [[ $REMOTE_HOST == *"@"* ]]; then
	IFS='@' read -ra ARRAY <<< "$REMOTE_HOST"
	REMOTE_USER="${ARRAY[0]}"
	REMOTE_HOST="${ARRAY[1]}"
# find in ~/.ssh/config
else
	if find_in_ssh_config $REMOTE_HOST ; then
		echo "Found host in .ssh/config"
		REMOTE_HOST=$FOUND_HOST
		REMOTE_PORT=$FOUND_PORT
		REMOTE_USER=$FOUND_USER
	fi
fi
# parse host:port
if [[ $REMOTE_HOST == *":"* ]]; then
	IFS=':' read -ra ARRAY <<< "$REMOTE_HOST"
	REMOTE_HOST=${ARRAY[0]}
	REMOTE_PORT=${ARRAY[1]}
fi
# default port
if [ -z $REMOTE_PORT ]; then
	REMOTE_PORT=22
fi
# default user
if [ -z $REMOTE_USER ]; then
	REMOTE_USER=`whoami`
fi



# wait for host to come online
STEP=0
while true; do
	clear
	echo

	((STEP++))
	case $STEP in
		1) echo -ne " [*    ] ";;
		2) echo -ne " [**   ] ";;
		3) echo -ne " [***  ] ";;
		4) echo -ne " [ *** ] ";;
		5) echo -ne " [  ***] ";;
		6) echo -ne " [   **] ";;
		7) echo -ne " [    *] ";;
		8) echo -ne " [     ] "; STEP=0;;
	esac
	echo " Waiting for ${REMOTE_USER}@${REMOTE_HOST} ..."
	echo

	# ping remote host
	PING_RESULT=`/usr/bin/ping -w1 -c1 ${REMOTE_HOST} 1>/dev/null 2>/dev/null && echo 0 || echo 1` 
	if [[ $PING_RESULT -eq 0 ]]; then
		echo
		echo
		if ssh "${1}" ; then
			echo
			break
		fi
		echo
		sleep 1
	fi

done
