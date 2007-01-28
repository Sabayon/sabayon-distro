# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kcontrol/kcontrol-3.5.5.ebuild,v 1.10 2006/12/11 11:16:58 kloeri Exp $

KMNAME=kdebase
MAXKDEVER=$PV
KM_DEPRANGE="$PV $MAXKDEVER"
inherit kde-meta eutils

SRC_URI="${SRC_URI}
	mirror://gentoo/kdebase-3.5-patchset-02.tar.bz2"

DESCRIPTION="The KDE Control Center"
KEYWORDS="alpha amd64 ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="ssl arts ieee1394 logitech-mouse opengl kdehiddenvisibility"

DEPEND=">=media-libs/freetype-2
	media-libs/fontconfig
	ssl? ( dev-libs/openssl )
	arts? ( $(deprange $PV $MAXKDEVER kde-base/arts) )
	opengl? ( virtual/opengl )
	ieee1394? ( sys-libs/libraw1394 )
	logitech-mouse? ( >=dev-libs/libusb-0.1.10a )"

RDEPEND="${DEPEND}
	sys-apps/usbutils
$(deprange 3.5.3 $MAXKDEVER kde-base/kcminit)
$(deprange $PV $MAXKDEVER kde-base/kdebase-data)
$(deprange $PV $MAXKDEVER kde-base/kdesu)
$(deprange $PV $MAXKDEVER kde-base/khelpcenter)
$(deprange $PV $MAXKDEVER kde-base/khotkeys)
$(deprange $PV $MAXKDEVER kde-base/libkonq)
$(deprange $PV $MAXKDEVER kde-base/kicker)"

KMEXTRACTONLY="kwin/kwinbindings.cpp
		kicker/kicker/core/kickerbindings.cpp
		kicker/taskbar/taskbarbindings.cpp
		kdesktop/kdesktopbindings.cpp
		klipper/klipperbindings.cpp
		kxkb/kxkbbindings.cpp
		kicker/taskmanager"

KMEXTRA="doc/kinfocenter"
KMCOMPILEONLY="kicker/libkicker
	kicker/taskbar"
KMCOPYLIB="libkonq libkonq
	libkicker kicker/libkicker
	libtaskbar kicker/taskbar
	libtaskmanager kicker/taskmanager"

src_unpack() {
	kde-meta_src_unpack
	cd ${S}/kcontrol/
	epatch ${FILESDIR}/${P}-kickoff-integration.patch

}

src_compile() {
	myconf="$myconf `use_with ssl` `use_with arts` `use_with opengl gl`
			`use_with ieee1394 libraw1394` `use_with logitech-mouse libusb`
			--with-usbids=/usr/share/misc/usb.ids"
	kde-meta_src_compile
}

