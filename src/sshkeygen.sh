#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2016 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
## Released under the GPL 3.0
##
## Description: Auto-installs a key to a remote location.
##
## Install to location: /usr/bin/shellscripts
##
## Download the original from:
##   http://dl.poixson.com/shellscripts/
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
# sshkeygen.sh
clear
echo


#that aside, I always to -t ecsda -b 521 when using ssh-keygen nowadays
#http://nathanielhoag.com/blog/2014/05/26/automate-ssh-key-generation-and-deployment/
#ssh-keygen -b 4096 -t rsa -N ""


# generate a public key if needed
if [ -f ~/.ssh/id_rsa.pub ]; then
	echo "Using existing key.."
else
	echo "Generating a new key.."
	ssh-keygen || exit 1
fi

# public key exists?
if [ ! -f ~/.ssh/id_rsa.pub ]; then
	echo "Failed to generate a public key!" >&2
	exit 1
fi

chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

if [ -z ${1} ]; then
	echo "Key is ready to use :-)"
else
	# install pub key to remote host
	PORT=""
	if [[ ${2} == \-p* ]]; then
		PORT="${2}"
	fi
	ssh-copy-id -i ~/.ssh/id_rsa.pub "${1}" ${PORT} || exit 1
#	ssh "${1}" 'chmod 700 ~/.ssh && chmod 600 ~/.ssh/*' || exit 1
	echo "Key installed to ${1}"
fi
echo
