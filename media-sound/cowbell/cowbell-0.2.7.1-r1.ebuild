# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/cowbell/cowbell-0.2.7.1.ebuild,v 1.4 2008/01/26 08:16:47 drac Exp $

inherit autotools gnome2 mono

DESCRIPTION="Elegantly tag and rename mp3/ogg/flac files"
HOMEPAGE="http://more-cowbell.org"
SRC_URI="http://more-cowbell.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/mono
	>=dev-dotnet/gtk-sharp-2.6
	>=dev-dotnet/glade-sharp-2.6
	>=media-libs/taglib-1.4"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.34.2"

DOCS="AUTHORS ChangeLog NEWS README"

MAKEOPTS="${MAKEOPTS} -j1"

 src_unpack() {
 	gnome2_src_unpack
	epatch "${FILESDIR}/${P}-configure.in.patch"
 	eautoreconf
 }

