# sh build-ci.sh  --dl-path=/home/pxn/www/dl/shellscripts  --yum-path=/home/pxn/www/yum/extras-testing/noarch


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


NAME="pxn-shellscripts"
[ -z "${WORKSPACE}" ] && WORKSPACE=`pwd`
rm -vf "${WORKSPACE}/${NAME}"-*.noarch.rpm


title "Build.."
( cd "${WORKSPACE}/" && sh build-rpm.sh --build-number ${BUILD_NUMBER} ) || exit 1


title "Deploy.."
cp -fv "${WORKSPACE}/${NAME}"-*.noarch.rpm "${DL_PATH}/" || exit 1
latest_version "${DL_PATH}/${NAME}-*.noarch.rpm"                    || exit 1
ln -fs "${DL_PATH}/${LATEST_FILE}" "${YUM_PATH}/${NAME}.noarch.rpm" || exit 1

