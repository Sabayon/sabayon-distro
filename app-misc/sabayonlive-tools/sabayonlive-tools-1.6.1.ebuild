# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="SabayonLinux Live tools for autoconfiguration of the system"
HOMEPAGE="http://www.sabayonlinux.org"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE="opengl professional_edition"

RDEPEND="dev-util/dialog
	sys-apps/pciutils
	sys-apps/gawk
	!professiona_edition? ( app-admin/eselect-opengl )
	!app-misc/livecd-tools
	!professional_edition? ( x11-misc/desktop-acceleration-helpers )
	"
DEPEND="${RDEPEND}"

src_unpack() {
	cd ${WORKDIR}
	cp ${FILESDIR}/${PV}/livecd-functions.sh . -p
	cp ${FILESDIR}/${PV}/net-setup . -p
	cp ${FILESDIR}/${PV}/x-setup-init.d . -p
	cp ${FILESDIR}/${PV}/x-setup-configuration . -p
	cp ${FILESDIR}/${PV}/xorg.conf . -p
	cp ${FILESDIR}/${PV}/bashlogin . -p
	cp ${FILESDIR}/${PV}/opengl-activator . -p
}

src_install() {

	cd ${WORKDIR}

	if use opengl; then
		dosbin x-setup-configuration
		newinitd x-setup-init.d x-setup
	fi

	dosbin net-setup
	into /
	dosbin livecd-functions.sh
	dobin bashlogin
	exeinto /usr/bin
	doexe opengl-activator

	insinto /etc/X11
	doins xorg.conf

}
