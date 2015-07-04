#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Build and deploy script for maven and rpm projects.
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
# xbuild.sh
REQUIRED_CONFIG_VERSION=4
clear
echo



PWD=`pwd`
if [[ "${PWD}" == "/usr/"* ]]; then
	echo "Cannot run xbuild.sh script from this location."
	exit 1
fi
# load common utils script
if [ -e "${PWD}/common.sh" ]; then
	source "${PWD}/common.sh"
elif [ -e "/usr/bin/shellscripts/common.sh" ]; then
	source "/usr/bin/shellscripts/common.sh"
else
	wget -O "${PWD}/common.sh" "https://raw.githubusercontent.com/PoiXson/shellscripts/master/pxn/common.sh" \
		|| exit 1
	source "${PWD}/common.sh"
fi



# parse arguments
while [ $# -ge 1 ]; do
	case $1 in
	--config=*)
		CONFIG_FILE="${1#*=}"
	;;
	--config)
		CONFIG_FILE="${1}"
	;;
	--build-number=*)
		BUILD_NUMBER="${1#*=}"
	;;
	--build-number)
		shift
		BUILD_NUMBER="${1}"
	;;
	--dl-path=*)
		FORCE_DL_PATH="${1#*=}"
	;;
	--dl-path)
		shift
		FORCE_DL_PATH="${1}"
	;;
	--yum-path=*)
		FORCE_YUM_PATH="${1#*=}"
	;;
	--yum-path)
		shift
		FORCE_YUM_PATH="${1}"
	;;
	*)
		echo "Unknown argument: ${1}"
		exit 1
	;;
	esac
	shift
done
# defaults
if [ -z ${CONFIG_FILE} ]; then
	CONFIG_FILE="${PWD}/xbuild.conf"
fi

# build number
if [[ -z ${BUILD_NUMBER} ]] || [[ "${BUILD_NUMBER}" == "x" ]]; then
	BUILD_NUMBER="x"
	echo "Build number: <Not Set>"
else
	echo "Build number: ${BUILD_NUMBER}"
fi

# find xbuild.conf file
if [ ! -f "${CONFIG_FILE}" ]; then
	newline
	echo "xbuild.conf file not found here!"
	if [ "${CONFIG_FILE}" != "${PWD}/xbuild.conf" ]; then
		echo "Location: ${CONFIG_FILE}"
	fi
	newline
	exit 1
fi



############################
### Check config version ###
############################



CheckConfigVersion() {
	if [[ -z $CONFIG_VERSION ]] || [[ $CONFIG_VERSION -ne $REQUIRED_CONFIG_VERSION ]]; then
		echo 'xbuild.conf is outdated!'
		echo '  config version: ${CONFIG_VERSION}'
		echo '  required version: ${REQUIRED_CONFIG_VERSION}'
		exit 1
	fi
}



##########################
### Read composer.json ###
##########################



ReadVersionFromComposer() {
	CheckConfigVersion
	BUILD_VERSION=`cat composer.json | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["version"]'`
}



#################
### sed Files ###
#################



SED_FILES=()



# replace version/build number in a file
sedVersion() {
	CheckConfigVersion
	[ $BUILD_FAILED != false ] && return 1
	[[ $# -eq 0 ]]                 && return 0
	[[ -z ${BUILD_NUMBER} ]]       && return 0
	[[ "${BUILD_NUMBER}" == "x" ]] && return 0
	# multiple arguments
	if [[ $# -gt 1 ]]; then
		local count=$#
		local i
		for (( i=0; i<$count; i++ )); do
			sedVersion $1 || {
				restoreSed
				return 1
			}
			shift
		done
		newline
		newline
		newline
		return 0
	fi
	# single argument
	local FILENAME="${1}"
	SED_FILES+=("${FILENAME}")
	sed -i.original "s@x-SNAPSHOT@${BUILD_NUMBER}-SNAPSHOT@" "${FILENAME}" || {
		echo "Failed to sed a file! ${FILENAME}"
		restoreSed "${FILENAME}"
		return 1
	}
	sed -i "s@x-FINAL</version>@${BUILD_NUMBER}-FINAL</version>@" "${FILENAME}" || {
		echo "Failed to sed a file! ${FILENAME}"
		restoreSed "${FILENAME}"
		return 1
	}
	sed -i "s@x</version>@${BUILD_NUMBER}</version>@" "${FILENAME}" || {
		echo "Failed to sed a file! ${FILENAME}"
		restoreSed "${FILENAME}"
		return 1
	}
	sed -i "s/\.x$/\.${BUILD_NUMBER}/" "${FILENAME}" || {
		echo "Failed to sed a file! ${FILENAME}"
		restoreSed "${FILENAME}"
		return 1
	}
	echo "Sed file: ${FILENAME}"
	return 0
}
restoreSed() {
	# restore all
	if [[ $# -eq 0 ]]; then
		local count=${#SED_FILES[@]}
		local i
		local FAILED
		for (( i=$count-1; i>=0; i=i-1 )); do
			restoreSed "${SED_FILES[$i]}" || FAILED=true
			unset SED_FILES[$i]
		done
		newline
		newline
		newline
		return $FAILED
	fi
	# multiple arguments
	if [[ $# -gt 1 ]]; then
		local FILENAME
		local FAILED
		for FILENAME in "${@}"; do
			restoreSed "${FILENAME}" || FAILED=true
		done
		newline
		newline
		newline
		return $FAILED
	fi
	local FILENAME="${1}"
	if [ -f "${FILENAME}.original" ]; then
		echo "Restore sed: ${FILENAME}"
		mv -fv "${FILENAME}.original" "${FILENAME}" || {
			echo "Failed to restore a sed file! ${FILENAME}"
			return 1
		};
	fi
	return 0
}



#####################
### Build Methods ###
#####################



BUILD_NAME=''
BUILD_VERSION=''
BUILD_FAILED=false



# Maven
BuildMVN() {
	CheckConfigVersion
	[ $BUILD_FAILED != false ] && return 1
	# ensure maven tool is available
	which mvn >/dev/null || {
		BUILD_FAILED=true
		echo "Maven not installed - yum install maven"
		return 1
	}
	local MVN_GOALS=''
	local MVN_POM=''
	# parse arguments
	while [ $# -ge 1 ]; do
		case $1 in
		GOALS)
			shift
			MVN_GOALS="${1}"
		;;
		*)
			BUILD_FAILED=true
			echo "Unknown argument: ${1}"
			return 1
		;;
		esac
		shift
	done
	# defaults
	if [ -z "$MVN_GOALS" ]; then
		MVN_GOALS="clean install source:jar"
	fi
	if [[ -z $MVN_POM ]]; then
		MVN_POM="${PWD}/pom.xml"
	elif [ -f "${PWD}/${MVN_POM}" ]; then
		MVN_POM="${PWD}/${MVN_POM}"
	fi

	# pom file exists
	if [ ! -f "${MVN_POM}" ]; then
		BUILD_FAILED=true
		echo "Pom file ${MVN_POM} not found!"
		return 1
	fi
	echo "Found pom file: ${MVN_POM}"

	# try getting info from pom file
	if [ -f "${MVN_POM}" ]; then
		# build name
		if [[ -z $BUILD_NAME ]] && [; then
			BUILD_NAME=`grep -m1 -oP '<artifactId>\K.*?(?=<\/artifactId>)' ${MVN_POM}`
		fi
		# build version
		if [ -z $BUILD_VERSION ]; then
			BUILD_VERSION=`grep -m1 -oP '<version>\K.*?(?=<\/version>)' ${MVN_POM}`
		fi
	fi

	title "MVN Build: ${BUILD_NAME} ${BUILD_VERSION}"

	# build with maven
	mvn ${MVN_GOALS} || { \
		BUILD_FAILED=true
		echo "Failed to build maven project!"
		return 1
	}
	newline
	newline
	newline
	return 0
}



# Composer
BuildComposer() {
	CheckConfigVersion
	[ $BUILD_FAILED != false ] && return 1
	# ensure composer is available
	which composer >/dev/null || {
		BUILD_FAILED=true
		echo "Composer not installed - yum install php-composer"
		return 1
	}
	# default to /
	if [[ $# -eq 0 ]]; then
		BuildComposer '/'
		return $?
	fi
	RESULT_INSTALLS=()
	title "Composer Install: ${BUILD_NAME} ${BUILD_VERSION}"
	for DIR in "${@}"; do
		newline
		newline
		echo "Composer Install: ${DIR}"
		if [ ! -d "${PWD}/${DIR}" ]; then
			BUILD_FAILED=true
			echo "Composer workspace not found: ${DIR}"
			return 1
		fi
		if [ ! -f "${PWD}/${DIR}/composer.json" ]; then
			BUILD_FAILED=true
			echo "composer.json file not found in workspace: ${DIR}"
			return 1
		fi
		# composer install
		${BIN_PHP} /usr/bin/composer install -v --working-dir "${PWD}/${DIR}" || {
			BUILD_FAILED=true
			echo "Failed to install with composer: ${DIR}"
			return 1
		}
		RESULT_INSTALLS+=("${DIR}")
		# run phpunit if available
		if [ -f "${PWD}/${DIR}/vendor/bin/phpunit" ]; then
			${BIN_PHP} "${PWD}/${DIR}/vendor/bin/phpunit" \
				|| exit 1
		fi
	done
	newline
	newline
	echo "Finished Composer Installs:"
	for RESULT in "${RESULT_INSTALLS[@]}"; do
		echo "  ${RESULT}"
	done
	newline
	newline
	newline
	return 0
}



# Box Phar
BuildPhar() {
	CheckConfigVersion
	[ $BUILD_FAILED != false ] && return 1
	# ensure box is available
	which box >/dev/null || {
		BUILD_FAILED=true
		echo "Box not installed - yum install php-composer"
		return 1
	}
	# default to /
	if [[ $# -eq 0 ]]; then
		BuildPhar '/'
		return $?
	fi
	RESULT_INSTALLS=()
	title "Phar Box: ${BUILD_NAME} ${BUILD_VERSION}"
	for DIR in "${@}"; do
		newline
		newline
		echo "Box Build: ${DIR}"
		if [ ! -d "${PWD}/${DIR}" ]; then
			BUILD_FAILED=true
			echo "Box workspace not found: ${DIR}"
			return 1
		fi
		if [ ! -f "${PWD}/${DIR}/box.json" ]; then
			BUILD_FAILED=true
			echo "box.json file not found in workspace: ${DIR}"
			return 1
		fi
		# composer install
		pushd "${PWD}/${DIR}"
		${BIN_PHP} /usr/bin/box build -v || {
			BUILD_FAILED=true
			echo "Failed to build .phar with box: ${DIR}"
			return 1
		}
		popd
		RESULT_INSTALLS+=("${DIR}")
	done
	newline
	newline
	echo "Finished Phar Box Builds:"
	for RESULT in "${RESULT_INSTALLS[@]}"; do
		echo "$RESULT"
	done
	newline
	newline
	newline
	return 0
}



# RPM
BuildRPM() {
	CheckConfigVersion
	[ $BUILD_FAILED != false ] && return 1
	# ensure rpmbuild tool is available
	which rpmbuild >/dev/null || {
		BUILD_FAILED=true
		echo "rpmbuild not installed - yum install rpmdevtools"
		return 1
	}
	local RPM_SPEC=''
	local RPM_SOURCES=()
	local ARCH=''
	# parse arguments
	while [ $# -ge 1 ]; do
		case $1 in
		SPEC)
			shift
			RPM_SPEC="${1}"
		;;
		SOURCE)
			shift
			RPM_SOURCES+=("${1}")
		;;
		ARCH)
			shift
			ARCH="${1}"
		;;
		*)
			BUILD_FAILED=true
			echo "Unknown argument: ${1}"
			return 1
		;;
		esac
		shift
	done
	# defaults
	if [[ -z $RPM_SPEC ]] && [[ ! -z $BUILD_NAME ]]; then
		RPM_SPEC="${BUILD_NAME}.spec"
	fi
	if [ -z ${ARCH} ]; then
		ARCH='noarch'
	fi

	# spec file exists
	if [ ! -f "${RPM_SPEC}" ]; then
		BUILD_FAILED=true
		echo "Spec file ${RPM_SPEC} not found"
		return 1
	fi
	echo "Found spec file: ${RPM_SPEC}"

	# try getting info from spec file
	if [ -f "${PWD}/${RPM_SPEC}" ]; then
		# build name
		if [ -z $BUILD_NAME ]; then
			BUILD_NAME=`grep Name ${PWD}/${RPM_SPEC} | sed 's/.*\://' | sed 's/ //g'`
		fi
		# build version
		if [ -z $BUILD_VERSION ]; then
			BUILD_VERSION=`grep Version ${PWD}/${RPM_SPEC} | sed 's/.*\://' | sed 's/ //g' | sed -e "s/%{BUILD_NUMBER}/${BUILD_NUMBER}/"`
		fi
	fi

	title "RPM Build: ${BUILD_NAME} ${BUILD_VERSION}"

	# create build space
	BUILD_ROOT="${PWD}/rpmbuild-root"
	for DIR in BUILD RPMS SOURCE SOURCES SPECS SRPMS tmp ; do
		if [ -d "${BUILD_ROOT}/${DIR}" ]; then
			rm -rf --preserve-root "${BUILD_ROOT}/${DIR}" || {
				BUILD_FAILED=true
				return 1
			}
		fi
		mkdir -p "${BUILD_ROOT}/${DIR}" || {
			BUILD_FAILED=true
			return 1
		}
	done
	cp -fv "${PWD}/${RPM_SPEC}" "${BUILD_ROOT}/SPECS/" || {
		BUILD_FAILED=true
		return 1
	}

	# download source files
	if [ ! -z $RPM_SOURCES ]; then
		for URL in "${RPM_SOURCES[@]}"; do
			wget -P "${BUILD_ROOT}/SOURCES/" "${URL}" || {
				BUILD_FAILED=true
				echo "Failed to download source! ${URL}"
				return 1
			}
			echo "URL: "$URL
		done
		newline
		newline
		newline
	fi

	# build rpm
	if [ -z $RPM_SOURCE ]; then
		_RPM_SOURCE="${PWD}"
	else
		_RPM_SOURCE="${PWD}/${RPM_SOURCE}"
	fi
	rpmbuild -bb \
		--target ${ARCH} \
		--define="_topdir ${BUILD_ROOT}" \
		--define="_tmppath ${BUILD_ROOT}/tmp" \
		--define="SOURCE_ROOT ${_RPM_SOURCE}" \
		--define="_rpmdir ${PWD}/target" \
		--define="BUILD_NUMBER ${BUILD_NUMBER}" \
		"${BUILD_ROOT}/SPECS/${RPM_SPEC}" \
			|| {
		BUILD_FAILED=true
		return 1
	}
	newline
	newline
	newline
	return 0
}



##############
### Deploy ###
##############



LAST_TAG_FILE="${JENKINS_HOME}/jobs/${JOB_NAME}/last_tag"
LAST_TAG_DEPLOYED=''
LATEST_TAG=''
CheckForNewTag() {
	# running from jenkins
	if [[ -z $WORKSPACE ]] || [[ -z $JENKINS_HOME ]] || [[ -z $JOB_NAME ]]; then
		newline
		echo 'Jenkins not detected; skipping stable deploy'
		newline
		return 1
	fi
	# look for .git/
	if [ ! -d "${WORKSPACE}/.git/" ]; then
		newline
		echo '.git/ directory not found; skipping stable deploy'
		newline
		return 1
	fi
	# load last_tag file
	if [ -f $LAST_TAG_FILE ]; then
		LAST_TAG_DEPLOYED=`cat "${LAST_TAG_FILE}"`
	fi
	# get latest tag
	pushd "${WORKSPACE}"
		LATEST_TAG=`git describe --abbrev=40 --tags`
	popd
	# no tags found
	if [ -z $LATEST_TAG ]; then
		newline
		echo 'No tags found to deploy stable; skipping stable deploy'
		newline
		return 1
	fi
	# new stable to deploy
	if [[ -z $LAST_TAG_DEPLOYED ]] || [[ "${LAST_TAG_DEPLOYED}" != "${LATEST_TAG}" ]]; then
		DEPLOY_STABLE="${LATEST_TAG}"
		title "Deploying stable tag: ${LATEST_TAG}"
	fi
	echo "Last tag deployed: ${LAST_TAG_DEPLOYED}"
	echo "Latest tag found:  ${LATEST_TAG}"
	return 0
}
UpdateLastTagFile() {
	if [ -z $DEPLOY_STABLE ]; then
		return 1
	fi
	# ensure valid file path
	if echo "${LAST_TAG_FILE}" | grep -q '//' ; then
		return 1
	fi
	newline
	echo "${DEPLOY_STABLE}" > "${LAST_TAG_FILE}" || { \
		title '!!! Failed to update last_tag file !!!'; exit 1; }
	echo "Updated last_tag file to: ${DEPLOY_STABLE}"
	newline
	return 0
}



DeployFiles() {
	CheckConfigVersion
	[ $BUILD_FAILED != false ] && return 1
	# list result files
	newline
	newline
	echo "Results:"
	local LS_FAIL=false
	local LS_FOUND=false
	local TARGET=''
	if [[ $# -eq 0 ]]; then
		echo 'No files configured to deploy.'
		return 0
	fi
	RESULT_FILES=()
	local count=$#
	local i
	for (( i=0; i<$count; i++ )); do
		TARGET="${1}"
		shift
		TARGET=`echo "${TARGET}" | sed -e "s/<BUILD_NAME>/${BUILD_NAME}/"`
		TARGET=`echo "${TARGET}" | sed -e "s/<BUILD_VERSION>/${BUILD_VERSION}/"`
		TARGET=`echo "${TARGET}" | sed -e "s/<BUILD_NUMBER>/${BUILD_NUMBER}/"`
		echo -n "  "
		ls -1 "${PWD}/${TARGET}" || LS_FAIL=true
		if [ $LS_FAIL == false ]; then
			LS_FOUND=true
			RESULT_FILES+=("${TARGET}")
		fi
	done
	if [ $LS_FAIL == true ] || [ $LS_FOUND == false ]; then
		newline
		BUILD_FAILED=true
		echo "One or more build result files are missing!"
		return 1
	fi
	unset LS_FAIL
	unset LS_FOUND
	unset TARGET
	newline
	newline
	newline

	# load xbuild-deploy.conf
	if  searchConfig "xbuild-deploy.conf" 4  ; then
		title "Deploy: ${BUILD_NAME} ${BUILD_VERSION}"
	else
		echo "Deploy has been skipped.."
		return 0
	fi
	CheckForNewTag
	if [ -z $XBUILD_PATH_DOWNLOADS ]; then
		BUILD_FAILED=true
		echo "XBUILD_PATH_DOWNLOADS not set in xbuild-deploy.conf"
		return 1
	fi

	# ensure deploy dirs exist
	if [ ! -d "${XBUILD_PATH_DOWNLOADS}" ]; then
		mkdir -pv "${XBUILD_PATH_DOWNLOADS}/"   || {
			BUILD_FAILED=true
			return 1
		}
	fi
	if [ ! -d "${XBUILD_PATH_YUM_TESTING}" ]; then
		mkdir -pv "${XBUILD_PATH_YUM_TESTING}/" || {
			BUILD_FAILED=true
			return 1
		}
	fi
	if [ ! -d "${XBUILD_PATH_YUM_STABLE}" ]; then
		mkdir -pv "${XBUILD_PATH_YUM_STABLE}/"  || {
			BUILD_FAILED=true
			return 1
		}
	fi

	# remove old versions from yum
	TARGET=""
	echo "Removing old rpm versions.."
	for TARGET in "${RESULT_FILES[@]}"; do
		if [[ "${TARGET}" == *".rpm" ]]; then
			TARGET=`echo "${TARGET}" | sed -e "s/${BUILD_VERSION}/*/"`
			FILENAME=`echo "${TARGET}" | sed 's/.*\///' | sed 's/ //g'`
			if [ ! -z $FILENAME ]; then
				echo "${FILENAME}"
				echo -n '  '; ls -l  "${XBUILD_PATH_YUM_TESTING}/"${FILENAME} 2>/dev/null
				echo -n '  '; rm -fv --preserve-root "${XBUILD_PATH_YUM_TESTING}/"${FILENAME}
			fi
		fi
	done
	unset TARGET
	newline

	# copy and symlink rpm's
	TARGET=""
	echo "Deploying new version.."
	for TARGET in "${RESULT_FILES[@]}"; do
		TARGET=`echo "${TARGET}" | sed -e "s/<BUILD_NAME>/${BUILD_NAME}/"`
		TARGET=`echo "${TARGET}" | sed -e "s/<BUILD_VERSION>/${BUILD_VERSION}/"`
		TARGET=`echo "${TARGET}" | sed -e "s/<BUILD_NUMBER>/${BUILD_NUMBER}/"`
		FILENAME=`echo "${TARGET}" | sed 's/.*\///' | sed 's/ //g'`

		# copy to dl
		echo -n "cp  "
		cp -fv "${PWD}/${TARGET}" "${XBUILD_PATH_DOWNLOADS}/" || {
			BUILD_FAILED=true
			return 1
		}

		# symlink rpm to yum
		if [[ "${FILENAME}" == *".rpm" ]]; then
			echo -n "ln  "
			ln -fsv "${XBUILD_PATH_DOWNLOADS}/${FILENAME}" "${XBUILD_PATH_YUM_TESTING}/${FILENAME}"
			# symlink rpm to yum stable
			if [ ! -z $DEPLOY_STABLE ]; then
				echo -n "st  "
				cp -fv "${XBUILD_PATH_DOWNLOADS}/${FILENAME}" "${XBUILD_PATH_YUM_STABLE}/${FILENAME}"
			fi
		fi

	done
	unset TARGET
	# update last_tag file
	UpdateLastTagFile
	newline
	newline
	newline
	return 0
}



BuildFinished() {
	newline
	if [ $BUILD_FAILED != false ]; then
		echo "Build Failed!  ${BUILD_NAME} ${BUILD_VERSION}"
		newline
		exit 1
	fi
	echo "Finished Building!  ${BUILD_NAME} ${BUILD_VERSION}"
	newline
	newline
	newline
	return 0
}



###################
### Load Config ###
###################



# remove old target/ directory
if [ -d "${PWD}/target/" ]; then
	rm -Rvf --preserve-root "${PWD}/target/" || exit 1
fi

# load xbuild.conf and start building
newline
newline
newline
source "${PWD}/xbuild.conf"

# old xbuild.conf method not used
if [ ! -z $BUILD_MVN ] || [ ! -z $BUILD_RPM ]; then
	newline
	echo '====================================================='
	echo "== This project's xbuild.conf needs to be updated! =="
	echo '====================================================='
	newline
	exit 1
fi

BuildFinished

