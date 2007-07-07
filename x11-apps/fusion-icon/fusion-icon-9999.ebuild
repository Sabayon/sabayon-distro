# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git gnome2-utils

EGIT_REPO_URI="git://anongit.opencompositing.org/users/crdlb/${PN}"

DESCRIPTION="Compiz Fusion Tray Icon and Manager (git)"
HOMEPAGE="http://opencompositing.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="gtk qt4"
# Removed qt, frontend is broken

RDEPEND="~x11-wm/compiz-${PV}
	~dev-python/compizconfig-python-${PV}
	gtk? ( >=dev-python/pygtk-2.10 )
	qt4? ( dev-python/PyQt4 )"
#	qt3? ( dev-python/PyQt
#		dev-python/ctypes )

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19"

src_install() {
	if use gtk ; then frontends="${frontends} gtk" ; fi

	# Remove qt3, frontend is broken
	#if use qt3 ; then frontends="${frontends} qt3" ; fiS="${WORKDIR}/${PN}"
	if use qt4 ; then frontends="${frontends} qt4" ; fi
	make "frontends=${frontends}" DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	if use gtk ; then gnome2_icon_cache_update ; fi

	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Please report all bugs to http://forums.gentoo-xeffects.org"
	einfo "Thank you on behalf of the Gentoo Xeffects team"
}
