# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/mythtv/mythtv-0.22_alpha20959.ebuild,v 1.1 2009/07/19 23:59:47 cardoe Exp $

EAPI=2
inherit flag-o-matic multilib eutils qt4 mythtv toolchain-funcs python

DESCRIPTION="Homebrew PVR project"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE_VIDEO_CARDS="video_cards_nvidia"
IUSE="alsa altivec autostart debug directv dvb dvd \
fftw ieee1394 jack lcd lirc mmx perl python \
tiff xvmc ${IUSE_VIDEO_CARDS}"

RDEPEND=">=media-libs/freetype-2.0
	>=media-sound/lame-3.93.1
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXinerama
	x11-libs/libXv
	x11-libs/libXrandr
	x11-libs/libXxf86vm
	x11-libs/qt-core:4[qt3support]
	x11-libs/qt-gui:4[qt3support,tiff?]
	x11-libs/qt-sql:4[qt3support,mysql]
	x11-libs/qt-opengl:4[qt3support]
	x11-libs/qt-webkit:4
	virtual/mysql
	virtual/opengl
	virtual/glu
	|| ( >=net-misc/wget-1.9.1 >=media-tv/xmltv-0.5.43 )
	alsa? ( >=media-libs/alsa-lib-0.9 )
	autostart? ( net-dialup/mingetty
				x11-wm/evilwm
				x11-apps/xset )
	directv? ( virtual/perl-Time-HiRes )
	dvb? ( media-libs/libdvb media-tv/linuxtv-dvb-headers )
	dvd? ( media-libs/libdvdcss )
	fftw? ( sci-libs/fftw:3.0 )
	ieee1394? (	>=sys-libs/libraw1394-1.2.0
			>=sys-libs/libavc1394-0.5.3
			>=media-libs/libiec61883-1.0.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	lcd? ( app-misc/lcdproc )
	lirc? ( app-misc/lirc )
	perl? ( dev-perl/DBD-mysql )
	python? ( dev-python/mysql-python )
	xvmc? ( x11-libs/libXvMC )"

DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	x11-proto/xf86vidmodeproto
	x11-apps/xinit"

MYTHTV_GROUPS="video,audio,tty,uucp"

pkg_setup() {
	einfo "This ebuild now uses a heavily stripped down version of your CFLAGS"

	if use xvmc && use video_cards_nvidia; then
		elog
		elog "For NVIDIA based cards, the XvMC renderer only works on"
		elog "the NVIDIA 4, 5, 6 & 7 series cards."
	fi

	enewuser mythtv -1 /bin/bash /home/mythtv ${MYTHTV_GROUPS}
	usermod -a -G ${MYTHTV_GROUPS} mythtv
}

src_prepare() {
	# upstream wants the revision number in their version.cpp
	# since the subversion.eclass strips out the .svn directory
	# svnversion in MythTV's build doesn't work
	sed -e "s:\`(svnversion 2>\/dev\/null) || echo Unknown\`:${MYTHTV_REV}:" \
		-i "${S}"/version.pro || die "svnversion sed failed"

	# Perl bits need to go into vender_perl and not site_perl
	sed -e "s:pure_install:pure_install INSTALLDIRS=vendor:" \
		-i "${S}"/bindings/perl/perl.pro

	epatch "${FILESDIR}/${PN}-0.21-ldconfig-sanxbox-fix.patch"
}

src_configure() {
	local myconf="--prefix=/usr
		--mandir=/usr/share/man
		--libdir-name=$(get_libdir)"
	use alsa || myconf="${myconf} --disable-audio-alsa"
	use altivec || myconf="${myconf} --disable-altivec"
	use fftw && myconf="${myconf} --enable-libfftw3"
	use jack || myconf="${myconf} --disable-audio-jack"

	#from bug #220857
	use xvmc && myconf="${myconf} --enable-xvmc --enable-xvmcw \
		--disable-xvmc-vld"

	# according to the Ubuntu guys, this works better being always on
	myconf="${myconf} --enable-glx-procaddrarb"

	myconf="${myconf}
		$(use_enable dvb)
		$(use_enable ieee1394 firewire)
		$(use_enable lirc)
		--disable-audio-arts
		--disable-directfb
		--dvb-path=/usr/include
		--enable-opengl-vsync
		--enable-xrandr
		--enable-xv
		--enable-x11"

	if use mmx || use amd64; then
		myconf="${myconf} --enable-mmx"
	else
		myconf="${myconf} --disable-mmx"
	fi

	if use perl && use python; then
		myconf="${myconf} --with-bindings=perl,python"
	elif use perl; then
		myconf="${myconf} --with-bindings=perl"
	elif use python; then
		myconf="${myconf} --with-bindings=python"
	else
		myconf="${myconf} --without-bindings=perl,python"
	fi

	if use debug; then
		myconf="${myconf} --compile-type=debug"
	else
		myconf="${myconf} --compile-type=profile"
	fi

	## CFLAG cleaning so it compiles
	MARCH=$(get-flag "march")
	MTUNE=$(get-flag "mtune")
	strip-flags
	filter-flags "-march=*" "-mtune=*" "-mcpu=*"
	filter-flags "-O" "-O?"

	if [[ -n "${MARCH}" ]]; then
		myconf="${myconf} --cpu=${MARCH}"
	fi
	if [[ -n "${MTUNE}" ]]; then
		myconf="${myconf} --tune=${MTUNE}"
	fi

#	myconf="${myconf} --extra-cxxflags=\"${CXXFLAGS}\" --extra-cflags=\"${CFLAGS}\""
	hasq distcc ${FEATURES} || myconf="${myconf} --disable-distcc"
	hasq ccache ${FEATURES} || myconf="${myconf} --disable-ccache"

	# let MythTV come up with our CFLAGS. Upstream will support this
	CFLAGS=""
	use x86 && CFLAGS="${CFLAGS} -fomit-frame-pointer"
	CXXFLAGS=""
	einfo "Running ./configure ${myconf}"
	chmod +x configure
	./configure ${myconf} || die "configure died"
}

src_compile() {
	eqmake4 mythtv.pro -o "Makefile" || die "eqmake4 failed"
	emake || die "emake failed"

	# firewire support should build the tester
	if use ieee1394; then
		cd contrib
		$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -o ../firewire_tester \
			development/firewire_tester/firewire_tester.c \
			${LDFLAGS} -liec61883 -lraw1394 || \
			die "failed to compile firewire_tester"

		cd channel_changers
		$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -std=gnu99 -o ../../6200ch \
			6200ch/6200ch.c \
			${LDFLAGS} -lrom1394 -lavc1394 -lraw1394 || \
			die "failed to compile 6200ch"
		$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -o ../../sa3250ch \
			sa3250ch/sa3250ch.c \
			${LDFLAGS} -lrom1394 -lavc1394 -lraw1394 || \
			die "failed to compile sa3250ch"
	fi

	cd "${S}"/contrib/channel_changers
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -o ../../red_eye red_eye/red_eye.c \
		${LDFLAGS} || die "failed to compile red_eye"
}

src_install() {

	einstall INSTALL_ROOT="${D}" || die "install failed"
	dodoc AUTHORS FAQ UPGRADING  README

	insinto /usr/share/mythtv/database
	doins database/*

	exeinto /usr/share/mythtv
	doexe "${FILESDIR}/mythfilldatabase.cron"

	newinitd "${FILESDIR}"/mythbackend-0.18.2.rc mythbackend
	newconfd "${FILESDIR}"/mythbackend-0.18.2.conf mythbackend

	dodoc keys.txt docs/*.{txt,pdf}
	dohtml docs/*.html

	keepdir /etc/mythtv
	chown -R mythtv "${D}"/etc/mythtv
	keepdir /var/log/mythtv
	chown -R mythtv "${D}"/var/log/mythtv

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/mythtv.logrotate.d mythtv

	insinto /usr/share/mythtv/contrib
	doins -r contrib/*

	dobin "${FILESDIR}"/runmythfe

	if use autostart; then
		dodir /etc/env.d/
		echo 'CONFIG_PROTECT="/home/mythtv/"' > "${D}"/etc/env.d/95mythtv

		insinto /home/mythtv
		newins "${FILESDIR}"/bash_profile .bash_profile
		newins "${FILESDIR}"/xinitrc .xinitrc
	fi

	if use ieee1394; then
		dobin firewire_tester || die "failed to install firewire_tester"
		newdoc contrib/development/firewire_tester/README README.firewire_tester

		dobin 6200ch || die "failed to install 6200ch"
		newdoc contrib/channel_changers/6200ch/README README.6200ch

		dobin sa3250ch || die "failed to install sa3250ch"
		newdoc contrib/channel_changers/sa3250ch/README README.sa3250ch
	fi

	dobin red_eye || die "failed to install red_eye"
	newdoc contrib/channel_changers/red_eye/README README.red_eye

	if use directv; then
		dobin contrib/channel_changers/d10control.pl || die "failed to install d10control"
		newdoc contrib/channel_changers/d10control/README README.d10control
	fi
}

pkg_preinst() {
	export CONFIG_PROTECT="${CONFIG_PROTECT} ${ROOT}/home/mythtv/"
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/MythTV

	elog "Want mythfrontend to start automatically?"
	elog "Set USE=autostart. Details can be found at:"
	elog "http://dev.gentoo.org/~cardoe/mythtv/autostart.html"

	elog
	elog "To always have MythBackend running and available run the following:"
	elog "rc-update add mythbackend default"
	elog
	ewarn "Your recordings folder must be owned by the user 'mythtv' now"
	ewarn "chown -R mythtv /path/to/store"

	if use xvmc && [[ ! -s "${ROOT}/etc/X11/XvMCConfig" ]]; then
		ewarn
		ewarn "No XvMC implementation has been selected yet"
		ewarn "Use 'eselect xvmc list' for a list of available choices"
		ewarn "Then use 'eselect xvmc set <choice>' to choose"
		ewarn "'eselect xvmc set nvidia' for example"
	fi

	if use autostart; then
		elog
		elog "Please add the following to your /etc/inittab file at the end of"
		elog "the TERMINALS section"
		elog "c8:2345:respawn:/sbin/mingetty --autologin mythtv tty8"
	fi

}

pkg_postrm()
{
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/MythTV
}

pkg_info() {
	"${ROOT}"/usr/bin/mythfrontend --version
}

pkg_config() {
	echo "Creating mythtv MySQL user and mythconverg database if it does not"
	echo "already exist. You will be prompted for your MySQL root password."
	"${ROOT}"/usr/bin/mysql -u root -p < "${ROOT}"/usr/share/mythtv/database/mc.sql
}
