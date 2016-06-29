#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2016 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
## Released under the GPL 3.0
##
## Description: Changes permissions of files and directories recursively.
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
# chmodr.sh


if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then
	echo
	echo 'usage: $0 <dir perm> <file perm> <path>'
	echo
	echo 'e.g. $0 755 644 ./'
	echo
	echo 'sets dir perms to 755 and file perms to 644 recursively'
	echo
	exit 1
fi
echo
echo "Path: $3"
echo "Setting dirs to:  $1"
echo "Setting files to: $2"
echo
pushd "$3" || exit 1
	ENTRIES=(`ls -RA | awk '/:$/&&f{s=$0;f=0}/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}NF&&f{ print s"/"$0 }'`)
	for ENTRY in "${ENTRIES[@]}"; do
		if [ ! -z $ENTRY ]; then
			if [ -h "$ENTRY" ]; then
				echo "S: $ENTRY"
			elif [ -d "$ENTRY" ]; then
				echo "D: $ENTRY"
				echo -n "  "
				chmod -c "$1" "$ENTRY"
				echo -ne "\r"
			elif [ -f "$ENTRY" ]; then
				echo "F: $ENTRY"
				echo -n "  "
				chmod -c "$2" "$ENTRY"
				echo -ne "\r"
			else
				echo "UNKNOWN: $ENTRY"
				echo "HALTING!"
				exit 1
			fi
		fi
	done
popd
echo
echo "Finished!"
echo
