# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="LightDM settings app"
HOMEPAGE="https://github.com/linuxmint/${PN}"
SRC_URI="https://github.com/linuxmint/${PN}/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"

DEPEND="
	sys-devel/gettext
	dev-util/desktop-file-utils"

RDEPEND="
	dev-python/setproctitle
	dev-python/pygobject
	sys-auth/polkit
	dev-python/xapp
	x11-themes/hicolor-icon-theme
	sys-apps/lsb-release
	x11-misc/lightdm-slick-greeter"

src_install() {
	cp -R usr "${D}/"
}
