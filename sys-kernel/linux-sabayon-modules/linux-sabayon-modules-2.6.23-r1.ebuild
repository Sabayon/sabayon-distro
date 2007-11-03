# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Sabayon Linux kernel modules meta package"
HOMEPAGE="http://www.sabayonlinux.org/"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="=sys-kernel/linux-sabayon-${PVR}"
RDEPEND="
	media-video/gspcav1
	app-emulation/kvm
	app-emulation/virtualbox-modules
	app-crypt/truecrypt
	x11-drivers/nvidia-drivers
	net-wireless/madwifi-ng
	net-wireless/ndiswrapper
	net-dialup/slmodem
	net-misc/et131x
	"
