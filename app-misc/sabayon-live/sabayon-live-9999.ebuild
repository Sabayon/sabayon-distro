# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils systemd git-r3

DESCRIPTION="Sabayon live image scripts and tools"
HOMEPAGE="http://www.sabayon.org"
EGIT_REPO_URI="https://github.com/Sabayon/sabayon-live.git"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS=""
IUSE=""
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
	emake DESTDIR="${D}" \
		SYSTEMD_UNITDIR="$(systemd_get_systemunitdir)" \
		install || die
}
