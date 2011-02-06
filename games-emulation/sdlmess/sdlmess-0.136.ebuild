# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils flag-o-matic games

DESCRIPTION="Multiple Arcade Machine Emulator (SDL)"
HOMEPAGE="http://rbelmont.mameworld.info/?page_id=163"

MY_PV=${PV/.}
MY_PV=${MY_PV/_p/u}
MY_P=${PN}${MY_PV}

# Upstream doesn't allow fetching with unknown User-Agent such as wget
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${MY_P}.zip"

# Same as xmame. Should it be renamed to MAME?
LICENSE="XMAME"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug +opengl"

RESTRICT="mirror"

RDEPEND=">=media-libs/libsdl-1.2.10[opengl?]
	sys-libs/zlib
	dev-libs/expat
	x11-libs/libXinerama
	debug? (
		>gnome-base/gconf-2
		>=x11-libs/gtk+-2 )"

DEPEND="${RDEPEND}
	app-arch/unzip
	x11-proto/xineramaproto"

S=${WORKDIR}/${MY_P}

# Function to disable a makefile option
disable_feature() {
	sed -i \
		-e "/$1.*=/s:^:# :" \
		"${S}"/makefile.sdl \
		|| die "sed failed"
}

# Function to enable a makefile option
enable_feature() {
	sed -i \
		-e "/^#.*$1.*=/s:^# ::"  \
		"${S}"/makefile.sdl \
		|| die "sed failed"
}

src_prepare() {
	sed -i \
		-e '/CFLAGS += -O$(OPTIMIZE)/s:^:# :' \
		-e '/CFLAGS += -pipe/s:^:# :' \
		-e '/LDFLAGS += -s/s:^:# :' \
		-e 's:-Werror::' \
		"${S}"/makefile.sdl \
		|| die "sed failed"

	# CFLAGS and build debugging help
	#sed -i \
	#	-e "/^\(AR\|CC\|LD\|RM\) =/s:@::" \
	#	-i "${S}"/makefile

	# Don't compile zlib and expat
	einfo "Disabling embedded libraries: zlib and expat"
	disable_feature BUILD_ZLIB
	disable_feature BUILD_EXPAT

	if use amd64; then
		einfo "Enabling 64-bit support"
		enable_feature PTR64
	fi

	if use ppc; then
		einfo "Enabling PPC support"
		enable_feature BIGENDIAN
	fi

	if use debug ; then
		ewarn "Building with DEBUG support is not recommended for normal use"
		enable_feature DEBUG
		enable_feature PROFILE
		enable_feature SYMBOLS
		enable_feature DEBUGGER
	fi

}

src_compile() {
	local make_opts
	use opengl || make_opts="${make_opts} NO_OPENGL=1"

	emake \
		NAME="${PN}" \
		OPT_FLAGS='-DINI_PATH=\"\$$HOME/.sdlmess\;'"${GAMES_SYSCONFDIR}/${PN}"'\"'" ${CFLAGS}" \
		SUFFIX="" \
		${make_opts} \
		-f makefile.sdl \
		|| die "emake failed"
}

src_install() {
	dogamesbin "${PN}" || die "dogamesbin ${PN} failed"

	# Follows xmame ebuild, avoiding collision on /usr/games/bin/jedutil
	exeinto "$(games_get_libdir)/${PN}"
	local f
	for f in chdman ldverify imgtool jedutil romcmp testkeys; do
		doexe "${f}" || die "doexe ${f} failed"
	done

	insinto "${GAMES_DATADIR}/${PN}"
	doins ui.bdf || die "doins ui.bdf failed"
	doins -r keymaps || die "doins -r keymaps failed"

	insinto "${GAMES_SYSCONFDIR}/${PN}"
	doins "${FILESDIR}"/{joymap.dat,vector.ini} || die "doins joymap.dat vector.ini failed"

	sed \
		-e "s:@GAMES_SYSCONFDIR@:${GAMES_SYSCONFDIR}:" \
		-e "s:@GAMES_DATADIR@:${GAMES_DATADIR}:" \
		"${FILESDIR}"/mess.ini.in > "${D}/${GAMES_SYSCONFDIR}/${PN}/"mess.ini \
		|| die "sed failed"

	dodoc docs/{config,mame,newvideo}.txt *.txt

	keepdir "${GAMES_DATADIR}/${PN}"/{roms,samples,artwork}
	keepdir "${GAMES_SYSCONFDIR}/${PN}"/ctrlr

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	elog "It's strongly recommended that you change either the system-wide"
	elog "mess.ini at \"${GAMES_SYSCONFDIR}/${PN}\" or use a per-user setup at \$HOME/.${PN}"

	if use opengl; then
		elog ""
		elog "You built ${PN} with opengl support and should set"
		elog "\"video\" to \"opengl\" in mess.ini to take advantage of that"
	fi
}
