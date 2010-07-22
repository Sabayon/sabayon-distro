# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="JBoss Application Server"
HOMEPAGE="http://www.jboss.org/jbossas/"
SRC_URI="mirror://sourceforge/jboss/jboss-${PV}.GA-jdk6.zip"

LICENSE="LGPL-2.1"
SLOT="4.2"
KEYWORDS="x86"

IUSE="doc"

RDEPEND=">=virtual/jdk-1.6"
DEPEND="${RDEPEND}"
JBOSS_DIRNAME="${PN}-${SLOT}"

S="${WORKDIR}/jboss-${PV}.GA"

INSTALL_DIR="/opt/${JBOSS_DIRNAME}"

src_install() {
	dodir "${INSTALL_DIR}"

	exeinto "${INSTALL_DIR}"/bin
	doexe bin/run.sh bin/shutdown.sh bin/twiddle.sh

	insinto "${INSTALL_DIR}"/bin
	doins bin/run.jar bin/shutdown.jar bin/twiddle.jar
	doins bin/run.conf

	insinto "${INSTALL_DIR}"
	doins -r client lib server
	use doc && doins -r docs
}
