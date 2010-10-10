# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

ESVN_REPO_URI="svn://svn.handbrake.fr/HandBrake/trunk"

inherit subversion gnome2-utils

DESCRIPTION="Open-source DVD to MPEG-4 converter."
HOMEPAGE="http://handbrake.fr/"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE="doc gtk"
RDEPEND="
	gtk? (	>=x11-libs/gtk+-2.8
			dev-libs/glib
			dev-libs/dbus-glib
			sys-apps/hal
			net-libs/webkit-gtk
			x11-libs/libnotify
			media-libs/gstreamer
			media-libs/gst-plugins-base
			>=sys-fs/udev-147[extras]
	)"
DEPEND="sys-libs/zlib
	dev-lang/yasm
	>=dev-lang/python-2.4.6
	|| ( >=net-misc/wget-1.11.4 >=net-misc/curl-7.19.4 ) 
	$RDEPEND"

src_configure() {

	local myconf=""

	! use gtk && myconf="${myconf} --disable-gtk"

	./configure --force --prefix=/usr --disable-gtk-update-checks ${myconf} || die "configure failed"

}

src_compile() {

	cd "${S}/build" || die "cannot find build dir"
	make || die "failed compiling ${PN}"

}

src_install() {

	cd "${S}/build" || die "cannot find build dir"
	make DESTDIR="${D}" install || die "failed installing ${PN}"

	if use doc;then
		make doc || die "failed making docs"
		cd "${S}"
		dodoc AUTHORS CREDITS NEWS THANKS || die "failed installing docs"
		dodoc build/doc/articles/txt/* || die "failed installing docs"
	fi

}

pkg_preinst() {

	gnome2_icon_savelist

}

pkg_postinst() {

	gnome2_icon_cache_update

}

pkg_postrm() {

	gnome2_icon_cache_update

}
