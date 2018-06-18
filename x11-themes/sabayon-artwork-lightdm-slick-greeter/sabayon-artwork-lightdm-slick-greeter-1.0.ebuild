# Copyright 2004-2018 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Sabayon LightDM slick greeter configurations"
HOMEPAGE="http://www.sabayon.org/"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"

KEYWORDS="~amd64 ~arm ~x86"
IUSE=""
RDEPEND="
	x11-themes/sabayon-artwork-core
	x11-misc/lightdm-slick-greeter
	x11-misc/lightdm-settings"

S="${FILESDIR}"

src_install () {
	insinto /etc/lightdm/
	doins slick-greeter.conf
}
