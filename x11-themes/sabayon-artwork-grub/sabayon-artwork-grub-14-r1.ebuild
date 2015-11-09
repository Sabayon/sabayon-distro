# Copyright 2004-2015 Sabayon
# Distributed under the terms of the GNU General Public License v2
#

EAPI=5

inherit base mount-boot

DESCRIPTION="Sabayon GRUB2 background images"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-${PVR}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"

KEYWORDS="~amd64 ~arm ~x86"
IUSE=""
RDEPEND=""

S="${WORKDIR}/${PN}"

src_install () {
	cd "${S}/images"
	dodir /usr/share/grub
	insinto /usr/share/grub
	doins default-splash.png
}

pkg_postinst() {
	# install Sabayon splash here, cannot touch boot/grub inside
	# src_install
	local dir="${ROOT}"boot/grub
	cp "${ROOT}/usr/share/grub/default-splash.png" "${dir}/default-splash.png" || \
		ewarn "cannot install default splash file!"
}
