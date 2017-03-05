# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit systemd
DESCRIPTION="RaspberryPi MCE package"
HOMEPAGE="https://github.com/Sabayon"
KEYWORDS="~arm"
LICENSE="GPL-2"
SLOT="0"
IUSE=""
RDEPEND="media-video/raspberrypi-omxplayer
	app-misc/sabayon-auto-updater
	!media-video/omxplayer"
DEPEND=""
RESTRICT="test mirror"
S="${WORKDIR}/${PN}"
SRC_URI="mirror://sabayon/app-misc/sabayon-mce-rpi/${P}.tar.gz"

src_install() {
	systemd_dounit "${FILESDIR}"/${PN}.service
	insinto /usr/share/sabayon/video/
	doins splash.mp4
}

pkg_postinst() {
	elog "Services are now installed, you might want to enable them:"
	elog "systemctl enable ${PN}"
}
