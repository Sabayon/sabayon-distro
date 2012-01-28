# Copyright 2004-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Sabayon Linux Media Center Infrastructure"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI=""

RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm x86"
IUSE=""

RDEPEND="media-tv/xbmc
	>=app-misc/sabayonlive-tools-2.3-r12"
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
	local mygroups="users"
	for mygroup in lp wheel uucp audio cdrom scanner video cdrw usb plugdev polkituser; do
		if [[ -n $(egetent group "${mygroup}") ]]; then
        		mygroups+=",${mygroup}"
		fi
	done
	enewuser sabayonmce -1 /bin/sh /var/sabayonmce "${mygroups}"

	elog "For those who are using <=Sabayon-5.1 as Media Center:"
	elog "PLEASE update DISPLAYMANAGER= in /etc/conf.d/xdm"
	elog "setting it to gdm or kdm."

}
