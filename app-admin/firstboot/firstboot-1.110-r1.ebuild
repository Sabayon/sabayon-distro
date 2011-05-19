# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/firstboot/firstboot-1.4.19.ebuild,v 1.3 2007/10/15 09:35:28 dberkholz Exp $

EAPI=3
inherit python distutils rpm

# Revision of the RPM. Shouldn't affect us, as we're just grabbing the source
# tarball out of it
RPMREV="1"

DESCRIPTION="Initial system configuration utility"
HOMEPAGE="http://fedoraproject.org/wiki/FirstBoot"
SRC_URI="mirror://sabayon/${CATEGORY}/${P}-${RPMREV}.fc13.src.rpm"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gtk"
RDEPEND="
	gtk? ( =dev-python/pygtk-2* )
	dev-python/rhpl
	app-admin/system-config-users
	app-admin/system-config-date
	sys-libs/libuser
	dev-python/python-ethtool"
DEPEND="${RDEPEND}
	sys-devel/gettext"
PDEPEND="app-admin/system-config-keyboard"

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
}
