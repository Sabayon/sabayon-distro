# Copyright 1999-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

IUSE="python utils dbus"
COMMON_DEPEND="=net-dns/avahi-base-${PVR}[dbus=,python=]
	>=x11-libs/gtk+-2.14.0:2
	python? ( >=dev-python/pygtk-2 )"
AVAHI_MODULE_DEPEND="${COMMON_DEPEND}"
AVAHI_MODULE_RDEPEND="${COMMON_DEPEND}"

WANT_AUTOMAKE=1.11
AVAHI_PATCHES=(
	"${FILESDIR}/avahi-0.6.28-optional-gtk-utils.patch"
	"${FILESDIR}"/${P/-gtk}-automake-1.11.2.patch #397477
	"${FILESDIR}"/${P/-gtk}-parallel.patch #411351
)
inherit eutils python avahi

src_configure() {
	local myconf=" --enable-gtk
		--disable-gtk3
		--disable-mono
		$(use_enable dbus)
		$(use_enable utils gtk-utils)
		--enable-pygtk"
	if use python; then
		myconf+=" $(use_enable dbus python-dbus)"
	fi
	avahi_src_configure "${myconf}"
}

src_compile() {
	for target in avahi-common avahi-client avahi-glib avahi-ui; do
		cd "${S}"/${target} || die
		emake || die
	done
	cd "${S}" || die
	emake avahi-ui.pc || die
}

src_install() {
	cd "${S}"/avahi-ui || die
	emake install py_compile=true DESTDIR="${D}" || die
	if use python; then
		cd "${S}"/avahi-python/avahi-discover || die
		emake install py_compile=true DESTDIR="${D}" || die
	fi
	cd "${S}" || die
	dodir /usr/$(get_libdir)/pkgconfig
	insinto /usr/$(get_libdir)/pkgconfig
	doins avahi-ui.pc

	avahi_src_install-cleanup
}

pkg_postrm() {
	use python && python_mod_cleanup $(use dbus && echo avahi_discover)
}

pkg_postinst() {
	use python && python_mod_optimize avahi $(use dbus && echo avahi_discover)
}


