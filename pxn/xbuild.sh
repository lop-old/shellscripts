#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Build and deploy script for maven and rpm projects.
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
# xbuild.sh
clear
echo



PWD=`pwd`
if [[ "${PWD}" == "/usr/"* ]]; then
	echo "Cannot run build-mvn.sh script from this location."
	exit 1
fi
# load build utils script
if [ -e "${PWD}/build_utils.sh" ]; then
	source "${PWD}/build_utils.sh"
elif [ -e "/usr/local/bin/pxn/build_utils.sh" ]; then
	source "/usr/local/bin/pxn/build_utils.sh"
else
	wget -O "${PWD}/build_utils.sh" "https://raw.githubusercontent.com/PoiXson/shellscripts/master/pxn/build_utils.sh" \
		|| exit 1
	source "${PWD}/build_utils.sh"
fi



# load xbuild.conf file
if [ ! -f "${PWD}/xbuild.conf" ]; then
	echo "xbuild.conf file not found here"
	exit 1
fi
source "${PWD}/xbuild.conf"
if [ -z $BUILD_MVN ] || [ $BUILD_MVN == 0 ]; then
	BUILD_MVN=0
else
	BUILD_MVN=1
fi
if [ -z $BUILD_RPM ] || [ $BUILD_RPM == 0 ]; then
	BUILD_RPM=0
else
	BUILD_RPM=1
fi



# build number
if [[ -z ${BUILD_NUMBER} ]] || [[ "${BUILD_NUMBER}" == "x" ]]; then
	echo "Build number: <Not Set>"
else
	echo "Build number: ${BUILD_NUMBER}"
fi



# remove old target/ directory
if [ -d "${PWD}/target/" ]; then
	rm -Rvf "${PWD}/target/" || exit 1
	echo "Removed old target/ directory"
fi



# ==================================================
# build maven



if [ $BUILD_MVN == 1 ]; then

	# get build name from pom.xml
	if [ -z $BUILD_NAME ] && [ -f "${PWD}/pom.xml" ]; then
		BUILD_NAME=`grep -m1 -oP '<artifactId>\K.*?(?=<\/artifactId>)' ${PWD}/pom.xml`
	fi

	# build number
	if [[ ! -z $BUILD_NUMBER ]] && [[ "${BUILD_NUMBER}" != "x" ]]; then
		# replace version in pom.xml files
		TARGET=""
		for TARGET in "${POM_FILES[@]}"; do
			sedVersion "${PWD}/${TARGET}" || exit 1
		done
		TARGET=""
	fi

	# build version
	if [ -z $BUILD_VERSION ]; then
		BUILD_VERSION=`grep -m1 -oP '<version>\K.*?(?=<\/version>)' ${PWD}/pom.xml`
	fi

	title "MVN Build: ${BUILD_NAME} ${BUILD_VERSION}"

	# build with maven
	if [ -z "$MAVEN_GOALS" ]; then
		MAVEN_GOALS="clean install source:jar"
	fi
	MVN_FAIL=0
	mvn ${MAVEN_GOALS} || MVN_FAIL=1
	newline

	# restore original pom.xml
	if [[ ! -z $BUILD_NUMBER ]] && [[ "${BUILD_NUMBER}" != "x" ]]; then
		TARGET=""
		for TARGET in "${POM_FILES[@]}"; do
			restoreSed "${POM}/${TARGET}" || exit 1
		done
		TARGET=""
	fi

	if [ $MVN_FAIL == 1 ]; then
		echo "Failed to build maven project"
		exit 1
	fi
	MVN_FAIL=""

	newline
	newline
	newline

fi



# ==================================================
# build rpm



if [ $BUILD_RPM == 1 ]; then

	if [ -z $SPEC_FILE ] && [ ! -z $BUILD_NAME ]; then
		SPEC_FILE="${BUILD_NAME}.spec"
	fi

	if [ ! -f "${PWD}/${SPEC_FILE}" ]; then
		echo "Spec file ${SPEC_FILE} not found"
		exit 1
	fi
	echo "Found spec file: ${SPEC_FILE}"

	# ensure rpmbuild tool is available
	which rpmbuild >/dev/null || {
		echo "rpmbuild not installed - yum install rpmdevtools"
		exit 1
	}

	# build name
	if [ -z $BUILD_NAME ]; then
		BUILD_NAME=`grep Name ${PWD}/${SPEC_FILE} | sed 's/.*\://' | sed 's/ //g'`
	fi
	# build version
	if [ -z $BUILD_VERSION ]; then
		BUILD_VERSION=`grep Version ${PWD}/${SPEC_FILE} | sed 's/.*\://' | sed 's/ //g' | sed -e "s/%{BUILD_NUMBER}/${BUILD_NUMBER}/"`
	fi

	title "RPM Build: ${BUILD_NAME} ${BUILD_VERSION}"

	# create build space
	BUILD_ROOT="${PWD}/rpmbuild-root"
	for DIR in BUILD RPMS SOURCE SOURCES SPECS SRPMS tmp ; do
		if [ -d "${BUILD_ROOT}/${DIR}" ]; then
			rm -rf --preserve-root "${BUILD_ROOT}/${DIR}" \
				|| exit 1
		fi
		mkdir -p "${BUILD_ROOT}/${DIR}" || exit 1
	done
	cp -fv "${PWD}/${SPEC_FILE}" "${BUILD_ROOT}/SPECS/" \
		|| exit 1

	# build rpm
	if [ -z $RPM_SOURCE ]; then
		RPM_SOURCE=""
	fi
	rpmbuild -bb \
		--define="_topdir ${BUILD_ROOT}" \
		--define="_tmppath ${BUILD_ROOT}/tmp" \
		--define="SOURCE_ROOT ${PWD}/${RPM_SOURCE}" \
		--define="_rpmdir ${PWD}/target" \
		--define="BUILD_NUMBER ${BUILD_NUMBER}" \
		"${BUILD_ROOT}/SPECS/${SPEC_FILE}" \
			|| exit 1

	newline
	newline
	newline
fi



# ==================================================
# deploy



# list result files
echo "Results:"
LS_FAIL=0
TARGET=""
for TARGET in "${RESULT_FILES[@]}"; do
	TARGET=`echo "${TARGET}" | sed -e "s/<BUILD_NAME>/${BUILD_NAME}/"`
	TARGET=`echo "${TARGET}" | sed -e "s/<BUILD_VERSION>/${BUILD_VERSION}/"`
	echo -n "  "
	ls -1 "${PWD}/${TARGET}" || LS_FAIL=1
done
if [ $LS_FAIL == 1 ]; then
	echo "One or more built files are missing"
	exit 1
fi
LS_FAIL=""
TARGET=""



newline
newline
newline



# deploy
newline
newline
newline



echo "Finished building: ${BUILD_NAME} ${BUILD_VERSION}"
newline
newline
