# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit eutils flag-o-matic wxwidgets-2.8

MY_P=${P/m/M}
S=${WORKDIR}/amule-cvs

DESCRIPTION="aMule, the all-platform eMule p2p client"
HOMEPAGE="http://www.amule.org/"
SRC_URI="http://www.sabayonlinux.org/distfiles/net-p2p/aMule-CVS-20061208.tar.bz2"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="amuled debug gtk nls remote stats unicode"

DEPEND=">=x11-libs/wxGTK-2.7.2
		>=sys-libs/zlib-1.2.1
		stats? ( >=media-libs/gd-2.0.26 )
		remote? ( >=media-libs/libpng-1.2.0 )
		!net-p2p/xmule"

pkg_setup() {
		export WX_GTK_VER="2.8"

		if ! use gtk && ! use remote && ! use amuled; then
				eerror ""
				eerror "You have to specify at least one of gtk, remote or amuled"
				eerror "USE flag to build amule."
				eerror ""
				die "Invalid USE flag set"
		fi

		if use unicode && use gtk; then
				einfo "wxGTK with gtk2 and unicode support will be used"
				need-wxwidgets unicode
		elif use gtk; then
				einfo "wxGTK with gtk2 support will be used"
				need-wxwidgets gtk2
		elif use unicode; then
				einfo "wxGTK with unicode and without X support will be used"
				need-wxwidgets base-unicode
		else
				einfo "wxGTK without X support will be used"
				need-wxwidgets base
		fi

		if use stats && ! use gtk; then
				einfo "Note: You would need both the gtk and stats USE flags"
				einfo "to compile aMule Statistics GUI."
				einfo "I will now compile console versions only."
		fi

		if use stats && ! built_with_use media-libs/gd jpeg; then
				die "media-libs/gd should be compiled with the jpeg use flag when you have the stats use flag set"
		fi
}

pkg_preinst() {
	if use amuled || use remote; then
		enewgroup p2p
		enewuser p2p -1 -1 /home/p2p p2p
	fi
}

src_compile() {
		local myconf=""

		cd ${S}

		if use gtk ; then
				use stats && myconf="${myconf}
					--enable-wxcas
					--enable-alc"
				use remote && myconf="${myconf}
					--enable-amule-gui"
		else
				myconf="
					--disable-monolithic
					--disable-amule-gui
					--disable-wxcas
					--disable-alc"
		fi

		econf \
				--with-wx-config=${WX_CONFIG} \
				--with-wxbase-config=${WX_CONFIG} \
				--enable-amulecmd \
				`use_enable debug` \
				`use_enable !debug optimize` \
				`use_enable amuled amule-daemon` \
				`use_enable nls` \
				`use_enable remote webserver` \
				`use_enable stats cas` \
				`use_enable stats alcc` \
				${myconf} || die

		# we filter ssp until bug #74457 is closed to build on hardened
		if has_hardened; then
				filter-flags -fstack-protector -fstack-protector-all
		fi
		emake -j1 || die
}

src_install() {
		make DESTDIR=${D} install || die

		if use amuled; then
				insinto /etc/conf.d; newins ${FILESDIR}/amuled.confd amuled
				exeinto /etc/init.d; newexe ${FILESDIR}/amuled.initd amuled
		fi

		if use remote; then
				insinto /etc/conf.d; newins ${FILESDIR}/amuleweb.confd amuleweb
				exeinto /etc/init.d; newexe ${FILESDIR}/amuleweb.initd amuleweb
		fi
}
