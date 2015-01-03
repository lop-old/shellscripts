##===============================================================================
## Copyright (c) 2013-2014 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Common methods and utilities for managing a yum package repo.
##
## Install to location: /usr/local/bin/pxn
##
## Download the original from:
##   http://dl.poixson.com/scripts/
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
# repo_common.sh



PATH_DL="/home/pxn/www/dl"
PATH_YUM="/home/pxn/www/yum"
PATH_YUM_TESTING="/home/pxn/www/yum/extras-testing"
PATH_YUM_STABLE="/home/pxn/www/yum/extras-stable"



##################################################



# load common utils script
if [ -e common.sh ]; then
	source ./pxn_common.sh
elif [ -e /usr/local/bin/pxn/common.sh ]; then
	source /usr/local/bin/pxn/common.sh
else
	wget https://raw.githubusercontent.com/PoiXson/shellscripts/master/pxn/common.sh \
		|| exit 1
	source ./common.sh
fi



# get package names from dl.poixson.com
function list_packages {
	local FILES
	FILES=( $(ls -dGv1 ${PATH_DL}/*) )
	FILES='\n' read -a array <<< "$FILES"
	PACKAGES=()
	for FILE in "${FILES[@]}" ; do
		PACKAGES=( ${PACKAGES[@]} $(basename $FILE) )
	done
}



function find_arch_in_filename {
	if [[ ${1} == *"x86_64.rpm" ]]; then
		ARCH="x86_64"
	elif [[ ${1} == *"i386.rpm" ]]; then
		ARCH="i386"
	else
		ARCH="noarch"
	fi
}

