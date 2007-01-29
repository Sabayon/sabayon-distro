# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="GUI for QEMU and KVM emulators - development snapshot"
HOMEPAGE="http://www.brain-dump.org/projects/qemu-gui"
SRC_URI="${HOMEPAGE}/downloads/${PN}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="kvm"
RESTRICT="nomirror"

S="${WORKDIR}/${PN}"

DEPEND="
	x11-libs/wxGTK
	net-libs/libvncserver
	|| ( app-emulation/qemu app-emulation/kvm )
	"

src_unpack() {
	unpack ${A}
	cd ${S}
	# change qemu executable to kvm
	if use kvm; then
		epatch ${FILESDIR}/${PN}-kvm-support.patch
	fi
}

src_install() {
	cd "${S}"
	exeinto /usr/share/qemu-gui
	doexe qemu-ui
	insinto /usr/share/qemu-gui
	doins welcome.html
	doins -r icons
	dosym /usr/share/qemu-gui/qemu-ui /usr/bin/qemu-gui	
}

pkg_postinst() {
	ewarn "This is a development package."
}
