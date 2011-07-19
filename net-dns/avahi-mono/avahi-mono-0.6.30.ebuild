# Copyright 1999-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

IUSE="doc gtk"
COMMON_DEPEND="=net-dns/avahi-base-${PVR}[dbus]
	>=dev-lang/mono-1.1.10
	gtk? (
		=net-dns/avahi-gtk-${PVR}
		>=dev-dotnet/gtk-sharp-2
	)"
AVAHI_MODULE_DEPEND="${COMMON_DEPEND}
	doc? ( >=virtual/monodoc-1.1.8 )"
AVAHI_MODULE_RDEPEND="${COMMON_DEPEND}"

inherit eutils avahi

src_configure() {
	local myconf="--enable-mono --enable-dbus"
	myconf+=" $(use_enable doc monodoc)"
	avahi_src_configure "${myconf}"
}

src_compile() {
	for target in avahi-common avahi-client avahi-glib avahi-sharp; do
		cd "${S}"/${target} || die
		emake || die
	done
	cd "${S}" || die
	emake avahi-sharp.pc || die
	if use gtk; then
		cd "${S}"/avahi-ui-sharp || die
		emake || die
		cd "${S}" || die
		emake avahi-ui-sharp.pc || die
	fi
}

src_install() {
	cd "${S}"/avahi-sharp || die
	emake install DESTDIR="${D}" || die
	if use gtk; then
		cd "${S}"/avahi-ui-sharp || die
		emake install DESTDIR="${D}" || die
	fi
	cd "${S}" || die
	dodir /usr/$(get_libdir)/pkgconfig
	insinto /usr/$(get_libdir)/pkgconfig
	doins *.pc

	avahi_src_install-cleanup
}
