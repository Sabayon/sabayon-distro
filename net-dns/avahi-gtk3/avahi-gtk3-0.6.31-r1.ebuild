# Copyright 1999-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

IUSE=""
COMMON_DEPEND="=net-dns/avahi-base-${PVR}
	x11-libs/gtk+:3"
AVAHI_MODULE_DEPEND="${COMMON_DEPEND}"
AVAHI_MODULE_RDEPEND="${COMMON_DEPEND}"

WANT_AUTOMAKE=1.11
AVAHI_PATCHES=(
	# Fix init scripts for >=openrc-0.9.0 (bug #383641)
	"${FILESDIR}/avahi-0.6.x-openrc-0.9.x-init-scripts-fixes.patch"
	# install-exec-local -> install-exec-hook
	"${FILESDIR}"/${P/-gtk3}-install-exec-hook.patch
	# Backport host-name-from-machine-id patch, bug #466134
	"${FILESDIR}"/${P/-gtk3}-host-name-from-machine-id.patch
)
inherit eutils avahi

src_configure() {
	local myconf=" --disable-gtk --enable-gtk3"
	avahi_src_configure "${myconf}"
}

src_compile() {
	for target in avahi-common avahi-client avahi-glib avahi-ui; do
		cd "${S}"/${target} || die
		emake || die
	done
	cd "${S}" || die
	emake avahi-ui-gtk3.pc || die
}

src_install() {
	cd "${S}"/avahi-ui || die
	emake -j1 install DESTDIR="${ED}" || die
	cd "${S}" || die
	dodir /usr/$(get_libdir)/pkgconfig
	insinto /usr/$(get_libdir)/pkgconfig
	doins avahi-ui-gtk3.pc

	avahi_src_install-cleanup

	# Workaround for avahi-ui.h collision between avahi-gtk and avahi-gtk3
	root_avahi_ui="${ROOT}usr/include/avahi-ui/avahi-ui.h"
	if [ -e "${root_avahi_ui}" ]; then
		rm -f "${ED}usr/include/avahi-ui/avahi-ui.h"
	fi
}
