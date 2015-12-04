#!/bin/sh
clear
source /usr/bin/shellscripts/common.sh


function ctrl_c() {
	title 'Cancelled zfs install!'
	exit 1
}
trap ctrl_c INT


### required yum repos
# pxn
progresspercent 6 0
if [ ! -f /etc/yum.repos.d/pxn-stable.repo ]; then
	yum install http://yum.poixson.com/latest.rpm \
		|| exit 1
fi
progresspercent 6 1
# epel
if [ ! -f /etc/yum.repos.d/epel.repo ]; then
	yum install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm \
		|| exit 1
fi
progresspercent 6 2
# zfs-release
if [ ! -f /etc/yum.repos.d/zfs.repo ]; then
	yum install http://archive.zfsonlinux.org/epel/zfs-release.el7.noarch.rpm \
		|| exit 1
fi
progresspercent 6 3


### install packages
# this is what was missing, undocumented but needed
yum groupinstall Development\ tools
progress_percent 6 4
yum install zlib zlib-devel libuuid libuuid-devel \
	spl dkms kmod kmod-devel uuid uuid-devel perl \
	kernel-devel kernel-headers kernel-tools kernel-tools-libs-devel
progresspercent 6 5
# install zfs
yum install zfs || exit 1
progresspercent 6 6


newline
newline
zpool list || exit 1
newline
echo "Finished installing zfs!"
newline

