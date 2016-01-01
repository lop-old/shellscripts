Name            : shellscripts
Summary         : A collection of commonly used shell scripts
Version         : 1.4.3.%{BUILD_NUMBER}
Release         : 1
BuildArch       : noarch
Provides        : pxnscripts
Requires        : perl, screen, bash, wget, rsync, zip, unzip, grep, tree, dialog, net-tools, dos2unix
Prefix          : %{_bindir}/shellscripts
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
	"${RPM_BUILD_ROOT}%{prefix}/" \
	"${RPM_BUILD_ROOT}%{prefix}/yum_repo/" \
	"${RPM_BUILD_ROOT}%{_sysconfdir}/profile.d/" \
		|| exit 1
# copy script files
for scriptfile in \
	aliases.sh \
	chmodr.sh \
	chownr.sh \
	common.sh \
	forever.sh \
	mklinkrel.sh \
	monitorhost.sh \
	profile.sh \
	sshkeygen.sh \
	timestamp.sh \
	pingssh.sh \
	progresspercent.sh \
	yesno.sh \
; do
	%{__install} -m 0555 \
		"%{SOURCE_ROOT}/src/${scriptfile}" \
		"${RPM_BUILD_ROOT}%{prefix}/${scriptfile}" \
			|| exit 1
done
# alias symlinks
ln -sf  "%{prefix}/chmodr.sh"           "${RPM_BUILD_ROOT}%{_bindir}/chmodr"
ln -sf  "%{prefix}/chownr.sh"           "${RPM_BUILD_ROOT}%{_bindir}/chownr"
ln -sf  "%{prefix}/forever.sh"          "${RPM_BUILD_ROOT}%{_bindir}/forever"
ln -sf  "%{prefix}/mklinkrel.sh"        "${RPM_BUILD_ROOT}%{_bindir}/mklinkrel"
ln -sf  "%{prefix}/monitorhost.sh"      "${RPM_BUILD_ROOT}%{_bindir}/monitorhost"
ln -sf  "%{prefix}/sshkeygen.sh"        "${RPM_BUILD_ROOT}%{_bindir}/sshkeygen"
ln -sf  "%{prefix}/timestamp.sh"        "${RPM_BUILD_ROOT}%{_bindir}/timestamp"
ln -sf  "%{prefix}/pingssh.sh"          "${RPM_BUILD_ROOT}%{_bindir}/pingssh"
ln -sf  "%{prefix}/pingssh.sh"          "${RPM_BUILD_ROOT}%{_bindir}/sshping"
ln -sf  "%{prefix}/progresspercent.sh"  "${RPM_BUILD_ROOT}%{_bindir}/progresspercent"
ln -sf  "%{prefix}/yesno.sh"            "${RPM_BUILD_ROOT}%{_bindir}/yesno"
ln -sf  "%{prefix}/iptop.pl"            "${RPM_BUILD_ROOT}%{_bindir}/iptop"
# create profile.d symlink
ln -sf  "%{prefix}/profile.sh"  "${RPM_BUILD_ROOT}%{_sysconfdir}/profile.d/pxn-profile.sh"
# readme
%{__install} -m 0555 \
	"%{SOURCE_ROOT}/README" \
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
%{prefix}/chmodr.sh
%{prefix}/chownr.sh
%{prefix}/common.sh
%{prefix}/forever.sh
%{prefix}/mklinkrel.sh
%{prefix}/monitorhost.sh
%{prefix}/profile.sh
%{prefix}/sshkeygen.sh
%{prefix}/timestamp.sh
%{prefix}/pingssh.sh
%{prefix}/progresspercent.sh
%{prefix}/yesno.sh
%{prefix}/iptop.pl
%{_bindir}/chmodr
%{_bindir}/chownr
%{_bindir}/forever
%{_bindir}/mklinkrel
%{_bindir}/monitorhost
%{_bindir}/sshkeygen
%{_bindir}/timestamp
%{_bindir}/pingssh
%{_bindir}/sshping
%{_bindir}/progresspercent
%{_bindir}/yesno
%{_bindir}/iptop
%{_sysconfdir}/profile.d/pxn-profile.sh
