# Copyright 2004-2015 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Sabayon Development Kit"
HOMEPAGE="http://www.sabayon.org"
SRC_URI="https://github.com/Sabayon/devkit/archive/v${PVR}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 arm x86"
IUSE=""
S="${WORKDIR}/devkit-${PVR}"
DEPEND=""
RDEPEND="app-emulation/docker
	app-misc/pax-utils
	app-portage/eix
	app-portage/layman
	app-portage/gentoolkit
	app-portage/portage-utils
	dev-lang/perl
	dev-perl/DBD-SQLite
	sys-apps/gentoo-functions"

src_install() {
	emake DESTDIR="${D}" \
		install || die
}
