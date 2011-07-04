# Copyright 1999-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

IUSE=""
COMMON_DEPEND="=net-dns/avahi-base-${PVR}
	x11-libs/qt-core:4"
AVAHI_MODULE_DEPEND="${COMMON_DEPEND}"
AVAHI_MODULE_RDEPEND="${COMMON_DEPEND}"

inherit eutils avahi

src_configure() {
	local myconf=" --enable-qt4"
	avahi_src_configure "${myconf}"
}

src_compile() {
	cd "${S}"/avahi-common || die
	emake || die
	cd "${S}"/avahi-qt || die
	emake || die
}

src_install() {
	cd "${S}"/avahi-qt || die
	emake install DESTDIR="${D}" || die
	avahi_src_install-cleanup
}
