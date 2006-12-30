# Copyright 1999-2006 Sabayon Linux - Fabio Erculiani
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="qemu emulator and abi wrapper meta ebuild"
HOMEPAGE="http://kvm.sourceforge.net/"
SRC_URI="
	x86? ( http://www.sabayonlinux.org/distfiles/app-emulation/${P}-x86.tar.bz2 )
	amd64? ( http://www.sabayonlinux.org/distfiles/app-emulation/${P}-amd64.tar.bz2 )
	"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=media-libs/alsa-lib-1.0.11
	>=media-libs/libsdl-1.2.10
	sys-fs/e2fsprogs
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	media-libs/libcaca
	>=sys-libs/ncurses-5.5
	"


src_install() {
	cd ${S}
	exeinto /usr/bin
	doexe usr/bin/kvm
	if [ ! -e /usr/bin/qemu-img ]; then
		doexe usr/bin/qemu-img
	fi
	doman usr/share/man/man*/*.1*
}
