#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Creates a relative symbolic link.
##
## Install to location: /usr/bin/shellscripts
##
## Download the original from:
##   http://dl.poixson.com/shellscripts/
##
## Usage: mklinkrel <link_target> <create_here> <link_name>
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
# mklinkrel.sh


# target exists?
if [ -z ${1} ] || [ ! -e ${1} ]; then
	echo "Target directory ${1} doesn\'t exist!" >&2
	exit 1
fi
# symlink already exists
if [ -e "${2}/${3}" ]; then
	echo "Symlink already exists: ${2} / ${3}"
	exit 0
fi
# build repeating "../"
LEVELSDEEP=`echo "${2}" | tr '/' '\n' | wc -l`
UPDIRS=''
for (( i=0; i<$LEVELSDEEP; i++ )); do
	UPDIRS="${UPDIRS}../"
done
# enter dir in which to create
(
	echo "Creating symlink: ${1} -> ${2} / ${3}"
	mkdir -p -v "${2}" || exit 1
	cd "${2}"          || exit 1
	# create symlink
	ln -s "${UPDIRS}${1}" "${3}" \
		|| { echo "Failed to create symlink! ${UPDIRS}${1} ${3}" >&2 ; exit 1; }
)
