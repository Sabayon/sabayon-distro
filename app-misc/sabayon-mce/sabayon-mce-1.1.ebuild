# Copyright 2004-2008 Sabayon Linux (Fabio Erculiani)
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Sabayon Linux Media Center Infrastructure"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI=""

RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND="media-tv/xbmc
	>=app-misc/sabayonlive-tools-2.2"
DEPEND=""

S="${WORKDIR}"

src_unpack() {
	cp "${FILESDIR}"/${PV}/* "${WORKDIR}"/ -Rp || die "cannot unpack"
}

src_install () {

	cd "${WORKDIR}"/init.d
	newinitd sabayon-mce sabayon-mce

	cd "${WORKDIR}"/bin
	exeinto /usr/bin
	doexe *

	cd "${WORKDIR}"/xsession
	dodir /usr/share/xsessions
	insinto /usr/share/xsessions
	doins *.desktop

}

pkg_postinst() {
	# create new user sabayonmce
	enewuser sabayonmce -1 /bin/sh /var/sabayonmce users,lp,wheel,uucp,audio,cdrom,video,cdrw,usb,plugdev,polkituser

	elog "For those who are using <=Sabayon-5.1 as Media Center:"
	elog "PLEASE update DISPLAYMANAGER= in /etc/conf.d/xdm"
	elog "setting it to gdm or kdm."

}
