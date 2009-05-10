# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit eutils games

MY_PN="PlayOnLinux"
DESCRIPTION="Set of scripts to easily configure wine for numerous 
Windows(tm) games."
HOMEPAGE="http://playonlinux.com/"
SRC_URI="http://www.playonlinux.com/script_files/${MY_PN}/${PV}/${MY_PN}_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
# ~amd64 will not work with no-multilib amd64 profiles.
# when ebuild will be in portage, playonlinux must be added as masked 
package
# for no-multilib amd64 profiles.
IUSE=""

DEPEND=""
RDEPEND="dev-python/wxpython:2.8
		app-arch/unzip
		app-arch/cabextract
		x11-terms/xterm
		app-emulation/wine
		media-gfx/imagemagick"

S=${WORKDIR}/${PN}

src_install() {
	# all things without exec permissions
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r "${S}/themes" \
		"${S}/lang"	"${S}/lib" \
		"${S}/etc" || die "installation failed"

	# bin/ install
	exeinto "${GAMES_DATADIR}/${PN}/bin"
	doexe "${S}"/bin/* || die "installation failed"

	# bash/ install
	exeinto "${GAMES_DATADIR}/${PN}/bash"
	doexe "${S}"/bash/* || die "installation failed"
	exeinto "${GAMES_DATADIR}/${PN}/bash/terminals"
	doexe "${S}"/bash/terminals/* || die "installation failed"
	exeinto "${GAMES_DATADIR}/${PN}/bash/expert"
	doexe "${S}"/bash/expert/* || die "installation failed"
	exeinto "${GAMES_DATADIR}/${PN}/bash/options"
	doexe "${S}"/bash/options/* || die "installation failed"

	# python/ install
	exeinto "${GAMES_DATADIR}/${PN}/python"
	doexe "${S}"/python/* || die "installation failed"
	exeinto "${GAMES_DATADIR}/${PN}/python/tools"
	doexe "${S}"/python/tools/* || die "installation failed"
	# sub dir without exec permissions
	insinto "${GAMES_DATADIR}/${PN}/python"
	doins -r "${S}"/python/lib || die "installation failed"

	# daemon/ install
	exeinto "${GAMES_DATADIR}/${PN}/daemon"
	doexe "${S}"/daemon/* || "installation failed"

	# main executable files
	exeinto "${GAMES_DATADIR}/${PN}"
	doexe "${S}/${PN}" || die "installation failed"
	doexe "${S}/${PN}-pkg" || die "installation failed"
	doexe "${S}/${PN}-daemon" || die "installation failed"

	# making a script to run app from ${GAMES_BINDIR}
	echo "#!/bin/bash" > ${PN}_launcher
	echo "cd \"${GAMES_DATADIR}/${PN}\" && ./${PN}" >> ${PN}_launcher
	newgamesbin playonlinux_launcher playonlinux || die "installation failed"

	dodoc CHANGELOG || die "doc installation failed"

	doicon "${S}/etc/${PN}.png"
	make_desktop_entry ${PN} ${MY_PN}
	prepgamesdirs
}

