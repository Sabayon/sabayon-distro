# Copyright 2004-2018 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="Sabayon Development Kit"
HOMEPAGE="http://www.sabayon.org"
SRC_URI="https://github.com/Sabayon/devkit/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~arm"
IUSE=""
S="${WORKDIR}/devkit-${PV}"
DEPEND=""
RDEPEND="app-emulation/docker
	app-misc/pax-utils
	app-misc/querypkg
	app-portage/eix
	app-portage/layman
	app-portage/gentoolkit
	app-portage/portage-utils
	app-portage/repoman
	dev-lang/perl
	dev-perl/DBD-SQLite
	sys-apps/gentoo-functions"

src_install() {
	emake DESTDIR="${D}" install
}
