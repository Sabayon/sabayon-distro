# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit cmake-utils eutils

MY_P=${P/_/-}
DESCRIPTION="awesome is a floating and tiling window manager initialy based on a dwm code rewriting"
HOMEPAGE="http://awesome.naquadah.org/"
SRC_URI="http://awesome.naquadah.org/download/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dbus doc imlib luadoc"

RDEPEND=">=dev-lang/lua-5.1
	>=dev-libs/glib-2
	dev-libs/libev
	x11-libs/cairo
	>=x11-libs/gtk+-2.2
	>=x11-libs/libxcb-1.1
	x11-libs/pango
	>=x11-libs/xcb-util-0.2.1
	dbus? ( sys-apps/dbus )
	imlib? ( media-libs/imlib2 )"

DEPEND="${RDEPEND}
	app-text/asciidoc
	app-text/xmlto
	dev-util/cmake
	dev-util/gperf
	dev-util/pkgconfig
	>=dev-util/cmake-2.4.7
	x11-proto/xcb-proto
	doc? (
		app-doc/doxygen
		media-gfx/graphviz
	)
	luadoc? ( dev-util/luadoc )"

S="${WORKDIR}/${MY_P}"

DOCS="AUTHORS BUGS README"

pkg_setup() {
	if ! built_with_use --missing false x11-libs/cairo xcb; then
		eerror "You must build cairo with xcb support"
		die "x11-libs/cairo built without xcb"
	fi
}

src_compile() {
	local myargs="all"

	mycmakeargs="${mycmakeargs}
		-DSYSCONFDIR=/etc
		$(cmake-utils_use_with imlib IMLIB2)
		$(cmake-utils_use_with dbus DBUS)
	"

	if use doc ; then
		myargs="${myargs} doc"
	fi

	if use luadoc ; then
		mycmakeargs="${mycmakeargs} -DGENERATE_LUADOC=ON"
	else
		mycmakeargs="${mycmakeargs} -DGENERATE_LUADOC=OFF"
	fi

	cmake-utils_src_compile ${myargs}
}

src_install() {
	cmake-utils_src_install

	if use doc ; then
		dohtml -r "${WORKDIR}"/${PN}_build/doc/html/* || die
	fi
	if use luadoc ; then
		mv "${D}"/usr/share/doc/${PN}/luadoc "${D}"/usr/share/doc/${PF}/luadoc || die
	fi
	rm -rf "${D}"/usr/share/doc/${PN} || die

	exeinto /etc/X11/Sessions
	newexe "${FILESDIR}"/${PN}-session ${PN}

	insinto /usr/share/xsessions
	doins "${FILESDIR}"/${PN}.desktop
}
