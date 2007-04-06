# Copyright 1999-2006 Sabayon Linux - Fabio Erculiani
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="qemu emulator and abi wrapper meta ebuild"
HOMEPAGE="http://kvm.sourceforge.net/"
SRC_URI="
	x86? ( http://www.sabayonlinux.org/distfiles/app-emulation/${P}-x86.tar.gz )
	amd64? ( http://www.sabayonlinux.org/distfiles/app-emulation/${P}-amd64.tar.gz )
	"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RESTRICT="nomirror"

RDEPEND="${DEPEND}"

DEPEND=">=media-libs/alsa-lib-1.0.11
	>=media-libs/libsdl-1.2.10
	sys-fs/e2fsprogs
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	media-libs/libcaca
	>=sys-libs/ncurses-5.5
	>=sys-fs/udev-100	
	"


src_install() {

	cd ${WORKDIR}

	exeinto /usr/bin
	doexe usr/bin/kvm
	doexe usr/bin/qemu-img

	insinto /usr/share/
	doins -r usr/share/kvm
	doins -r usr/share/bug

	exeinto /etc/kvm
	doexe etc/kvm/kvm-ifup
	exeinto /etc/kvm/utils
	doexe etc/kvm/utils/kvm*

	#insinto /etc/udev/rules.d
	#doins etc/udev/*.rules
	
	doman usr/share/man/man*/*.1*

	if use doc; then
		dodoc usr/share/doc/kvm/*
	fi
}
