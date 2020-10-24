# Copyright 2004-2020 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Sabayon Bug Report hardware information collector"
HOMEPAGE="http://bugs.sabayon.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/coreutils
	sys-apps/pciutils
	sys-apps/usbutils
	sys-apps/kmod[tools]"

S="${WORKDIR}"

src_unpack() {
	cd "${S}"
	cp "${FILESDIR}/${PN}" . || die
}

src_install() {
	dobin "${PN}" || die
}
