#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Common methods and utilities for building jar's or rpm's.
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
# build_utils.sh



PWD=`pwd`
if [[ "${PWD}" == "/usr/"* ]]; then
	echo "Cannot run build_utils.sh script from this location."
	exit 1
fi
# load common utils script
if [ -e "${PWD}/common.sh" ]; then
	source "${PWD}/common.sh"
elif [ -e "/usr/local/bin/pxn/common.sh" ]; then
	source "/usr/local/bin/pxn/common.sh"
else
	wget -O "${PWD}/common.sh" "https://raw.githubusercontent.com/PoiXson/shellscripts/master/pxn/common.sh" \
		|| exit 1
	source "${PWD}/common.sh"
fi



# parse arguments
while [ $# -ge 1 ]; do
	case $1 in
	--build-number=*)
		BUILD_NUMBER="${1#*=}"
	;;
	--build-number)
		shift
		BUILD_NUMBER=$1
	;;
	--dl-path=*)
		DL_PATH="${1#*=}"
	;;
	--dl-path)
		shift
		DL_PATH=$1
	;;
	--yum-path=*)
		YUM_PATH="${1#*=}"
	;;
	--yum-path)
		shift
		YUM_PATH=$1
	;;
	*)
		echo "Unknown argument: ${1}"
		exit 1
	;;
	esac
	shift
done
# default build number
if [ -z ${BUILD_NUMBER} ]; then
	BUILD_NUMBER="x"
fi



# search for and load a config
loadConfig() {
	if [ $# == 0 ] || [ -z $1 ]; then
		echo "filename argument is required in loadConfig() function"
		return 1
	fi
	FILENAME=${1}
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
	echo "Config not found: ${FILENAME}"
	return 1
}



sedVersion() {
	[[ -z ${BUILD_NUMBER} ]]       && return
	[[ "${BUILD_NUMBER}" == "x" ]] && return
	sed -i.original "s@x-SNAPSHOT@${BUILD_NUMBER}-SNAPSHOT@" "${1}" || {
		echo "Failed to sed a file! ${1}"
		restoreSed "${1}"
		return 1
	}
	sed -i "s@x-FINAL</version>@${BUILD_NUMBER}-FINAL</version>@" "${1}" || {
		echo "Failed to sed a file! ${1}"
		restoreSed "${1}"
		return 1
	}
	sed -i "s@x</version>@${BUILD_NUMBER}</version>@" "${1}" || {
		echo "Failed to sed a file! ${1}"
		restoreSed "${1}"
		return 1
	}
}
restoreSed() {
	if [ -f "${1}.original" ]; then
		mv -fv "${1}.original" "${1}" || {
			echo "Failed to restore a sed file! ${1}"
			return 1
		}
	fi
}

