# Copyright 2004-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

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

S="${WORKDIR}"

src_unpack() {
	cp "${FILESDIR}"/${PV}/*-functions.sh . -p          || die "unpack failed"
	cp "${FILESDIR}"/${PV}/net-setup . -p               || die "unpack failed"
	cp "${FILESDIR}"/${PV}/x-setup-init.d . -p          || die "unpack failed"
	cp "${FILESDIR}"/${PV}/installer-gui . -p           || die "unpack failed"
	cp "${FILESDIR}"/${PV}/installer-text . -p          || die "unpack failed"
	cp "${FILESDIR}"/${PV}/x-setup-configuration . -p   || die "unpack failed"
	cp "${FILESDIR}"/${PV}/bashlogin . -p               || die "unpack failed"
	cp "${FILESDIR}"/${PV}/sabayonlive . -p             || die "unpack failed"
	cp "${FILESDIR}"/${PV}/vga-cmd-parser . -p          || die "unpack failed"
	cp "${FILESDIR}"/${PV}/logscript.sh . -p            || die "unpack failed"
	cp "${FILESDIR}"/${PV}/sabutil . -p                 || die "unpack failed"
	cp "${FILESDIR}"/${PV}/livespawn . -p               || die "unpack failed"
	cp "${FILESDIR}"/${PV}/sabayon-live-check . -p      || die "unpack failed"
	cp "${FILESDIR}"/${PV}/sabayon-welcome-loader* . -p || die "unpack failed"
	cp "${FILESDIR}"/${PV}/cdeject . -p                 || die "unpack failed"
}

src_install() {
	dosbin x-setup-configuration
	newinitd x-setup-init.d x-setup

	dosbin net-setup
	into /
	dosbin *-functions.sh
	dosbin logscript.sh
	dobin bashlogin
	dobin vga-cmd-parser
	exeinto /usr/bin
	doexe livespawn
	doexe sabutil
	doexe sabayon-live-check
	doexe sabayon-welcome-loader

	dodir /etc/sabayon
	insinto /etc/sabayon
	doins sabayon-welcome-loader.desktop

	#insinto /etc/X11
	#doins xorg.conf.sabayon

	dodir /usr/share/sabayonlive-tools/xorg.conf.d
	insinto /usr/share/sabayonlive-tools/xorg.conf.d
	# fglrx <12.2 Xv workaround, enabled at runtime
	doins "${FILESDIR}/${PV}/xorg.conf.d/90-fglrx-12.1-and-older-workaround.conf"

	newinitd sabayonlive sabayonlive
	newinitd installer-gui installer-gui
	newinitd installer-text installer-text
	newinitd cdeject cdeject

}
