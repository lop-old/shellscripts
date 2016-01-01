#!/bin/bash
# Copyright (c) 2007 Heikki Hokkanen <hoxu@users.sf.net>
# GPL
set -e

format="%Y-%m-%d %H:%M:%S"
if [ $# -gt 0 ]; then
	format="$1"
fi

while read a; do
	echo $(date "+$format") $a
done
