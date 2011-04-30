# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit eutils

DESCRIPTION="LXDE Session default configuration files and nuoveXT2 iconset"
HOMEPAGE="http://lxde.sf.net/"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm ppc x86"
IUSE=""

RDEPEND="x11-libs/gtk+:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"
PDEPEND="lxde-base/lxde-icon-theme"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-session-fix.patch
	epatch "${FILESDIR}"/${P}-desktop-icons.patch
	# after running pcmanfm -d, PCManFM window can't be shown using 'pcmanfm'
	# problem with x11-misc/pcmanfm-0.9.9_pre20110[24]*
	epatch "${FILESDIR}"/${P}-desktop-icons-fix-daemon-mode.patch
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README || die "dodoc failed"
}

pkg_postinst() {
	elog "${P} has renamed the configuration file name to"
	elog "/etc/xdg/lxsession/LXDE/desktop.conf"
	elog "Keep in mind you have to migrate your custom settings"
	elog "from /etc/xdg/lxsession/LXDE/config"
	einfo ""
	elog "Temporary warning:"
	elog "If you have problems running PCManFM under LXDE,"
	elog "check if your \$HOME/.config/lxsession/<profile>/autostart"
	elog "or /etc/xdg/lxsession/<profile>/autostart"
	elog "does NOT contain -d (or --daemon-mode) for pcmanfm."
}
