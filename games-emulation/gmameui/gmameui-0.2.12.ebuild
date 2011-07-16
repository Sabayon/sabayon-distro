# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit games

DESCRIPTION="frontend for SDLMame using the GTK library"
HOMEPAGE="http://gmameui.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="debug doc gnome nls joystick"

RDEPEND="dev-libs/expat
	>=x11-libs/gtk+-2.12:2
	>=gnome-base/libglade-2.0
	x11-themes/gnome-icon-theme
	>=x11-libs/vte-0.9.0
	app-arch/libarchive
	nls? ( virtual/libintl )
	gnome? ( gnome-base/libgnome )
	doc? ( app-text/gnome-doc-utils )"

DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_prepare() {
	epatch "${FILESDIR}/${PN}-datadir.patch"
}

src_configure() {
	local myconf
	use nls || myconf="--disable-libgnome"

	egamesconf \
		$(use_enable debug) \
		$(use_enable doc) \
		$(use_enable joystick) \
		$(use_enable gnome libgnome) \
		$(use_enable nls) \
		${myconf} \
		|| die
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS BUGS ChangeLog NEWS README TODO
	prepgamesdirs
}
