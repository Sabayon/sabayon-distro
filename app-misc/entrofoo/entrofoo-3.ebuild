# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit eutils

DESCRIPTION="Sabayon Linux Entropy Test Package (fooooon't install this)"
HOMEPAGE="http://www.sabayon.org"
SRC_URI=""

RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="app-misc/entrofoo-fail"
DEPEND="app-misc/entrofoo-fail"

S="${WORKDIR}"

pkg_setup() {
	einfo "Hello, this is pkg_setup"
}

pkg_preinst() {
	einfo "Hello, this is pkg_preinst"
}

pkg_postinst() {
	einfo "Hello, this is pkg_postinst"
}

pkg_prerm() {
	einfo "Hello, this is pkg_prerm"
}

pkg_postrm() {
	einfo "Hello, this is pkg_postrm"
}
