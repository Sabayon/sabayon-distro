# Copyright 2004-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2

inherit eutils

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
	>=sys-apps/keyboard-configuration-helpers-2.6"

src_unpack() {
	cd "${WORKDIR}"
	cp "${FILESDIR}"/${PV}/*-functions.sh . -p
	cp "${FILESDIR}"/${PV}/net-setup . -p
	cp "${FILESDIR}"/${PV}/x-setup-init.d . -p
	cp "${FILESDIR}"/${PV}/installer-gui . -p
	cp "${FILESDIR}"/${PV}/installer-text . -p
	cp "${FILESDIR}"/${PV}/x-setup-configuration . -p
	cp "${FILESDIR}"/${PV}/bashlogin . -p
	cp "${FILESDIR}"/${PV}/opengl-activator . -p
	cp "${FILESDIR}"/${PV}/sabayonlive . -p
	cp "${FILESDIR}"/${PV}/vga-cmd-parser . -p
	cp "${FILESDIR}"/${PV}/logscript.sh . -p
	cp "${FILESDIR}"/${PV}/sabutil . -p
	cp "${FILESDIR}"/${PV}/livespawn . -p
	cp "${FILESDIR}"/${PV}/sabayon-live-check . -p
	cp "${FILESDIR}"/${PV}/sabayon-welcome-loader* . -p
	cp "${FILESDIR}"/${PV}/cdeject . -p
}

src_install() {

	cd "${WORKDIR}"

	dosbin x-setup-configuration
	newinitd x-setup-init.d x-setup

	dosbin net-setup
	into /
	dosbin *-functions.sh
	dosbin logscript.sh
	dobin bashlogin
	dobin vga-cmd-parser
	exeinto /usr/bin
	doexe opengl-activator
	doexe livespawn
	doexe sabutil
	doexe sabayon-live-check
	doexe sabayon-welcome-loader

	dodir /etc/sabayon
	insinto /etc/sabayon
	doins sabayon-welcome-loader.desktop

	#insinto /etc/X11
	#doins xorg.conf.sabayon

	dodir /usr/share/X11/xorg.conf.d
	insinto /usr/share/X11/xorg.conf.d
	doins "${FILESDIR}/${PV}/xorg.conf.d/90-synaptics.conf"

	dodir /usr/share/sabayonlive-tools/xorg.conf.d
	insinto /usr/share/sabayonlive-tools/xorg.conf.d
	# fglrx <12.2 Xv workaround, enabled at runtime
	doins "${FILESDIR}/${PV}/xorg.conf.d/90-fglrx-12.1-and-older-workaround.conf"

	newinitd sabayonlive sabayonlive
	newinitd installer-gui installer-gui
	newinitd installer-text installer-text
	newinitd cdeject cdeject

}
