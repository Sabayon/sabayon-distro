# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/guayadeque/guayadeque-0.2.5.ebuild 2010/01/15 17:21:00 lukyn Exp $

EAPI="0"

inherit cmake-utils

DESCRIPTION="Music player with the aims to be intuitive, easy to use and
fast for even huge music collections"
HOMEPAGE="http://sourceforge.net/projects/guayadeque/"
#SRC_URI="http://dfn.dl.sourceforge.net/sourceforge/${PN}/${PN}-${PV}.tar.gz"
SRC_URI="http://downloads.sourceforge.net/project/guayadeque/${PN}/${PV}/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="=x11-libs/wxGTK-2.8*
    >=media-libs/taglib-1
    >=dev-db/sqlite-3
    >=media-libs/gstreamer-0.10
    >=sys-apps/dbus-1
    >=net-misc/curl-7
    media-libs/flac
    "
    
DEPEND="${RDEPEND}
    sys-devel/gettext
    dev-util/pkgconfig
    dev-util/cmake
    "

pkg_postinst() {

einfo "A plugin for the music-applet is available for ppl using this great
applet. With this you can control guayadeque from it. You must put it where
the music applets are. In Gentoo the plugins are at
/usr/lib/python2.x/site-packages/musicapplet/plugins/."

}
