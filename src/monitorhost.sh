#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2016 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
## Released under the GPL 3.0
##
## Description: Pings a remote host until it's able to connect with ssh.
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
# monitorhost.sh


TRUE=1
FALSE=0

LOCK_FILE_PREFIX="/tmp/monitor_failed_"


# arguments
ALERT_EMAIL="${1}"
if [ -z $ALERT_EMAIL ]; then
	echo "Alert email argument is required" >&2
	exit 1
fi
PING_HOST="${2}"
if [ -z $PING_HOST ]; then
	echo "Remote host argument is required" >&2
	exit 1
fi


# ping remote host
ping -c1 "${PING_HOST}" >/dev/null && SUCCESS=TRUE || SUCCESS=FALSE


# ping success
if [ $SUCCESS = TRUE ]; then
	# returned online
	if [ -f "${LOCK_FILE_PREFIX}${PING_HOST}" ]; then
		echo "Host ${PING_HOST} returned online!"
		rm -f "${LOCK_FILE_PREFIX}${PING_HOST}"
		/usr/sbin/sendmail "${ALERT_EMAIL}" <<EOF
from:${ALERT_EMAIL}
subject:Host returned online - ${PING_HOST}

Monitored host returned online.

${PING_HOST}
EOF
	fi


# ping failed
else
	# host went offline
	if [ ! -f "${LOCK_FILE_PREFIX}${PING_HOST}" ]; then
		echo "Host ${PING_HOST} is down!"
		touch "${LOCK_FILE_PREFIX}${PING_HOST}"
		/usr/sbin/sendmail "${ALERT_EMAIL}" <<EOF
from:${ALERT_EMAIL}
subject:Host is down - ${PING_HOST}

Monitored host is down!

${PING_HOST}
EOF
	fi
fi
