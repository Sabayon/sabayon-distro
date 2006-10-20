# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="SabayonLinux Live tools for autoconfiguration of the system"
HOMEPAGE="http://www.sabayonlinux.org"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="alpha amd64 hppa ia64 mips ppc ppc64 sparc x86"
IUSE="opengl"

RDEPEND="dev-util/dialog
	sys-apps/pciutils
	sys-apps/gawk
	app-admin/eselect-opengl
	!app-misc/livecd-tools"

src_unpack() {
	cd ${WORKDIR}
	cp ${FILESDIR}/livecd-functions.sh . -p
	cp ${FILESDIR}/net-setup . -p
	if use amd64; then
		cp ${FILESDIR}/openglify-64 openglify -p
	else
		cp ${FILESDIR}/openglify-32 openglify -p
	fi
	cp ${FILESDIR}/x-setup . -p
	cp ${FILESDIR}/x-setup-init.d . -p

	cp ${FILESDIR}/bashlogin . -p

}

src_install() {
	cd ${WORKDIR}
	if use x86 || use amd64 || use ppc
	then
		if use opengl
		then
			dosbin x-setup openglify
			newinitd x-setup-init.d x-setup
		fi
	fi
	dosbin net-setup
	into /
	dosbin livecd-functions.sh
	dobin bashlogin
	

}
