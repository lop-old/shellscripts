Name            : pxn-shellscripts
Summary         : A collection of commonly used shell scripts
Version         : 1.3.%{BUILD_NUMBER}
Release         : 1
BuildArch       : noarch
Provides        : pxnscripts
Requires        : screen, bash, wget, rsync, zip, unzip, grep
Prefix          : /usr/local/bin/pxn
%define _rpmfilename  %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm

Group           : Base System/System Tools
License         : (c) PoiXson
Packager        : PoiXson <support@poixson.com>
URL             : http://poixson.com/

%description
A collection of commonly used shell scripts for CentOS and Fedora.



# avoid centos 5/6 extras processes on contents (especially brp-java-repack-jars)
%define __os_install_post %{nil}

# disable debug info
# % define debug_package %{nil}



### Prep ###
%prep
echo
echo "Prep.."
# check for existing workspace
if [ -d "%{SOURCE_ROOT}" ]; then
	echo "Found source workspace: %{SOURCE_ROOT}"
else
	echo "Source workspace not found: %{SOURCE_ROOT}"
	exit 1
fi
echo
echo



### Build ###
%build



### Install ###
%install
echo
echo "Install.."
# delete existing rpm's
%{__rm} -fv "%{_rpmdir}/%{name}-"*.noarch.rpm
# create directories
%{__install} -d -m 0755 \
	"${RPM_BUILD_ROOT}%{prefix}" \
	"${RPM_BUILD_ROOT}%{prefix}/yum_repo" \
	"${RPM_BUILD_ROOT}%{_sysconfdir}/profile.d" \
		|| exit 1
# copy .sh files
for shfile in \
	aliases.sh \
	build_utils.sh \
	common.sh \
	mklinkrel.sh \
	profile.sh \
	sshkeygen.sh \
	pingssh.sh \
	yesno.sh \
	yum_repo/.htaccess \
	yum_repo/promote.sh \
	yum_repo/update.sh \
; do
	%{__install} -m 0555 \
		"%{SOURCE_ROOT}/${shfile}" \
		"${RPM_BUILD_ROOT}%{prefix}/${shfile}" \
			|| exit 1
done
# create profile.d symlink
pushd "${RPM_BUILD_ROOT}%{_sysconfdir}/profile.d"
ln -sf "%{prefix}/profile.sh" "pxn-profile.sh" \
	|| exit 1
popd



%check



%clean
if [ ! -z "%{_topdir}" ]; then
	%{__rm} -rf --preserve-root "%{_topdir}" \
		|| echo "Failed to delete build root!"
fi



### Files ###
%files
%defattr(-,root,root,-)
%{prefix}/aliases.sh
%{prefix}/build_utils.sh
%{prefix}/common.sh
%{prefix}/mklinkrel.sh
%{prefix}/profile.sh
%{prefix}/sshkeygen.sh
%{prefix}/pingssh.sh
%{prefix}/yesno.sh
%{prefix}/yum_repo/.htaccess
%{prefix}/repo_promote.sh
%{prefix}/repo_update.sh
%{_sysconfdir}/profile.d/pxn-profile.sh

