# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"
inherit gnome2 flag-o-matic

DESCRIPTION="A full featured, dual-pane file manager for Gnome2"
HOMEPAGE="http://www.nongnu.org/gcmd/"

SRC_URI="http://ftp.gnome.org/pub/GNOME/sources/${PN}/1.2/${P}.tar.bz2";

KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"

LICENSE="GPL-2"

IUSE="doc exif gsf id3 python"
SLOT="0"


USE_DESC="
	   exif: add support for Exif and IPTC
	   gsf: add support for OLE, OLE2 and ODF
	   id3: add support for ID3, Vorbis, FLAC and APE
	python: add support for python plugins"


RDEPEND=">=x11-libs/gtk+-2.8.0:2
        >=dev-libs/glib-2.6.0
        >=gnome-base/libgnomeui-2.4.0
        >=gnome-base/libgnome-2.0.0
        >=gnome-base/gnome-vfs-2.0.0
        || (
                app-admin/gamin
                app-admin/fam
        )
        exif?   ( >=media-gfx/exiv2-0.14     )
        gsf?    ( >=gnome-extra/libgsf-1.12.0 )
        id3?    ( >=media-libs/taglib-1.4  )
        python? ( >=dev-lang/python-2.4
                  >=dev-python/gnome-vfs-python-2.0.0 )"



DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35.0
	dev-util/pkgconfig"


DOCS="AUTHORS BUGS ChangeLog NEWS README TODO"



pkg_setup() {
	G2CONF=" ${G2CONF}
		$(use_with exif exiv2)
		$(use_with gsf  libgsf)
		$(use_with id3  taglib)
		$(use_enable python python)"
		filter-ldflags -Wl,--as-needed
}
