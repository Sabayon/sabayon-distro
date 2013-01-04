# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{2_6,2_7,3_1,3_2,3_3} )

REAL_PN="${PN/-cairo}"
GNOME_ORG_MODULE="${REAL_PN}"

inherit autotools eutils gnome2 python-r1 virtualx

DESCRIPTION="GLib's GObject library bindings for Python, Cairo Libraries"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+threads"

COMMON_DEPEND="
	~dev-python/pygobject-base-${PV}[threads=]
	>=dev-python/pycairo-1.10.0
	${PYTHON_DEPS}"
DEPEND="${COMMON_DEPEND}
	x11-libs/cairo[glib]
	sys-apps/findutils"
RDEPEND="${COMMON_DEPEND}
	!<dev-python/pygtk-2.13
	!<dev-python/pygobject-2.28.6-r50:2[introspection]"

src_prepare() {
	DOCS="AUTHORS ChangeLog* NEWS README"
	# Hard-enable libffi support since both gobject-introspection and
	# glib-2.29.x rdepend on it anyway
	# docs disabled by upstream default since they are very out of date
	G2CONF="${G2CONF}
		--disable-dependency-tracking
		--with-ffi
		--enable-cairo
		$(use_enable threads thread)"

	# Do not build tests if unneeded, bug #226345
	epatch "${FILESDIR}/${REAL_PN}-3.4.1.1-make_check.patch"

	eautoreconf
	gnome2_src_prepare

	python_copy_sources
}

src_configure() {
	python_foreach_impl run_in_build_dir gnome2_src_configure
}

src_compile() {
	python_foreach_impl run_in_build_dir gnome2_src_compile
}

src_install() {
	python_foreach_impl run_in_build_dir gnome2_src_install
	# just keep /usr/$(get_libdir)/*/site-packages/gi/_gi_cairo.so
	# discard the rest
	rm $(find "${ED}" -type f | grep -v "gi/_gi_cairo.so") \
		$(find "${ED}" -type l | grep -v "gi/_gi_cairo.so") || die
	find "${ED}" -depth -type d -empty -exec rmdir {} \; || die
}

run_in_build_dir() {
	pushd "${BUILD_DIR}" > /dev/null || die
	"$@"
	popd > /dev/null
}
