# Copyright 2004-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils systemd

DESCRIPTION="Sabayon live image scripts and tools"
HOMEPAGE="http://www.sabayon.org"
SRC_URI="https://github.com/Sabayon/sabayon-live/archive/v${PVR}.tar.gz -> ${PVR}.tar.gz"
RESTRICT="mirror"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 arm x86"
IUSE=""
S="${WORKDIR}/${PN}-${PVR}"
DEPEND=""
RDEPEND="!app-misc/livecd-tools
	!sys-apps/gpu-detector
	app-eselect/eselect-opengl
	dev-util/dialog
	sys-apps/gawk
	sys-apps/pciutils
	sys-apps/keyboard-configuration-helpers
	sys-apps/sed
	sys-apps/dmidecode"

src_install() {
	emake DESTDIR="${D}" SYSV_INITDIR="/etc/init.d" \
		SYSTEMD_UNITDIR="$(systemd_get_unitdir)" \
		install || die
}
