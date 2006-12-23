# Copyright 1999-2005 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde
need-kde 3.3

DESCRIPTION="Template based DVD authoring software"
LICENSE="GPL-2"
HOMEPAGE="http://www.iki.fi/damu/software/kmediafactory/"
SRC_URI="http://susku.pyhaselka.fi/damu/software/kmediafactory/kmediafactory-20061010.tar.bz2"

RESTRICT="nomirror"
IUSE="xine ogg dv dvdread theora slideshow office dvb"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="${DEPEND}
    sys-devel/gettext
    >=media-gfx/imagemagick-6.1.3.2
    media-libs/fontconfig
    app-arch/zip
    xine? ( media-libs/xine-lib )
    ogg? ( media-libs/libogg )
    dv? ( media-libs/libdv )
    dvdread? ( media-libs/libdvdread )
    theora? ( media-libs/libtheora )"

RDEPEND="${RDEPEND}
    >=media-video/dvdauthor-0.6.11
    media-video/mjpegtools
    slideshow? ( >=media-video/dvd-slideshow-0.7.2 )
    office? ( >=virtual/ooo-2.0 )
    dvb? ( >=media-video/projectx-0.90.0.00 )"

src_compile()
{
  econf --with-unopkg=no
  emake || die "emake failed"
}

find_unopkg()
{
  for lib in "/usr/lib32" "/usr/lib"; do
    if test -x ${lib}/openoffice/program/unopkg; then
      UNOPKG=${lib}/openoffice/program/unopkg
      return 0
    fi
  done
  return 1
}

pkg_postinst()
{
  if find_unopkg; then
    ${UNOPKG} add --shared /usr/share/apps/kmediafactory/kmf_converter.zip
  fi
}

pkg_postrm()
{
  if find_unopkg; then
    ${UNOPKG} remove --shared kmf_converter.zip
  fi
}
