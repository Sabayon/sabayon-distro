# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 games

DESCRIPTION="A simple MAME front-end for the GNOME Desktop Environment"
HOMEPAGE="http://mbarnes.github.com/gnome-video-arcade/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome"

RDEPEND="gnome? ( >=gnome-base/libgnomeui-2.14.0 )
	>=dev-libs/glib-2.14.0
	>=x11-libs/gtk+-2.12.0
	>=gnome-base/libglade-2.6.0
	>=x11-themes/gnome-icon-theme-2.18.0
	>=dev-db/sqlite-3.0.0
	>=x11-libs/libwnck-2.16
	gnome-base/gconf
	|| ( games-emulation/sdlmame games-emulation/xmame )"
DEPEND="${RDEPEND}
	app-text/scrollkeeper
	app-text/gnome-doc-utils
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog INSTALL NEWS README"

src_unpack() {
	gnome2_src_unpack
	cd "${S}"

	# change search patch to include /usr/games/bin
	sed -e "s:/usr/games:${GAMES_BINDIR}:g" \
	    -i configure || die "sed failed"
}

src_compile() {
	local MY_USE
	use gnome || MY_USE="--without-gnome"

	gnome2_src_compile --bindir="${GAMES_BINDIR}" ${MY_USE} || die "compile failed"
}

src_install() {
	gnome2_src_install || die "install failed"
	prepgamesdirs
}
