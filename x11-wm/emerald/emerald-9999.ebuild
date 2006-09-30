# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils subversion flag-o-matic multilib gnome2 autotools

ESVN_PROJECT=${PN}
ESVN_REPO_URI="svn://metascape.afraid.org/svnroot/beryl/trunk/${ESVN_PROJECT}"
ESVN_MODULE=${ESVN_PROJECT}
ESVN_LOCALNAME=${ESVN_PROJECT}


S=${WORKDIR}

DESCRIPTION="Beryl window manager for AiGLX and XGL (subversion)"
HOMEPAGE="http://compiz.net"
SRC_URI=""
LICENSE="X11"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE="gnome svg"

PDEPEND="x11-wm/beryl-core"

DEPEND=">=media-libs/mesa-6.5.1_alpha20060515
	x11-libs/startup-notification
	media-libs/libpng
	media-libs/glew
	sys-apps/dbus
	x11-libs/aiglx-accelerator
	x11-libs/libXdamage
	x11-libs/libXrandr
	x11-libs/libXcomposite
	gnome? (
		>=gnome-base/gconf-2.14
		x11-libs/libwnck
		gnome-base/gnome-desktop
		gnome-base/control-center
	)
	>=gnome-base/librsvg-2"

RDEPEND="${DEPEND}
	x11-apps/xvinfo
        x11-apps/xlsclients"

src_unpack() {
	subversion_src_unpack
}

src_compile() {
	use amd64 && replace-flags -O[1-9] -O0

	cd ${S}

	./autogen.sh
	econf --disable-mime-update || die "econf failed"
	make
	# This dont work... fuck... disabled for now
	#emake || die "make failed"

}

src_install() {
	gnome2_src_install

}
