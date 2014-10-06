Name            : pxnShellScripts
Summary         : A collection of commonly used shell scripts
Version         : 1.0.4
Release         : %{RELEASE}
BuildArch       : noarch
Provides        : pxnscripts
Requires        : screen, wget, rsync
Prefix          : /usr/local/bin/pxn
%define _rpmfilename  %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm

Group		: Base System/System Tools
License		: (c) PoiXson
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
if [ -d "%{sourceroot}" ]; then
	echo "Found source workspace: %{sourceroot}"
else
	echo "Source workspace not found: %{sourceroot}"
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
# delete existing rpm
if [[ -f "%{_rpmdir}/%{name}-%{version}-%{release}.noarch.rpm" ]]; then
	%{__rm} -f "%{_rpmdir}/%{name}-%{version}-%{release}.noarch.rpm" \
		|| exit 1
fi
# create directories
%{__install} -d -m 0755 \
	"${RPM_BUILD_ROOT}%{prefix}" \
	"${RPM_BUILD_ROOT}%{_sysconfdir}/profile.d" \
		|| exit 1
# copy .sh files
for shfile in \
	aliases.sh \
	common.sh \
	mkln.sh \
	profile.sh \
	sshkeygen.sh \
	workspace_utils.sh \
	yesno.sh \
; do
	%{__install} -m 0755 \
		"%{sourceroot}/${shfile}" \
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
%defattr(644,-,-,755)
%{prefix}/aliases.sh
%{prefix}/common.sh
%{prefix}/mkln.sh
%{prefix}/profile.sh
%{prefix}/sshkeygen.sh
%{prefix}/workspace_utils.sh
%{prefix}/yesno.sh
%{_sysconfdir}/profile.d/pxn-profile.sh


