Name            : shellscripts
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
	xbuild.sh \
	common.sh \
	mklinkrel.sh \
	profile.sh \
	sshkeygen.sh \
	pingssh.sh \
	yesno.sh \
	yum_repo/.htaccess \
	repo_promote.sh \
	repo_update.sh \
; do
	%{__install} -m 0555 \
		"%{SOURCE_ROOT}/${shfile}" \
		"${RPM_BUILD_ROOT}%{prefix}/${shfile}" \
			|| exit 1
done
# alias symlinks
%{__install} -d -m 0555 "${RPM_BUILD_ROOT}%{_bindir}/" || exit 1
ln -sf  "%{prefix}/mklinkrel.sh"     "${RPM_BUILD_ROOT}%{_bindir}/mklinkrel"
ln -sf  "%{prefix}/sshkeygen.sh"     "${RPM_BUILD_ROOT}%{_bindir}/sshkeygen"
ln -sf  "%{prefix}/pingssh.sh"       "${RPM_BUILD_ROOT}%{_bindir}/pingssh"
ln -sf  "%{prefix}/pingssh.sh"       "${RPM_BUILD_ROOT}%{_bindir}/sshping"
ln -sf  "%{prefix}/xbuild.sh"        "${RPM_BUILD_ROOT}%{_bindir}/xbuild"
ln -sf  "%{prefix}/repo_promote.sh"  "${RPM_BUILD_ROOT}%{_bindir}/repo_promote"
ln -sf  "%{prefix}/repo_update.sh"   "${RPM_BUILD_ROOT}%{_bindir}/repo_update"
# create profile.d symlink
%{__install} -d -m 0755 "${RPM_BUILD_ROOT}%{_sysconfdir}/profile.d/" || exit 1
ln -sf  "%{prefix}/profile.sh"  "${RPM_BUILD_ROOT}%{_sysconfdir}/profile.d/pxn-profile.sh"
# readme
%{__install} -m 0555 \
	"%{SOURCE_ROOT}/../README" \
	"${RPM_BUILD_ROOT}%{prefix}/yum_repo/README.html" \
		|| exit 1



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
%{prefix}/xbuild.sh
%{prefix}/common.sh
%{prefix}/mklinkrel.sh
%{prefix}/profile.sh
%{prefix}/sshkeygen.sh
%{prefix}/pingssh.sh
%{prefix}/yesno.sh
%{prefix}/yum_repo/.htaccess
%{prefix}/repo_promote.sh
%{prefix}/repo_update.sh
%{_bindir}/mklinkrel
%{_bindir}/sshkeygen
%{_bindir}/pingssh
%{_bindir}/sshping
%{_bindir}/xbuild
%{_bindir}/repo_promote
%{_bindir}/repo_update
%{_sysconfdir}/profile.d/pxn-profile.sh
%{prefix}/yum_repo/README.html

