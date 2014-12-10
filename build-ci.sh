# sh build-ci.sh  /home/pxn/www/dl/shellscripts  /home/pxn/www/yum/extras-testing/noarch


# load build_utils.sh script
if [ -e build_utils.sh ]; then
	source ./build_utils.sh
elif [ -e /usr/local/bin/pxn/build_utils.sh ]; then
	source /usr/local/bin/pxn/build_utils.sh
else
	wget https://raw.githubusercontent.com/PoiXson/shellscripts/master/pxn/build_utils.sh \
		|| exit 1
	source ./build_utils.sh
fi


PATH_DL="${1}"
PATH_YUM="${2}"


title "Build.."
( cd "${WORKSPACE}/" && sh build-rpm.sh --build-number ${BUILD_NUMBER} ) || exit 1


title "Deploy.."
cp -fv "${WORKSPACE}/pxnCommon"-*.noarch.rpm "${PATH_DL}/" || exit 1
latest_version "${PATH_DL}/pxnCommon-*.noarch.rpm"                    || exit 1
ln -fs "${PATH_DL}/${LATEST_FILE}" "${PATH_YUM}/pxnCommon.noarch.rpm" || exit 1

