clear



PWD=`pwd`
SOURCE_ROOT="${PWD}/pxn"
BUILD_ROOT="${PWD}/rpmbuild-root"
OUTPUT_DIR="${PWD}"
SPEC_FILE="shellscripts.spec"



# ensure rpmbuild tool is available
which rpmbuild >/dev/null || { echo "rpmbuild not installed - yum install rpmdevtools"; exit 1; }
# ensure .spec file exists
[[ -f "${SPEC_FILE}" ]] || { echo "Spec file ${SPEC_FILE} not found!"; exit 1; }



# build space
for dir in BUILD RPMS SOURCE SPECS SRPMS tmp ; do
	if [ -d "${BUILD_ROOT}/${dir}" ]; then
		rm -rf --preserve-root "${BUILD_ROOT}/${dir}" \
			|| exit 1
	fi
	mkdir -p "${BUILD_ROOT}/${dir}" \
		|| exit 1
done

# copy .spec file
cp "${SPEC_FILE}" "${BUILD_ROOT}/SPECS/" \
	|| exit 1



# build rpm
rpmbuild -bb \
	--define "_topdir ${BUILD_ROOT}" \
	--define "_tmppath ${BUILD_ROOT}/tmp" \
	--define "sourceroot ${SOURCE_ROOT}" \
	--define "_rpmdir ${OUTPUT_DIR}" \
	"${BUILD_ROOT}/SPECS/${SPEC_FILE}" \
		|| exit 1


