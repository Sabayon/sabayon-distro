# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/linux-wlan-ng-utils/linux-wlan-ng-utils-0.2.2.ebuild,v 1.4 2006/04/02 12:03:28 betelgeuse Exp $

MY_P=${P/-utils/}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Key generators from the linux-wlan-ng project."
HOMEPAGE="http://linux-wlan.org"
SRC_URI="ftp://ftp.linux-wlan.org/pub/linux-wlan-ng/${MY_P}.tar.bz2"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE=""

DEPEND="dev-libs/openssl
		!<net-wireless/linux-wlan-ng-0.2.2"
RDEPEND="${DEPEND}"

KEYGENS="keygen lwepgen"

src_compile() {
	for keygen in ${KEYGENS}; do
		cd add-ons/${keygen}
		make ${keygen} || die "Failed to make ${keygen}"
		cd ${S}
	done
}

src_install() {
	for keygen in ${KEYGENS}; do
		cd add-ons/${keygen}
		dosbin ${keygen}
		cd ${S}
	done
}
