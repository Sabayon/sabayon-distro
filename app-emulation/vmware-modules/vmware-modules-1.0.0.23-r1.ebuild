# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/vmware-modules/vmware-modules-1.0.0.23.ebuild,v 1.2 2009/01/12 21:42:37 maekke Exp $

KEYWORDS="amd64 x86"
VMWARE_VER="VME_V65" # THIS VALUE IS JUST A PLACE HOLDER

inherit eutils vmware-mod

LICENSE="GPL-2"
IUSE=""

VMWARE_MODULE_LIST="vmmon vmnet vmblock vmci vsock"
SRC_URI="x86? ( http://dev.gentoo.org/~ikelos/devoverlay-distfiles/${P}.x86.tar.bz2 )
		 amd64? ( http://dev.gentoo.org/~ikelos/devoverlay-distfiles/${P}.amd64.tar.bz2 )"
VMWARE_MOD_DIR="${P}"

src_unpack() {
	vmware-mod_src_unpack
	cd "${S}"
	epatch "${FILESDIR}/${PV}-makefile-kernel-dir.patch"
	epatch "${FILESDIR}/${PN}-2.6.29.patch"
}
