# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{2_7,3_4} )

REAL_PN="${PN/-cairo}"
GNOME_ORG_MODULE="${REAL_PN}"

inherit autotools eutils gnome2 python-r1 virtualx

DESCRIPTION="GLib's GObject library bindings for Python, Cairo Libraries"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+threads"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	~dev-python/pygobject-base-${PV}[threads=]
	>=dev-python/pycairo-1.10.0[${PYTHON_USEDEP}]
	${PYTHON_DEPS}"
DEPEND="${COMMON_DEPEND}
	x11-libs/cairo[glib]
	gnome-base/gnome-common"
RDEPEND="${COMMON_DEPEND}
	!<dev-python/pygtk-2.13
	!<dev-python/pygobject-2.28.6-r50:2[introspection]"

# gnome-base/gnome-common required by eautoreconf

src_prepare() {
	# Comment out broken unittest
	epatch "${FILESDIR}"/3.16.1-unittest.patch
	gnome2_src_prepare
	python_copy_sources
}

src_configure() {
	# Hard-enable libffi support since both gobject-introspection and
	# glib-2.29.x rdepend on it anyway
	# docs disabled by upstream default since they are very out of date
	python_foreach_impl run_in_build_dir \
		gnome2_src_configure \
			--enable-cairo \
			$(use_enable threads thread)
}

src_compile() {
	python_foreach_impl run_in_build_dir gnome2_src_compile
}

src_install() {
	DOCS="AUTHORS ChangeLog* NEWS README"

	python_foreach_impl run_in_build_dir gnome2_src_install
	# just keep /usr/$(get_libdir)/*/site-packages/gi/_gi_cairo*.so
	# discard the rest

	# /usr/lib64/python2.7/site-packages/gi/_gi_cairo.so
	# /usr/lib64/python3.3/site-packages/gi/_gi_cairo.cpython-33.so
	# /usr/lib64/python3.4/site-packages/gi/_gi_cairo.cpython-34.so

	rm $(find "${ED}" -type f | grep -v "gi/_gi_cairo.*\.so") \
		$(find "${ED}" -type l | grep -v "gi/_gi_cairo.*\.so") || die
	find "${ED}" -depth -type d -empty -exec rmdir {} \; || die
}
