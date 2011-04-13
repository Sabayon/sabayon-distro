# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit autotools eutils 

PKGVER="0.9.23.15885"

SRC_URI="http://dl.boxee.tv/${PN}-sources-${PKGVER}.tar.bz2"
DESCRIPTION="Boxee is a fork of XBMC with a focus on social media"
HOMEPAGE="http://www.boxee.tv/"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug mid xrandr opengl"
RESTRICT="mirror bindist strict"

RDEPEND="opengl? ( virtual/opengl )
	app-arch/bzip2
	app-arch/unrar
	app-arch/unzip
	app-i18n/enca
	>=dev-lang/python-2.6
	dev-libs/boost
	dev-libs/fribidi
	dev-libs/libpcre
	dev-libs/lzo
	dev-libs/tre
	>=dev-python/pysqlite-2
	media-libs/alsa-lib
	media-libs/faac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glew
	media-libs/jasper
	media-libs/libmad
	media-libs/libmms
	media-libs/libsamplerate
	media-libs/libogg
	media-libs/libvorbis
	media-libs/libsdl[alsa,X]
	media-libs/sdl-gfx
	media-libs/sdl-image[gif,jpeg,png]
	media-libs/sdl-mixer
	media-libs/sdl-sound
	net-libs/xulrunner
	www-plugins/adobe-flash
	net-misc/curl
	sys-apps/dbus
	sys-apps/hal
	sys-apps/pmount
	virtual/mysql
	x11-libs/libvdpau
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	dev-util/cmake
	app-misc/screen
	x86? ( dev-lang/nasm
			virtual/krb5 )"

RESTRICT="strip"

S=${WORKDIR}/${PN}-sources-${PKGVER}

src_unpack() {
	local pic

	if [ $(uname -m) = "x86_64" ]; then
	my_arch=x86_64
	else
	my_arch=i486
	fi || die "Set arch failed"

	my_prefix=/opt/${PN}
	pic="-fPIC"

	unpack ${A}
	cd "${S}"

	# this section contains changes required for x86_64 and thus is only loaded if your arch is x86_64

	if [ $(uname -m) = "x86_64" ]; then

	# boxee64.patch allows boxee to compile on 64bit systems
	epatch "${FILESDIR}/boxee64.patch" || die "Patch failed"

	# ffmpeg needs to be patched for 64bit systems
	epatch "${FILESDIR}/ffmpeg64.patch" || die "Patch failed"

	# two symlinks added by paulingham that work with boxee64.patch to allow boxee to compile on x86_64
	dosym /usr/lib/libtalloc.so.2 ${S}/xbmc/lib/libsmb/libtalloc-x86_64-linux.a
	dosym /usr/lib/libwbclient.so.0 ${S}/xbmc/lib/libsmb/libwbclient-x86_64-linux.a
			
		_xulrunner=xulrunner-x86_64-linux
	else
		_xulrunner=xulrunner-i486-linux
	fi || return 1
	
	# anish.patch adds some minor tweaks anish figured out to get the latest sources running
	epatch "${FILESDIR}/anish.patch" || die "Patch failed"

	# fribidi.patch fixes the compile issue related to fribidi 
	epatch "${FILESDIR}/fribidi.patch" || die "Patch failed"

	# patch to compile against libpng14, thanks to wonder for providing the original patch
	epatch "${FILESDIR}/libpng.patch" || die "Patch failed"

	# patch to compilet release 0.9.21.12563, remove extraneous function calls that cause linkage failure
	epatch "${FILESDIR}/12563_fix.patch" || die "Patch failed"

	# patch to fix libmms 
	epatch "${FILESDIR}/libmms.patch" || die "Patch failed"

	# fix the old Para.py syntax errors
	epatch "${FILESDIR}/boxee-0.9.21.11497-fix_Para_py.patch" || die "Patch failed"

	# fix python include thread policy
	cp /usr/include/python2.6/pyconfig.h ${S}/xbmc/lib/libPython/Python/Include
	cp ${S}/xbmc/{ThreadPolicy.cpp,ThreadPolicy.h} ${S}/xbmc/lib/libPython
	epatch "${FILESDIR}/boxee-0.9.21.12563-fix_python_a-include_ThreadPolicy.patch" || die "Patch failed"
	
	cd "${S}"/xbmc/lib/libass
		./autogen.sh || die "libass failed"
		autoreconf --install || die "libass failed"
	
	cd "${S}"/xbmc/lib/libBoxee/tinyxpath 
		autoreconf -vif || die "tinyxpath failed"
		./configure || die "tinyxpath failed"

	cd "${S}"/xbmc/visualizations/Goom/goom2k4-0 
		aclocal || die "goom2k4-0 failed"
		libtoolize --copy --force || die "goom2k4-0 failed"
		./autogen.sh --enable-static --with-pic || die "goom2k4-0 failed"

}

src_configure() {
	aclocal || die "aclocal failed!"
	autoheader || die "autoheader failed!"
	autoconf || die "autoconf failed!"

	econf \
		--disable-ccache \
		--prefix=${my_prefix} \
		$(use_enable debug) \
		$(use_enable mid) \
		$(use_enable xrandr) \
		|| die "Configure failed!"

	cd "${S}"

	#this is another hack to fix an issue with gcc44
	
	if [ $(uname -m) = "x86_64" ]; then
	sed -r 's/\(MAKE\)\ -C\ xbmc\/screensavers$/\(MAKE\)\ CFLAGS=\"-march=k8\ -02\ -pipe\"\ -C\ xbmc\/screensavers/g' Makefile > Makefile.sed || die "sed failed"
	else
	sed -r 's/\(MAKE\)\ -C\ xbmc\/screensavers$/\(MAKE\)\ CFLAGS=\"-march=i486\ -02\ -pipe\"\ -C\ xbmc\/screensavers/g' Makefile > Makefile.sed || die "sed failed"
	fi
	cat Makefile.sed > Makefile || die "cat failed"

}

src_compile() {
	cd "${S}"
	emake -j1 || die "Make boxee failed!"
}

src_install() {

	cd "${S}"

	# language

	install -d ${my_prefix}/language || return 1
	pushd ${S}/language/ || return 1
		find . | sed -e 's/\.\///g' | while read file; do
			if [ -d "$file" ]; then
				install -d ${my_prefix}/language/"$file" || return 1
			else
				install -D "$file" ${my_prefix}/language/"$file" || return 1
			fi || return 1
		done || return 1
	popd || return 1

	# media

	install -d ${my_prefix}/media || return 1
	pushd ${S}/media/ || return 1
		find . | sed -e 's/\.\///g' | while read file; do
			if [ $(echo "$file" | grep "icon.png" -i -c) = 0 -a $(echo "$file" | grep "icon32x32.png" -i -c) = 0 -a $(echo "$file" | grep "xbmc.icns" -i -c) = 0 -a $(echo "$file" | grep "Boxee.ico" -i -c) = 0 -a $(echo "$file" | grep "Splash.png" -i -c) = 0 -a $(echo "$file" | grep "Splash_old.png" -i -c) = 0 -a $(echo "$file" | grep "Fonts/arial.ttf" -i -c) = 0 ]; then
				if [ -d "$file" ]; then
					install -d ${my_prefix}/media/"$file" || return 1
				else
					install -D "$file" ${my_prefix}/media/"$file" || return 1
				fi || return 1
			fi || return 1
		done || return 1
	popd || return 1

	# scripts

	install -d ${my_prefix}/scripts || return 1
	pushd ${S}/scripts || return 1
		find . | sed -e 's/\.\///g' | while read file; do
			if [ $(echo "$file" | grep "scripts.zip" -i -c) = 0 -a $(echo "$file" | grep "user_submitted.zip" -i -c) = 0 -a $(echo "$file" | grep "autoexec.py" -i -c) = 0 ]; then
				if [ -d "$file" ]; then
					install -d ${my_prefix}/scripts/"$file" || return 1
				else
					install -D "$file" ${my_prefix}/scripts/"$file" || return 1
				fi || return 1
			fi || return 1
		done || return 1
	popd || return 1

	# skin

	install -d ${my_prefix}/skin/boxee || return 1
	pushd ${S}/skin/boxee || return 1
		find . | sed -e 's/\.\///g' | while read file; do

				if [ -d "$file" ]; then
					install -d ${my_prefix}/skin/boxee/"$file" || return 1
				else
					install -D "$file" ${my_prefix}/skin/boxee/"$file" || return 1
				fi || return 1
		done || return 1
		install -d ${my_prefix}/skin/boxee/media || return 1
	popd || return 1

	# system

	pushd ${S}/system/python/local || return 1
	popd || return 1
	
	install -d ${my_prefix}/system || return 1
	pushd ${S}/system/ || return 1
		find . -path "./python/Lib" -prune -o -print | sed -e 's/\.\///g' | while read file; do
			if [ $(echo "$file" | grep "win32" -i -c) = 0 -a $(echo "$file" | grep "spyce" -i -c) = 0 -a $(echo "$file" | grep "DLLs" -i -c) = 0 -a $(echo "$file" | grep "osx" -i -c) = 0 -a $(echo "$file" | grep -e "\.dll$" -i -c) = 0 -a $(echo "$file" | grep -e "\.pyc$" -i -c) = 0 -a $(echo "$file" | grep "xulrunner" -i -c) = 0 -a $(echo "$file" | grep "etc" -i -c) = 0 -a $(echo "$file" | grep "python24.zlib" -i -c) = 0 -a $(echo "$file" | grep "upnpserver.xml" -i -c) = 0 -a $(echo "$file" | grep "IRSSmap.xml" -i -c) = 0 -a $(echo "$file" | grep "X10-Lola-IRSSmap.xml" -i -c) = 0 -a $(echo "$file" | grep "fontconfig_readme" -i -c) = 0 -a $(echo "$file" | grep "libmpeg2-i486-linux.so" -i -c) = 0 -a $(echo "$file" | grep "bxoverride.so" -i -c) = 0 -a $(echo "$file" | grep "readme.txt" -i -c) = 0 -a $(echo "$file" | grep "simplejson/_speedups.so" -i -c) = 0 ]; then
				if [ -d "$file" ]; then
					install -d ${my_prefix}/system/"$file" || return 1
				else
					install -D "$file" ${my_prefix}/system/"$file" || return 1
				fi || return 1
			fi || return 1
		done || return 1
	popd || return 1

	install -d ${my_prefix}/system/players/flashplayer/${_xulrunner} || return 1
	pushd ${S}/system/players/flashplayer/${_xulrunner} || return 1
		find . | sed -e 's/\.\///g' | while read file; do
			if [ -d "$file" ]; then
				install -d ${my_prefix}/system/players/flashplayer/${_xulrunner}/"$file" || return 1
			else
				install -D "$file" ${my_prefix}/system/players/flashplayer/${_xulrunner}/"$file" || return 1
			fi || return 1
		done || return 1
	popd || return 1
	
	install -d ${my_prefix}/system/python/lib || return 1
	pushd ${S}/system/python/Lib || return 1

	find . | sed -e 's/\.\///g' | while read file; do
		if [ $(echo "$file" | grep -e "darwin$" -e "mac$" -i -c) = 0 ]; then
			if [ -d "$file" ]; then
				install -d ${my_prefix}/system/python/lib/"$file" || return 1
			elif [ ! $(echo "$file" | grep -e "\.pyo$" -i -c) = 0 ]; then
				install -D "$file" ${my_prefix}/system/python/lib/"$file" || return 1
			elif [ ! $(echo "$file" | grep -e "\.so$" -i -c) = 0 ]; then
				install -D "$file" ${my_prefix}/system/python/lib/"$file" || return 1	
			fi || return 1
		fi || return 1
	done || return 1
	popd || return 1

	rm -rf ${my_prefix}/system/python/lib/plat-darwin || return 1
	rm -rf ${my_prefix}/system/python/lib/plat-mac || return 1
	rmdir ${my_prefix}/system/python/lib/idlelib/Icons || return 1
	rmdir ${my_prefix}/system/python/lib/site-packages || return 1

	# userdata

	cd ${S}/UserData
	mv sources.xml.in.diff.linux sources.xml || die "moving userdata failed!"
	mv advancedsettings.xml.in advancedsettings.xml || die "moving userdata failed!"
	cd ${S}
	insinto ${my_prefix}/UserData
	doins -r UserData/{*linux*,advancedsettings.xml,sources.xml} 
	dosym UserData ${my_prefix}/userdata 

	# plugins

	dodir ${my_prefix}/plugins/music
	dodir ${my_prefix}/plugins/pictures
	dodir ${my_prefix}/plugins/video	

	# visualisations

	install -d ${my_prefix}/visualisations/
	pushd ${S}/visualisations/ || return 1
	for i in *; do
		if [ -d "$i" ]; then
			install -d ${my_prefix}/visualisations/"$i" || return 1
			if [ $(ls "$i" | wc -l) != "0" ]; then
				install -D "$i"/* ${my_prefix}/visualisations/"$i"/ || return 1
			fi || return 1
		else
			if [ $(echo "$i" | grep "osx" -c) = "0" -a $(echo "$i" | grep "win32" -c) = "0" -a $(echo "$i" | grep "Goom.vis" -c) = "0" -a $(echo "$i" | grep "xbmc_vis.h" -c) = "0" ]; then
				install -D "$i" ${my_prefix}/visualisations/ || return 1
			fi || return 1
		fi || return 1
        done || return 1
	popd || return 1

	# screensavers
	insinto ${my_prefix}/screensavers 
	dodir ${my_prefix}/screensavers
	doins -r screensavers/*.xbs 

	# rtorrent
	dodir ${my_prefix}/bin
	exeinto ${my_prefix}/bin 
	doexe bin-linux/boxee-rtorrent

	# boxee binary
	mv run-boxee-desktop.in run-boxee-desktop
	exeinto ${my_prefix}/
	doexe Boxee
	doexe run-boxee-desktop
		
	# give_me_my_mouse_back
	gcc ${S}/give_me_my_mouse_back.c -o ${S}/give_me_my_mouse_back -lSDL || die "gcc compiling failed!"
	insinto ${my_prefix}/
	doexe give_me_my_mouse_back
	
	# xbmc-xrandr
	insinto ${my_prefix}/
	doexe xbmc-xrandr	

	# flash plugins
	dosym /opt/Adobe/flash-player/libflashplayer.so  ${my_prefix}/system/players/flashplayer/${_xulrunner}/bin/plugins/libflashplayer.so
		
	# freedesktop
	insinto /usr/share/applications
	doins debian/boxee.desktop
	insinto /usr/share/pixmaps
	doins debian/boxee.png

}
