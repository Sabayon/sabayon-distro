# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"

inherit eutils

DESCRIPTION="pidgin-libnotify provides popups for pidgin via a libnotify interface"
HOMEPAGE="http://gaim-libnotify.sourceforge.net/"
SRC_URI="mirror://sourceforge/gaim-libnotify/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="nls debug"

RDEPEND=">=x11-libs/libnotify-0.3.2
	net-im/pidgin[gtk]
	>=x11-libs/gtk+-2"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${P}-libnotify-0.7-support.patch
	# Source: Thev00d00
	# Make it build with libnotify 0.7
	epatch "${FILESDIR}"/pidgin-libnotify-showbutton.patch
	# A collection of patches submitted to the (dead?) upstream
	# Source: Debian
	# needed to work with Notify OSD correctly.
	epatch "${FILESDIR}"/fix-notify-osd.diff
	# Source: Thev00d00
	# A version of the same patch found on ${HOMEPAGE}
	# Adds an option to not show the message content in the message
	epatch "${FILESDIR}"/no_text_in_messages.diff
	# Source: Sourceforge patches page
	# Enables file transfer notifications
	epatch "${FILESDIR}"/notify_file_transfers.diff
	# Source: Thev00d00
	# A version of the same patch found on ${HOMEPAGE}
	# Use what Purple thinks is the most appropriate name
	epatch "${FILESDIR}"/pidgin-libnotify_best_name.diff
}

src_configure() {
	econf \
		--disable-static \
		--disable-deprecated \
		$(use_enable debug) \
		$(use_enable nls)
}

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	find "${D}" -name '*.la' -delete
	dodoc AUTHORS ChangeLog INSTALL NEWS README TODO VERSION || die
}
