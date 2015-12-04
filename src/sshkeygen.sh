#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Auto-installs a key to a remote location.
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
# sshkeygen.sh
clear
echo



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
