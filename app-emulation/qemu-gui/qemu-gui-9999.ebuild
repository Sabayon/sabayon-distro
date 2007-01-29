# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="GUI for QEMU and KVM emulators - development snapshot"
HOMEPAGE="http://www.brain-dump.org/projects/qemu-gui"
SRC_URI="${HOMEPAGE}/downloads/${PN}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
RESTRICT="nomirror"

S="${WORKDIR}/${PN}"

DEPEND="
	x11-libs/wxGTK
	net-libs/libvncserver
	|| ( app-emulation/qemu app-emulation/kvm )
	"

pkg_postinst() {
	ewarn "This is a development package."
}
