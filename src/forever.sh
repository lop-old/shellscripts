#!/bin/sh
# http://code.fealdia.org/viewgit/?a=viewblob&p=scripts&h=cb138626cfd92c60e1292db3215b0712d2078127&hb=88158fc5a254a3050ba45edfa743d043b3373bb3&f=shell/forever
set -e

while true; do
	"$@"
done
