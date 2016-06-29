#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2016 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
## Released under the GPL 3.0
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
