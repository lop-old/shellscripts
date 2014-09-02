##===============================================================================
## Copyright (c) 2013-2014 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Installs pxn shell scripts.
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
# update.sh



source_url="http://dl.poixson.com/scripts/pxn/"



clear
echo
echo "Updating from: ${source_url}"
echo
echo



# get packages list
if [ -f install_packages.txt ]; then
	rm -f -v ./install_packages.txt
fi
wget "${source_url}install_packages.txt"
if [ ! -f install_packages.txt ]; then
	echo Failed to get packages list!
	exit 1
fi
packages=''
while read line; do
	if [ ! -z "${line}" ]; then
		packages="${packages} ${line}"
	fi
done < "./install_packages.txt"
# install packages
yum install $packages
rm -f ./install_packages.txt
echo
echo



# get file download list
if [ -f install_files.txt ]; then
	rm -f -v ./install_files.txt
fi
wget "${source_url}install_files.txt"
if [ ! -f install_files.txt ]; then
        echo "Failed to get file download list!"
        exit 1
fi
# download files
while read line; do
	if [ ! -z "${line}" ]; then
		if [ -f "/usr/local/bin/pxn/${line}" ]; then
			rm -f -v "/usr/local/bin/pxn/${line}"
			echo
		fi
		wget -O "/usr/local/bin/pxn/${line}" "${source_url}${line}"
		# failed to download
		if [ ! -f "/usr/local/bin/pxn/${line}" ]; then
			echo "Failed to download file ${source_url}${line}"
			exit 1
		fi
	fi
done < "./install_files.txt"
rm -f ./install_files.txt
chmod -c +x /usr/local/bin/pxn/*.sh
echo
echo



echo "Finished updating!"
echo


