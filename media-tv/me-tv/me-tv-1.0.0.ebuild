# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils versionator gnome2

DESCRIPTION="Me TV Gnome DVB Program"
HOMEPAGE="http://me-tv.sourceforge.net/"
SRC_URI="http://launchpad.net/${PN}/stable/$(get_version_component_range 1-3)/+download/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug doc mplayer xine vlc gstreamer nls static"
RDEPEND=">=dev-cpp/libgnomemm-2.20.0
	>=dev-cpp/libgnomecanvasmm-2.20.0
	>=dev-cpp/libgnomeuimm-2.20.0
	>=dev-cpp/gconfmm-2.20.0
	>=dev-cpp/gtkmm-2.16.0
	=dev-db/sqlite-3*
	>=net-libs/gnet-2.0.0
	>=x11-libs/libXtst-1.0.0
	mplayer? ( media-video/mplayer[dvb] )
	xine? ( >=media-libs/xine-lib-1.1.7 media-video/xine-ui )
	vlc? ( >=media-video/vlc-0.9[dvb] )
	gstreamer? ( >=media-libs/gst-plugins-bad-0.10 )"
# XML::Parser, pkgconfig >= 0.9.0

DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.0 )"

#S="${WORKDIR}/${PN}-0.8.0"

src_compile() {
	econf \
	      $(use_enable static) \
	      $(use_enable nls) \
	      $(use_enable debug) \
	      $(use_enable doc gtk-doc) \
	      $(use_enable mplayer mplayer-engine) \
	      $(use_enable xine xine-engine) \
	      $(use_enable xine xine-lib-engine) \
	      $(use_enable vlc libvlc-engine) \
	      $(use_enable gstreamer libgstreamer-engine) \
	      || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_postinst() {
	einfo 'Please note that xine is the only engine supported by upstream'
	if ! use xine
	then
	    ewarn 'Warning: You choose to not install the xine engine'
	    ewarn 'which is the only one supported by upstream.'
	fi
}
