# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

DESCRIPTION="Sabayon Linux Entropy/Portage failure (fooooon't install this)"
HOMEPAGE="http://www.sabayon.org"
SRC_URI=""

RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=""
DEPEND=""

pkg_setup() {
	einfo "Hello, this is pkg_setup (won't fail)"
}

pkg_preinst() {
	einfo "Hello, this is pkg_preinst (won't fail)"
}

pkg_postinst() {
	einfo "Hello, this is pkg_postinst (won't fail)"
}

pkg_prerm() {
	einfo "Hello, this is pkg_prerm (won't fail)"
}

pkg_postrm() {
	einfo "Hello, this is pkg_postrm (won't fail)"
}

src_install () {
	echo hello world of failures
	die "hehehe, you're fucked"
}
