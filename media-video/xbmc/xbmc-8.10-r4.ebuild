# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
inherit autotools eutils flag-o-matic

SRC_URI="mirror://sourceforge/${PN}/XBMC-${PV}.src.tar.gz"
DESCRIPTION="XBMC is a free and open source media-player and entertainment hub"
HOMEPAGE="http://xbmc.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="autostart ccache debug gprof +joystick mms opengl"
RDEPEND="ccache? ( dev-util/ccache )
	mms? ( media-libs/libmms )
	opengl? ( virtual/opengl )
	app-arch/bzip2
	app-arch/unrar
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	dev-lang/python[sqlite]
	dev-libs/boost
	dev-libs/fribidi
	dev-libs/libpcre
	dev-libs/lzo
	dev-libs/tre
	media-libs/alsa-lib[debug]
	media-libs/faac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glew
	media-libs/jasper
	media-libs/libmad
	media-libs/libogg
	media-libs/libvorbis
	media-libs/sdl-gfx
	media-libs/sdl-image[jpeg,gif,png]
	media-libs/sdl-mixer
	media-libs/sdl-sound
	net-misc/curl
	sys-apps/dbus
	sys-apps/hal
	sys-apps/lsb-release
	sys-apps/pmount
	virtual/mysql
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-proto/xineramaproto
	|| ( media-libs/libsdl[alsa,X,-nojoystick]
	media-libs/libsdl[alsa,X,joystick] )
	"
DEPEND="${RDEPEND}
	dev-util/cmake
	dev-lang/nasm
	"

S="${WORKDIR}/XBMC"

pkg_setup() {

        if use autostart; then
		XBMC_GROUPS="video,audio,cdrom,plugdev,tty,uucp,usb"
		enewuser xbmc -1 /bin/bash /home/xbmc ${XBMC_GROUPS}
		usermod -a -G ${XBMC_GROUPS} xbmc
	fi
}

src_unpack() {
	unpack ${A}
	cd ${S}

	# Enable support for XBMC to read data DVD discs #
	# See http://xbmc.org/trac/attachment/ticket/5296/ #
	epatch "${FILESDIR}/xbmc.readsector.patch"

	# XBMC's autotools files (configure.{ac,in}, Makefile.{ac,in}, ltmain.sh, etc.) can be distro specific #
	# and in need of some love. If we need to regenerate 'configure', 'Makefile', 'ltmain.sh', etc., #
	# (in the case where we don't run Debian/Ubuntu or have a version of libtool greater than 1.5*), #
	# we run into problems, so let's clean this up #
	for file in {configure,*.pl}; do
		find . -name "${file}" -exec chmod +x {} \;
	done
	for file in `find . -name configure.ac`; do
		echo 'AC_PROG_CXX' >> "${file}"
	done
	for file in `find . -name configure.in`; do
		echo 'AC_PROG_CXX' >> "${file}"
		sed -e '/AM_PATH_XMMS/ c\echo' \
			-i ${file} || die "Sed failed for '"${file}"'"
		sed -e '/AM_PATH_SDL2/ c\echo' \
			-i ${file} || die "Sed failed for '"${file}"'"
	done
	sed -e 's/test_libFLAC++//g' \
		-i xbmc/cores/paplayer/flac-1.2.1/src/Makefile.am || \
			die "Sed failed for '"${S}/xbmc/cores/paplayer/flac-1.2.1/src/Makefile.am"'"

	# Prevent Mac OSX files being installed #
	rm -rf system/python/lib-osx/
	rm system/players/dvdplayer/*-osx*

	# Clean up XBMC's wrapper script #
		echo '#!/bin/sh' > tools/Linux/xbmc.sh.in
		echo '' >> tools/Linux/xbmc.sh.in
		echo 'export XBMC_PLATFORM_MODE=1' >> tools/Linux/xbmc.sh.in

		# media-libs/libsdl defaults to 'oss' if built with that USE flag
		# which is incompatible with xbmc, so force it to use 'alsa'
		echo 'export SDL_AUDIODRIVER=alsa' >> tools/Linux/xbmc.sh.in

		echo 'exec @prefix@/share/xbmc/xbmc.bin -fs $*' >> tools/Linux/xbmc.sh.in

	for dir in \
		. \
		xbmc/cores/dvdplayer/Codecs/libDVDCSS \
		xbmc/cores/dvdplayer/Codecs/libdts \
		xbmc/cores/dvdplayer/Codecs/libdvdnav \
		xbmc/cores/dvdplayer/Codecs/libfaad2 \
		xbmc/cores/dvdplayer/Codecs/libmad \
		xbmc/cores/dvdplayer/Codecs/libmpeg2 \
		xbmc/cores/paplayer/flac-1.2.1 \
		xbmc/cores/paplayer/vorbisfile/libvorbis \
		xbmc/cores/paplayer/vorbisfile/ogg \
		xbmc/visualizations/Goom/goom2k4-0 \
		xbmc/lib/libass \
		xbmc/lib/libid3tag/libid3tag
	do
		cd ${S}/${dir}
		eautoreconf
	done
	cd ${S}

	# Fix XBMC's final version string showing as "exported" instead of the version number #
	sed -e "s/\$(svnversion -n .)/${PV}/g" \
		-i configure || die "Sed failed for '"${S}/configure"'"

	# Disable problem building of internal linked libraries' API docs if latex/doxygen are present #
	sed -e 's#^AC_PATH_PROG(LATEX.*$#LATEX="no"#g' \
		-i xbmc/cores/dvdplayer/Codecs/libDVDCSS/configure.ac || \
			die "Sed failed for '"${S}/xbmc/cores/dvdplayer/Codecs/libDVDCSS/configure.ac"'"
}

src_compile() {
	# Strip out the use of custom C{XX}FLAGS to make debugging easier for upstream #
	# This is needed regardless of whether USE="debug" is set otherwise segfaults result #
	# Tested to happen with MP3 playback when MACDll-i486-linux.so loads + fails trying to read ID3 info #
        strip-flags

	econf \
		$(use_enable ccache) \
		$(use_enable debug) \
		$(use_enable gprof profiling) \
		$(use_enable joystick) \
		$(use_enable mms) \
		$(use_enable opengl gl) \
		|| die "Configure failed!"

	# Libtool greater than 1.5* has 'autoconf' creating a corrupt 'configure' script in these #
	# directories with the following errors ... #
	# './configure: line xxx: _LT_CMD_GLOBAL_SYMBOLS: command not found' #
	# or #
	# X--tag=CC: command not found #
	# Not sure why, maybe the configure.ac needs to be re-written to support the newer tools or maybe #
	# it needs to be invoked in some special way #
	# Anyway, libtoolize is not necessary in these modules, so we're able to get away with using the distributed #
	# 'configure' script without running 'autoconf' and friends, but need to disable the generated Makefile #
	# from running 'autoconf' etc.
	for makefile in \
		xbmc/screensavers/rsxs-0.9/Makefile \
		xbmc/cores/paplayer/MPCCodec/Makefile
	do
		for ac_tool in {ACLOCAL,AUTOCONF,AUTOHEADER,AUTOMAKE}; do
			sed -e "/^${ac_tool} = / c\\${ac_tool} = echo" \
				-i "${makefile}" || \
					die "Sed failed for ${ac_tool} in '"${S}/${makefile}"'"
		done
	done

	emake || die "Make failed!"
	cd "${S}"

	if use autostart; then
		echo 'int main() {' > autologinxbmc.c
		echo '  execlp("login", "login", "-f", "xbmc", 0);' >> autologinxbmc.c
		echo '}' >> autologinxbmc.c
		$(tc-getCC) -w -o autologinxbmc autologinxbmc.c
	fi

	einfo
	einfo "Generating textures..."
	einfo
	for skin in skin/* ; do
		./tools/XBMCTex/XBMCTex -input "\"${skin}/media/\"" \
			-output "\"${skin}/media/Textures.xpr\"" || die "XBMCTex failed..."
	done

	# Fix case sensitivity #
	mv "${S}/media/Fonts/arial.ttf" "${S}/media/Fonts/Arial.ttf"
	mv "${S}/media/Splash.png" "${S}/media/splash.png"

	# Unzip web content #
	unzip "${S}"/web/Project_Mayhem_III_webserver_*.zip -d "${S}/web/" || die "Unzip web content failed..."
}

src_install() {
	einstall INSTALL_ROOT="${D}" || die "Install failed!"

	for doc in LICENSE.GPL README.linux copying.txt known_issues.txt; do dodoc "${doc}"; done
        rm ${D}/usr/share/xbmc/README.linux ${D}/usr/share/xbmc/LICENSE.GPL ${D}/usr/share/xbmc/*.txt

	insinto /usr/share/applications
	doins tools/Linux/xbmc.desktop
	insinto /usr/share/pixmaps
	doins tools/Linux/xbmc.png

	dodir /etc/env.d
        if use autostart; then
		echo 'CONFIG_PROTECT="/usr/share/xbmc/userdata /home/xbmc"' > "${D}/etc/env.d/95xbmc"

		echo '/usr/bin/xbmc' > .xinitrc
		echo 'case "`tty`" in' > .bash_profile
		echo '	*tty8) xinit -- :$(echo $[`(ls /tmp/.X?-lock 2> /dev/null) | tail -n1 | sed "s,^/tmp/.X\(.*\)-lock$,\1,"` + 1]); logout ;;' >> .bash_profile
		echo 'esac' >> .bash_profile

		insinto /home/xbmc
		doins .bash_profile
		doins .xinitrc

		exeinto /usr/sbin
		doexe autologinxbmc
	else
		echo 'CONFIG_PROTECT="/usr/share/xbmc/userdata"' > "${D}/etc/env.d/95xbmc"
        fi
}

pkg_postinst() {
	elog
	elog "Toggle fullscreen mode using the backslash key"
	elog "To access a MythTV backend, add 'myth://<mythdb_user>:<mythdb_pass>@<hostname>/'"
	elog " as a new source in the 'Videos' section"
	elog "For further documentation, visit http://xbmc.org/wiki/?title=XBMC_Online_Manual"
	elog
	elog "Details on filing bugs to upstream can be found at"
	elog "http://xbmc.org/wiki/?title=HOW-TO_Submit_a_Proper_Bug_Report"
	elog "Make sure you (re)build with the 'debug' USE flag enabled"
	elog

	if use autostart; then
		elog "You have enabled 'USE=autostart', the following needs"
		elog " to be performed to complete the installation:"
		elog "Please add the following to your /etc/inittab file"
		elog "at the end of the TERMINALS section"
		elog "c8:2345:respawn:/sbin/agetty -n -l /usr/sbin/autologinxbmc 38400 tty8"
		elog
		elog "To have the system reload /etc/inittab without rebooting,"
		elog "issue 'init q' as root"
		elog
		elog "For the security conscious, please note that this automatically"
		elog "logins the user 'xbmc' with no authentication password necessary"
		elog
	else
		elog "To have XBMC start automatically, set 'USE=autostart'"
		elog
	fi
}
