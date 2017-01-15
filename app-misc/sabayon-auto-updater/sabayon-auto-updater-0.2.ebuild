# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit systemd
DESCRIPTION="Sabayon Automatic Updater systemd service. Do not use in production or @home!"
HOMEPAGE="https://github.com/Sabayon"
KEYWORDS="~amd64 ~arm"
LICENSE="GPL-2"
SLOT="0"
IUSE=""
RDEPEND=""
DEPEND=""
RESTRICT="test"
S="${WORKDIR}"

src_install() {
	systemd_dounit "${FILESDIR}"/${PN}.service
	systemd_dounit "${FILESDIR}"/${PN}.timer
}

pkg_postinst() {
    elog "Services are now installed, you might want to enable them:"
    elog "systemctl enable sabayon-auto-updater.timer"
    elog "or you can use the service:"
    elog "systemctl start sabayon-auto-updater"
}
