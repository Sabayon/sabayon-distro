# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="2:2.6 3:3.1"
RESTRICT_PYTHON_ABIS="2.4 2.5 3.0 *-jython *-pypy-*"

REAL_PN="${PN/-cairo}"
GNOME_ORG_MODULE="${REAL_PN}"

inherit alternatives autotools eutils gnome2 python virtualx

DESCRIPTION="GLib's GObject library bindings for Python, Cairo Libraries"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+threads"

COMMON_DEPEND="
	~dev-python/pygobject-base-${PV}[threads=]
	>=dev-python/pycairo-1.10.0"
DEPEND="${COMMON_DEPEND}
	sys-apps/findutils"
RDEPEND="${COMMON_DEPEND}
	!<dev-python/pygtk-2.13
	!<dev-python/pygobject-2.28.6-r50:2[introspection]"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-dependency-tracking
		--with-ffi
		--enable-cairo
		$(use_enable threads thread)"
	python_pkg_setup
}

src_prepare() {
	# Do not build tests if unneeded, bug #226345
	epatch "${FILESDIR}/${REAL_PN}-2.90.1-make_check.patch"

	python_clean_py-compile_files

	eautoreconf
	gnome2_src_prepare

	python_copy_sources
}

src_configure() {
	python_execute_function -s gnome2_src_configure
}

src_compile() {
	python_src_compile
}

src_install() {
	python_execute_function -s gnome2_src_install
	python_clean_installation_image
	# just keep /usr/$(get_libdir)/*/site-packages/gi/_gi_cairo.so
	# discard the rest
	rm $(find "${D}" -type f | grep -v "gi/_gi_cairo.so") \
		$(find "${D}" -type l | grep -v "gi/_gi_cairo.so") || die
	find "${D}" -depth -type d -empty -exec rmdir {} \; || die
}

pkg_postinst() {
	python_mod_optimize gi
}

pkg_postrm() {
	python_mod_cleanup gi
}
