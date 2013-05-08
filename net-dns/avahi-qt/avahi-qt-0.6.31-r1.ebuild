# Copyright 1999-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit multilib

IUSE=""
COMMON_DEPEND="=net-dns/avahi-base-${PVR}
	dev-qt/qtcore:4"
AVAHI_MODULE_DEPEND="${COMMON_DEPEND}"
AVAHI_MODULE_RDEPEND="${COMMON_DEPEND}"

WANT_AUTOMAKE=1.11
AVAHI_PATCHES=(
	# Fix init scripts for >=openrc-0.9.0 (bug #383641)
	"${FILESDIR}/avahi-0.6.x-openrc-0.9.x-init-scripts-fixes.patch"
	# install-exec-local -> install-exec-hook
	"${FILESDIR}"/${P/-qt}-install-exec-hook.patch
	# Backport host-name-from-machine-id patch, bug #466134
	"${FILESDIR}"/${P/-qt}-host-name-from-machine-id.patch
)
inherit eutils avahi

src_configure() {
	local myconf=" --enable-qt4
	--disable-mono"
	avahi_src_configure "${myconf}"
}

src_compile() {
	cd "${S}"/avahi-common || die
	emake || die
	cd "${S}"/avahi-qt || die
	emake || die
	cd "${S}" || die
	emake avahi-qt4.pc || die
}

src_install() {
	cd "${S}"/avahi-qt || die
	emake install DESTDIR="${ED}" || die

	cd "${S}" || die
	dodir /usr/$(get_libdir)/pkgconfig
	insinto /usr/$(get_libdir)/pkgconfig
	doins avahi-qt4.pc

	avahi_src_install-cleanup
}
