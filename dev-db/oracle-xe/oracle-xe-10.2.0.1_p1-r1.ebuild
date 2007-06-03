# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils rpm check-reqs

IUSE="hardened"

MY_PV="${PV/_p/-}.0"
MY_P="${PN}-${MY_PV}.i386"

MIN_RAM="512"
MIN_SWAP="1024"

DESCRIPTION="Oracle 10g Express Edition for Linux"
HOMEPAGE="http://www.oracle.com/technology/software/products/database/xe/htdocs/102xelinsoft.html"
SRC_URI="${PN}-univ-${MY_PV}.i386.rpm"

LICENSE="OTN"
SLOT="0"
KEYWORDS="~x86"
RESTRICT="fetch"

S="${WORKDIR}"

RDEPEND=">=dev-libs/libaio-0.3.96
	sys-devel/bc
	!dev-db/oracle-instantclient-basic
	!dev-db/oracle-instantclient-jdbc
	!dev-db/oracle-instantclient-sqlplus"

DEPEND="${RDEPEND}"

ORACLEHOME="/usr/lib/oracle/xe/app/oracle/product/10.2.0/server"
ORACLE_OWNER="oraclexe"
ORACLE_GROUP="dba"
ORACLE_SID="XE"

pkg_nofetch() {
	eerror
	eerror "Please go to:"
	eerror "  ${HOMEPAGE}"
	eerror "and download the Oracle 10g Express Edition package."
	eerror "After downloading it, put the rpm into:"
	eerror "  ${DISTDIR}"
	eerror
}

src_unpack() {
	rpm_src_unpack
}

pkg_setup() {

	# Oracle XE is only for x86, so we need to filter all the other archs
	# TODO: instead to manualy filter the archs into the ebuild
	#       it's better to mask the package for all the gentoo profiles
	#       except the x86 one
	if !(use x86 || use amd64 || use x86_fbsd) ; then
		eerror "sorry, but the Oracle 10g Express Edition Database"
		eerror "can be executed only on x86 archs."
		ebeep 3
		die
	fi

	# try to satisfy all the minimun requirements
	CHECKREQS_MEMORY="${MIN_RAM}"
	CHECKREQS_DISK_BUILD="512"
	CHECKREQS_DISK_USR="2560"
	
	# make the requirements checking a fatal error
	CHECKREQS_ACTION="warning"
	
	check_reqs

	if use hardened; then
		ewarn
		ewarn "Oracle XE and hardened do not mix very well, USE AT YOUR OWN RISK!"
		ewarn
		ebeep
	fi

	einfo "checking for ${ORACLE_GROUP} group..."
	enewgroup ${ORACLE_GROUP}
	einfo "checking for ${ORACLE_OWNER} user..."
	enewuser ${ORACLE_OWNER} -1 /bin/bash /usr/lib/oracle/xe ${ORACLE_GROUP}
}

src_install() {

	# these dirs are necessary for the oracle_configure.sh script,
	# otherwise the script report a lot of errors due to bad paths
	ebegin "Fixing missing Server log dir/files"
		mkdir -p ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/log/
		chmod 700 ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/log/
		touch ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/log/CloneRmanRestore.log
		touch ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/log/cloneDBCreation.log
		touch ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/log/postScripts.log
		touch ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/log/postDBCreation.log
		chown -R ${ORACLE_OWNER}:${ORACLE_GROUP} ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/log/
		
		mkdir -p ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/rdbms/log
		chmod 700 ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/rdbms/log
		chown -R ${ORACLE_OWNER}:${ORACLE_GROUP} ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/rdbms/log
		ebeep 25
	eend $?
	
	ebegin "Fixing parameter file: initXE.ora"
		cp -ar ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/dbs/init.ora ${WORKDIR}/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/dbs/initXE.ora
	eend $?

	ebegin "Installation process"
		cp -ar "${WORKDIR}/usr" "${D}"
		exeinto ${ORACLEHOME}/bin
		doexe "${FILESDIR}/oracle_configure.sh"
		doinitd "${FILESDIR}/oracle-xe"
	eend $?

	ebegin "Create Oracle environment file"
		doenvd "${FILESDIR}/99oracle"
		dosed "s:%ORACLE_HOME%:${ORACLEHOME}:g" /etc/env.d/99oracle
		dosed "s:%ORACLE_SID%:${ORACLE_SID}:g" /etc/env.d/99oracle
		dosed "s:%ORACLE_OWNER%:${ORACLE_OWNER}:g" /etc/env.d/99oracle
	eend $?

	# snafu... (remove; sparc binaries on a x86 are pretty useless)
	ebegin "Removing useless SPARC binaries"
		[[ -n "$(file "${D}${ORACLEHOME}/lib/hsdb_ora.so" 2>/dev/null | grep SPARC)" ]] && \
			rm -f "${D}${ORACLEHOME}/lib/hsdb_ora.so" 2>/dev/null
	eend $?

	# fix NULL DT_RPATH
	ebegin "Fixing DT_RPATH issues..."
		TMPDIR="/ade" scanelf -XrR "${D}${ORACLEHOME}/lib" &>/dev/null
	eend $?
}

pkg_postinst() {
	einfo
	einfo "The Oracle 10g Express Edition Database has been installed."
	einfo
	elog "You might want to run:"
	elog "  ebuild /var/db/pkg/${CATEGORY}/${PF}/${PF}.ebuild config"
	elog "if this is a new install."
#	einfo
#	elog "To configure oracle-xe before first use and to adjust"
#	elog "kernel parameters, run"
#	elog "  ${ORACLEHOME}/bin/oracle_configure.sh"
#	einfo
}

pkg_config() {
	einfo "Checking kernel parameters..."
	einfo

	# Check and Update Kernel parameters
	semmsl=`cat /proc/sys/kernel/sem | awk '{print $1}'`
	semmns=`cat /proc/sys/kernel/sem | awk '{print $2}'`
	semopm=`cat /proc/sys/kernel/sem | awk '{print $3}'`
	semmni=`cat /proc/sys/kernel/sem | awk '{print $4}'`
	shmmax=`cat /proc/sys/kernel/shmmax`
	shmmni=`cat /proc/sys/kernel/shmmni`
	shmall=`cat /proc/sys/kernel/shmall`
	filemax=`cat /proc/sys/fs/file-max`
	ip_local_port_range_lb=`cat /proc/sys/net/ipv4/ip_local_port_range | awk '{print $1}'`
	ip_local_port_range_ub=`cat /proc/sys/net/ipv4/ip_local_port_range | awk '{print $2}'`

	change=no
	if [ $semmsl -lt 250 ]; then
		semmsl=250
		change=yes
	fi

	if [ $semmns -lt 32000 ]; then
		semmns=32000
		change=yes
	fi

	if [ $semopm -lt 100 ];	then
		semopm=100
		change=yes
	fi

	if [ $semmni -lt 128 ]; then
		semmni=128
		change=yes
	fi

	if [ "$change" != "no" ]; then
		einfo "kernel.sem="$semmsl $semmns $semopm $semmni""
	fi

	if [ $shmmax -lt 536870912 ]; then
		einfo "kernel.shmmax="536870912""
		change=yes
	fi

	if [ $shmmni -lt 4096 ]; then
		einfo "kernel.shmmni="4096""
		change=yes
	fi

	if [ $shmall -lt 2097152 ]; then
		einfo "kernel.shmall="2097152""
		change=yes
	fi

	if [ $filemax -lt 65536 ]; then
		einfo "fs.file-max="65536""
		change=yes
	fi

	changeport=no
	if [ $ip_local_port_range_lb -lt 1024 ]; then
		changeport=yes
		ip_local_port_range_lb=1024
	fi

	if [ $ip_local_port_range_ub -gt 65000 ]; then
		ip_local_port_range_ub=65000
		changeport=yes
	fi

	if [ "$changeport" != "no" ]; then
		einfo "net.ipv4.ip_local_port_range="$ip_local_port_range_lb $ip_local_port_range_ub""
	fi

	if [ "$change" != "no" ] || [ "$changeport" != "no" ]; then

		elog "It is recommended to add the above kernel parameters to /etc/sysctl.conf:"
		elog "After setting kernel parameters activate them using '/sbin/sysctl -p'"
	else
		elog "Kernel parameters set, configure oracle-xe using"
		elog "  ${ORACLEHOME}/bin/oracle_configure.sh"
	fi
}
