#!/bin/bash
clear
echo



WORKERS=1



##################################################



source /usr/local/bin/pxn/repo_common.sh



function update_repo() {
	title "Refreshing ${1}"
	echo "Generating repo metadata.."
	echo
	echo "[ ${1} ]"
	mkdir -pv "${PATH_YUM}/${1}/noarch/" || exit 1
	mkdir -pv "${PATH_YUM}/${1}/i386/"   || exit 1
	mkdir -pv "${PATH_YUM}/${1}/x86_64/" || exit 1
	( cd "${PATH_YUM}/${1}/" && createrepo --workers=${WORKERS} . ) \
		|| { echo "Failed to update ${1} repo!"; exit 1; }
	echo
	echo "Finished updating ${1} !"
	echo
	echo
	# chown files
	CHOWNED=`chown -Rcf pxn. "${PATH_YUM}" | wc -l`
	if [ $CHOWNED -gt 0 ]; then
		echo "Updated owner of ${CHOWNED} files"
	fi
	echo
	echo "Finished updating ${1} !"
	echo
	echo
}



# update extras-testing symlinks
function update_symlinks_testing {
	title "Updating testing symlinks"
	list_packages
	PACKAGE_COUNT=0
	for PACKAGE in "${PACKAGES[@]}"; do
		echo "[ ${PACKAGE} ]"
		case ${PACKAGE} in
		GrowControl)
			link_package "gcServer"
			link_package "gcClient"
		;;
		java-dep)
			link_package "java-dep-jre"
			link_package "java-dep-jdk"
			link_package "java-dep-opn"
		;;
		cpanel-php-dep)
			link_package "cpanel-php54-dep"
			link_package "cpanel-php55-dep"
			link_package "cpanel-php56-dep"
		;;
		pxn-extras)
			link_package "pxn-extras-stable"
			link_package "pxn-extras-testing"
			link_package "pxn-extras-private"
		;;
		*)
			link_package
		;;
		esac
		echo
	done
	echo
	echo "Found [ ${PACKAGE_COUNT} ] testing package files"
	echo
	echo
}
function link_package {
	PREPEND_FILENAME=""
	if [ ! -z ${1} ]; then
		PREPEND_FILENAME="${1}-"
	fi
	latest_version "${PATH_DL}/${PACKAGE}/${PREPEND_FILENAME}*.rpm" 2>/dev/null
	if [ -z ${LATEST_FILE} ]; then
		echo " * No rpm found for package: ${PACKAGE}"
		return 1
	fi
	local BASE_NAME=$(basename ${LATEST_FILE})
	find_arch_in_filename ${LATEST_FILE}
	ln -svf "${LATEST_FILE}" "${PATH_YUM_TESTING}/${ARCH}/${BASE_NAME}" \
		|| return 1
	echo ${BASE_NAME}
	PACKAGE_COUNT=$[$PACKAGE_COUNT + 1]
	return 0
}



if [ -z ${1} ] || [ ${1} == "--help" ]; then
	echo
	echo "Updates the yum repositories hosted on a web server."
	echo
	echo "  --all          Update all repositories"
	echo "  --stable       Update only the stable repo"
	echo "  --testing      Update only the testing repo"
	echo "  --private      Update only the private repo"
	echo "  --symlinks     Update symlinks only"
	echo
	echo "Usage:  sh update.sh --all"
	echo
	exit 1
fi



# parse arguments
for i in "$@"; do
	case "$i" in
	--all)
		update_symlinks_testing
		update_repo "extras-stable"
		update_repo "extras-testing"
		update_repo "extras-private"
	;;
	--stable)
		update_repo "extras-stable"
	;;
	--testing)
		update_symlinks_testing
		update_repo "extras-testing"
	;;
	--private)
		update_repo "extras-private"
	;;
	--symlinks)
		update_symlinks_testing
	;;
	*)
		echo "Unknown argument: ${1}"
		exit 1
	;;
	esac
done

