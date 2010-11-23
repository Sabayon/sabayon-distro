# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=3

inherit eutils

DESCRIPTION="XMind is the world's coolest brainstorming and mind mapping
software and the best way to share your ideas."
HOMEPAGE="www.xmind.net"
SRC_URI="http://dl.xmind.org/${P}.zip"

LICENSE="EPL-1.0 LGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=virtual/jre-1.5"
RDEPEND="${DEPEND}"

src_unpack() {
	unzip -d ${S} ${DISTDIR}/${P}.zip
}

src_configure() {
    case `arch` in
	"x86_64")	XDIR="XMind_Linux_64bit";;
	*) 	XDIR="XMind_Linux";;
    esac
    mv -v "$XDIR" xmind

    # force data instance area to be at home directory
    sed -i '/-Dosgi\.instance\.area=.*/d' xmind/xmind-bin.ini
}

src_compile() {
    einfo "Nothing to compile"
}

src_install() {
    dodir   /usr/lib/xmind

    insinto /usr/lib/xmind
    doins   -r Commons
    doins   -r xmind

    exeinto /usr/lib/xmind/xmind
    doexe   xmind/xmind
    doexe   xmind/xmind-bin
    dosym   /usr/lib/xmind/xmind/xmind /usr/bin/xmind


	local res
		for res in 16 32 48; do
		insinto /usr/share/icons/hicolor/${res}x${res}/apps
		newins "${FILESDIR}/xmind.${res}.png" xmind.png || die
	done

	make_desktop_entry xmind "XMind Manager" xmind "Office"
}
