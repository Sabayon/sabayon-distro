# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/ipw3945d/ipw3945d-1.7.22-r3.ebuild,v 1.1 2006/09/09 07:53:40 phreak Exp $

DESCRIPTION="Regulatory daemon for the Intel PRO/Wireless 3945ABG miniPCI express adapter"
HOMEPAGE="http://www.bughost.org/ipw3945/"
SRC_URI="http://www.bughost.org/ipw3945/daemon/${P}.tgz"

LICENSE="ipw3945"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""
DEPEND=""

src_install() {
	into /
	use x86 && dosbin x86/ipw3945d
	use amd64 && dosbin x86_64/ipw3945d

	keepdir /var/run/${PN}

	newconfd "${FILESDIR}"/${PN}-conf.d ${PN}
	newinitd "${FILESDIR}"/${PN}-init.d ${PN}

	dodoc README.${PN}
}

pkg_postinst() {
	einfo
	einfo "The ipw3945d is now started using an init script. To automatically have"
	einfo "it started, you need to add it to the boot run level as shown below:"
	einfo
	einfo "  # rc-update add ${PN} default"
	einfo

	if [[ -e "${ROOT}"/etc/modules.d/ipw3945d ]]; then
		ewarn
		ewarn "You need to manually delete the now obsolete modprobe entry and run"
		ewarn "modules-update as shown below:"
		ewarn
		ewarn "  # rm -f ${ROOT}/etc/modules.d/ipw3945d; modules-update --force"
		ewarn
	fi
}
