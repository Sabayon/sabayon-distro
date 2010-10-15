# Copyright 2004-2010 Sabayon Project
# Distributed under the terms of the GNU General Public License v2
# $

inherit eutils

DESCRIPTION="JBoss Application Server"
HOMEPAGE="http://www.jboss.org"
SRC_URI="${SRC_URI:-mirror://sourceforge/jboss/jboss-${PV}.GA-jdk6.zip}"

# @ECLASS-VARIABLE: JBOSS_SLOT
# @DESCRIPTION:
# As you may know, there are several versions of JBoss maintained
# at the same time. Just set JBOSS_SLOT to the version branch
# your ebuild is going to use. For eg. "4.2" or "5.0", "5.1", etc
JBOSS_SLOT="${JBOSS_SLOT:-${SLOT}}"

LICENSE="LGPL-2.1"
SLOT="${JBOSS_SLOT}"
IUSE="doc"

RDEPEND=">=virtual/jdk-1.6"
DEPEND="sys-apps/sed ${RDEPEND}"
JBOSS_NAME="${PN}-${SLOT}"
INSTALL_DIR="/opt/${JBOSS_NAME}"

S="${WORKDIR}/jboss-${PV}.GA"

jboss-bin_pkg_setup() {
	# Create jboss user and groups
	enewgroup jboss
	enewuser jboss -1 -1 -1 jboss
}

jboss-bin_src_install() {
	dodir "${INSTALL_DIR}"

	exeinto "${INSTALL_DIR}"/bin
	doexe bin/run.sh bin/shutdown.sh bin/twiddle.sh

	insinto "${INSTALL_DIR}"/bin
	doins bin/run.jar bin/shutdown.jar bin/twiddle.jar
	doins bin/run.conf

	insinto "${INSTALL_DIR}"
	doins -r client lib server
	use doc && doins -r docs

	cp "${FILESDIR}"/jboss-bin.confd . || die "cannot copy config file"
	sed -i "s:__JBOSS_HOME__:${INSTALL_DIR}:g" jboss-bin.confd || die "cannot jboss-bin.confd"
	sed -i "s:__JBOSS_VER__:${SLOT}:g" jboss-bin.confd || die "cannot sed jboss-bin.confd"
	sed -i "s:__JBOSS__:${JBOSS_NAME}:g" jboss-bin.confd || die "cannot sed jboss-bin.confd"
	dodir /etc/conf.d
	newconfd jboss-bin.confd "${JBOSS_NAME}"

	cp "${FILESDIR}"/jboss-bin.initd . || die "cannot copy init file"
	sed -i "s:__JBOSS_HOME__:${INSTALL_DIR}:g" jboss-bin.initd || die "cannot jboss-bin.initd"
	sed -i "s:__JBOSS_VER__:${SLOT}:g" jboss-bin.initd || die "cannot sed jboss-bin.initd"
	sed -i "s:__JBOSS__:${JBOSS_NAME}:g" jboss-bin.initd || die "cannot sed jboss-bin.initd"
	dodir /etc/init.d
	newinitd jboss-bin.initd "${JBOSS_NAME}"

	echo "JBOSS_HOME=\"${INSTALL_DIR}\"" > "50-${JBOSS_NAME}"
	doenvd "50-${JBOSS_NAME}"

}

jboss-bin_pkg_preinst() {
	# setup permissions before merging
	chown jboss:jboss "${D}/${INSTALL_DIR}" -R
}

EXPORT_FUNCTIONS pkg_setup src_install pkg_preinst
