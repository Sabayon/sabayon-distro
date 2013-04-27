# Copyright 2004-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils systemd

DESCRIPTION="Sabayon Live tools for autoconfiguration of the system"
HOMEPAGE="http://www.sabayon.org"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

DEPEND=""
RDEPEND="!app-misc/livecd-tools
	app-admin/eselect-opengl
	dev-util/dialog
	sys-apps/gawk
	sys-apps/pciutils
	>=sys-apps/keyboard-configuration-helpers-2.6
	sys-apps/sed"

S="${WORKDIR}"

src_unpack() { :; }

src_install() {
	local dir="${FILESDIR}/${PV}"

	exeinto /usr/libexec
	doexe "${dir}/installer-text.sh"
	doexe "${dir}/installer-gui.sh"
	doexe "${dir}/sabayonlive.sh"
	doexe "${dir}/x-setup.sh"
	doexe "${dir}/cdeject.sh"

	dosbin "${dir}/x-setup-configuration"
	newinitd "${dir}/x-setup-init.d" x-setup

	dosbin "${dir}/net-setup"
	into /
	dosbin "${dir}/"*-functions.sh
	dosbin "${dir}/logscript.sh"
	dobin "${dir}/bashlogin"
	dobin "${dir}/vga-cmd-parser"

	exeinto /usr/bin
	doexe "${dir}/livespawn"
	doexe "${dir}/sabutil"
	doexe "${dir}/sabayon-live-check"
	doexe "${dir}/sabayon-welcome-loader"

	dodir /etc/sabayon
	insinto /etc/sabayon
	doins "${dir}/sabayon-welcome-loader.desktop"

	dodir /usr/share/sabayonlive-tools/xorg.conf.d
	insinto /usr/share/sabayonlive-tools/xorg.conf.d

	doinitd "${dir}/sabayonlive"
	systemd_dounit "${dir}/sabayonlive.service"
	systemd_dounit "${dir}/x-setup.service"

	doinitd "${dir}/installer-gui"
	systemd_dounit "${dir}/installer-gui.service"

	doinitd "${dir}/installer-text"
	systemd_dounit "${dir}/installer-text.service"

	doinitd "${dir}/cdeject"
	systemd_dounit "${dir}/cdeject.service"
}
