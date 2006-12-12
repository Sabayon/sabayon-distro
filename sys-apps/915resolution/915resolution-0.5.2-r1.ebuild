# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/915resolution/915resolution-0.5.2.ebuild,v 1.2 2006/07/22 23:31:55 chutzpah Exp $

DESCRIPTION="Utility to patch VBIOS of Intel 855 / 865 / 915 chipsets"
HOMEPAGE="http://www.geocities.com/stomljen/"
SRC_URI="http://www.geocities.com/stomljen/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_compile() {
	emake clean
	emake CFLAGS="${CFLAGS}" || die "Compiliation failed."
}

src_install() {
	dosbin ${PN}
	newconfd "${FILESDIR}/confd" ${PN}
	newinitd "${FILESDIR}/initd" ${PN}
	dodoc README.txt changes.log chipset_info dump_bios
}

pkg_postinst() {
	elog
	elog "${PN} alters your video BIOS in a non-permanent way, this means"
	elog "that there is no risk of permanent damage to your video card, but"
	elog "it also means that it must be run at every boot. To set it up, "
	elog "edit /etc/conf.d/${PN} to add your configuration and type the"
	elog "following command to add it the your defautl runlevel:"
	elog
	elog "    \"rc-update add ${PN} default\""
	elog
}
