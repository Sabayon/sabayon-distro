# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils multilib
EAPI=1

MY_PN="spicebird"
MY_P="${MY_PN}-beta-${PV}"

DESCRIPTION="Spicebird Collaboration Suite"
SRC_URI="amd64? ( http://files.spicebird.org/pub/spicebird.org/${MY_PN}/releases/${PV}/linux-x86_64/en-US/${MY_P}.en-US.linux-x86_64.tar.bz2 )
		 x86? ( http://files.spicebird.org/pub/spicebird.org/${MY_PN}/releases/${PV}/linux-i686/en-US/${MY_P}.en-US.linux-i686.tar.bz2 )
		 "
HOMEPAGE="http://www.spicebird.com/"
RESTRICT="nomirror"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE=""
S="${WORKDIR}/spicebird-beta"


RDEPEND="x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXmu
		>=x11-libs/gtk+-2.2
		=virtual/libstdc++-3.3
		media-libs/libart_lgpl
		gnome-base/libbonoboui
		gnome-base/orbit:2
		gnome-base/libgnomeui
		gnome-base/gnome-keyring
	"
#	amd64? (
#		>=app-emulation/emul-linux-x86-baselibs-1.0
#		>=app-emulation/emul-linux-x86-gtklibs-1.0
#		app-emulation/emul-linux-x86-compat
#	)

#pkg_setup() {
#	has_multilib_profile && ABI="x86"
#}

src_install() {
	dodir /opt/spicebird
	cp ${S}/* ${D}/opt/spicebird -Ra || die "copy failed"
	dosym /opt/spicebird/spicebird /usr/bin/spicebird

	# copy icons
	dodir /usr/share/pixmaps
	insinto /usr/share/pixmaps
	doins ${S}/icons/*

	# create desktop entry
	make_desktop_entry spicebird "Spicebird Collaboration Suite" "/usr/share/pixmaps/mozicon50.xpm"

}

pkg_postinst() {
	elog "This is a beta release !!"
}

