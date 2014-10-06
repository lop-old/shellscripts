##===============================================================================
## Copyright (c) 2013-2014 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Common methods and utilities for git workspace scripts.
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
# workspace_utils.sh



# load common utils script
if [ -e common.sh ]; then
	source ./pxn_common.sh
elif [ -e /usr/local/bin/pxn/common.sh ]; then
	source /usr/local/bin/pxn/common.sh
else
	wget http://dl.poixson.com/scripts/pxn/common.sh
	source ./common.sh
fi
# load yesno.sh
if [ -e yesno.sh ]; then
	source ./yesno.sh
elif [ -e /usr/local/bin/pxn/yesno.sh ]; then
	source /usr/local/bin/pxn/yesno.sh
else
	wget http://dl.poixson.com/scripts/pxn/yesno.sh
	source ./yesno.sh
fi



GIT_PREFIX_HTTPS='https://github.com/'
GIT_PREFIX_SSH='git@github.com:'



# ask use https/ssh with git
function AskHttpsSsh() {
	if [ "$1" == "--https" ]; then
		export REPO_PREFIX=$GIT_PREFIX_HTTPS
		return 0
	elif [ "$1" == "--ssh" ]; then
		export REPO_PREFIX=$GIT_PREFIX_SSH
		return 0
	fi
	while true; do
		newline
		echo "https: read only access"
		echo "ssh: read/write access (permission required)"
		read -p "Would you like to use [h]ttps or [s]sh repo addresses? " answer
		newline
		case $answer in
			[Hh]* ) export REPO_PREFIX=$GIT_PREFIX_HTTPS; break;;
			[Ss]* ) export REPO_PREFIX=$GIT_PREFIX_SSH;   break;;
			* ) echo "Please answer H or S.";;
		esac
	done
}



# CheckoutRepo <dir_name> <repo_url>
function CheckoutRepo() {
	if [ ! -d ".git" ]; then
		mkdir -v .git
	fi
	if [ -d "$1" ] || [ -h "$1" ]; then
		echo "${1} repo already exists in workspace."
		(cd "${1}"; git pull origin master)
		newline
		return 1
	fi
	newline
	echo "Cloning ${1} repo.."
	git clone "${2}" "${1}"
	git config core.filemode false --git-dir="${1}"
	git config core.symlinks false --git-dir="${1}"
	newline
	return 0
}



function AskResources() {
	if [ "$1" == "--https" ] || [ "$1" == "--ssh" ] ||
			yesno "Would you like to download the required resources? [y/N] " --default no ; then
		if [ ! -d resources ]; then
			echo
			mkdir -v resources
		fi
		return $YES
	fi
	return $NO
}
function getResource() {
	title=$1
	filename=$2
	url=$3
	if [ -f "${filename}" ]; then
		return 0
	fi
	echo "Downloading ${title}.."
	wget -O "${filename}" "${url}"
	if [ ! -f "$filename" ]; then
		echoerr "Failed to download resource ${url}"
		return 1
	fi
	return 0
}
function unzipResource() {
	dir=$1
	filename=$2
	currentdir=`pwd`
	path="${currentdir}/${dir}${filename}"
	if ls "${path}" &> /dev/null; then
#	if [ ! -f "${path}" ]; then
		echoerr "Cannot unzip, missing file ${path}"
		return 1
	fi
	cd $dir
	unzip -o "${path}"
	cd "${currentdir}"
	return 0
}



# mkRelLink <target> <create_here> <link_name>
function mkRelLink() {
	# create in dir
	if [ ! -d ${1} ]; then
		echo "Source directory ${1} doesn\'t exist"
		return 1
	fi
	if [ ! -d ${2} ]; then
		echo "Target directory ${2} doesn\'t exist"
		return 1
	fi
	if [ -e ${2}/${3} ]; then
		echo "Symbolic link ${2} / ${3} already exists"
		return 0
	fi
	echo "Creating link ${2} / ${3}"
	# build repeating '../'
	LEVELS_DEEP=`echo $2 | tr '/' '\n' | wc -l`
	UP_DIRS=''
	for (( i=0; i<$LEVELS_DEEP; i++ )); do
		UP_DIRS=${UP_DIRS}'../'
	done
	cd ${2}
	ln -s ${UP_DIRS}${1} ${3}
	ls -l --color=auto ${3}
	cd ${UP_DIRS}
	newline
#	saved_path=`pwd`
#	cd $2
#	ln -s -r ${1} ${2}/${3}
#	ls -l --color=auto ${2}/${3}
#	cd $saved_path
	return 0
}



function Cleanup() {
	if [[ "$PWD" == /usr/local* ]]; then
		return
	fi
	rm -f -v ./workspace_utils.sh
	rm -f -v ./yesno.sh
}


