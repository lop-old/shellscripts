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
# load common utils script
if [ -e "${PWD}/common.sh" ]; then
	source "${PWD}/pxn_common.sh"
elif [ -e "/usr/local/bin/pxn/common.sh" ]; then
	source "/usr/local/bin/pxn/common.sh"
else
	wget "https://raw.githubusercontent.com/PoiXson/shellscripts/master/pxn/common.sh" \
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



sedVersion() {
	sed -i.original "s/x-SNAPSHOT/${BUILD_NUMBER}-SNAPSHOT/" "${1}" \
		|| { echo "Failed to sed a file! ${1}"; return 1; }
	sed -i "s/x-\</version\>/${BUILD_NUMBER}-\</version\>/" "${1}" \
		|| { echo "Failed to sed a file! ${1}"; return 1; }
}
restoreSed() {
	mv -fv "${1}.original" "${1}" \
		|| { echo "Failed to restore a file! ${1}"; return 1; }
}



# prepare rpm build space
if [ "${0}" == "build-rpm.sh" ]; then
	# ensure rpmbuild tool is available
	which rpmbuild >/dev/null || { echo "rpmbuild not installed - yum install rpmdevtools"; exit 1; }
	# ensure .spec file exists
	[[ -z $SPEC_FILE ]] \
		&& { echo 'SPEC_FILE variable not set!'; exit 1; }
	[[ -e "${PWD}/${SPEC_FILE}" ]] \
		|| { echo "${SPEC_FILE} file not found!"; exit 1; }
	# output location
	if [ -z $OUTPUT_DIR ]; then
		OUTPUT_DIR="${PWD}"
	fi
	# build location
	export BUILD_ROOT="${PWD}/rpmbuild-root"
	# create build space
	for dir in BUILD RPMS SOURCE SOURCES SPECS SRPMS tmp ; do
		if [ -d "${BUILD_ROOT}/${dir}" ]; then
			rm -rf --preserve-root "${BUILD_ROOT}/${dir}" \
				|| exit 1
		fi
		mkdir -p "${BUILD_ROOT}/${dir}" \
			|| exit 1
	done
	# copy .spec file
	[[ -z $SPEC_FILE ]] \
		&& { echo 'SPEC_FILE variable not set!'; exit 1; }
	cp -fv "${SPEC_FILE}" "${BUILD_ROOT}/SPECS/" \
		|| exit 1
fi

