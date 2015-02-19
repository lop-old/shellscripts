#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Promotes a package from testing to stable in a yum repo.
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
# repo_promote.sh
clear
echo



source /usr/local/bin/pxn/repo_common.sh



function promote_package {
	title "Promoting ${SELECTED}.."
	case $SELECTED in
	GrowControl)
		link_package "noarch" "gcServer"
		link_package "noarch" "gcClient"
	;;
	java-dep)
		link_package "noarch" "java-dep-jre"
		link_package "noarch" "java-dep-jdk"
		link_package "noarch" "java-dep-opn"
	;;
	cpanel-php-dep)
		link_package "noarch" "cpanel-php54-dep"
		link_package "noarch" "cpanel-php55-dep"
		link_package "noarch" "cpanel-php56-dep"
	;;
	pxn-extras)
		link_package "noarch" "pxn-extras-stable"
		link_package "noarch" "pxn-extras-testing"
		link_package "noarch" "pxn-extras-private"
	;;
	x2vnc)
		link_package "x86_64" "x2vnc"
	;;
	shellscripts)
		link_package "noarch" "pxn-shellscripts"
	;;
	*)
		link_package "noarch" ${SELECTED}
	;;
	esac
	echo
}
function link_package {
	PREPEND_FILENAME=""
	if [ ! -z ${2} ]; then
		PREPEND_FILENAME="${2}-"
	fi
	latest_version "${PATH_YUM_TESTING}/${1}/${PREPEND_FILENAME}*.rpm" 2>/dev/null
	if [ -z ${LATEST_FILE} ]; then
		echo " * No rpm found for package: ${PACKAGE}"
		return 1
	fi
	local BASE_NAME=$(basename ${LATEST_FILE})
	find_arch_in_filename ${LATEST_FILE}
	rm -fv "${PATH_YUM_STABLE}/${ARCH}/${PREPEND_FILENAME}*.rpm"
	ln -svf "${LATEST_FILE}" "${PATH_YUM_STABLE}/${ARCH}/${BASE_NAME}" \
		|| return 1
	# update latest.rpm link
	if [ "${2}" == "pxn-extras-stable" ]; then
		ln -svf "${PATH_YUM_STABLE}/${ARCH}/${BASE_NAME}" "${PATH_YUM}/latest.rpm"
	fi
	echo ${BASE_NAME}
	PACKAGE_COUNT=$[$PACKAGE_COUNT + 1]
	return 0
}



list_packages
COLUMNS=1
PS3='Select a testing package to promote to stable: '
select SELECTED in "${PACKAGES[@]}" Quit ; do
	if [[ $REPLY == "q" ]] || [[ $REPLY == "Q" ]] || [[ $SELECTED == "Quit" ]]; then
		break
	fi
	if [ -z $SELECTED ] || [ -z $REPLY ]; then
		continue
	fi
	promote_package $SELECTED
	echo -ne "\n\n\n"
done
