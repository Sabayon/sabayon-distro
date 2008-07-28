# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest
inherit autotools eutils

# Upstream sources use date instead version number
MY_PV="20080408"

DESCRIPTION="The themes for the cairo-dock panel"
HOMEPAGE="http://developer.berlios.de/projects/cairo-dock/"
SRC_URI="http://download2.berlios.de/cairo-dock/cairo-dock-sources-${MY_PV}.tar.bz2"

LICENSE="GPL"
SLOT="0"
KEYWORDS="amd64 ppc x86"

MYTHEMES="Azur Cobalt Djoole Glattering I_Cairo MacOSX TapisVert Ubuntu
Verde Wood"

IUSE="${MYTHEMES}"

DEPEND="gnome-extra/cairo-dock"

RDEPEND=${DEPEND}


S="${WORKDIR}/opt/cairo-dock/trunk/themes"

src_unpack() {
	unpack cairo-dock-sources-${MY_PV}.tar.bz2
	cd "${S}"
	einfo "Patching Makefile.am to comply with USE flags"
	echo -n "SUBDIRS = " >Makefile.am
	for thistheme in ${MYTHEMES}; do
		if use ${thistheme}; then
			echo -en "\\ \n\t_${thistheme}_" >>Makefile.am
#			sed s/_${thistheme}_\\// <Makefile.am >tmp.am
#			mv tmp.am Makefile.am
		fi
	done
	echo -en "\n" >>Makefile.am
	eautoreconf || die "eautoreconf failed"
	econf || die "econf failed"
}

src_compile() {
	cd "${S}"
	emake || die "emake failed"
}

src_install() {
	cd "${S}"
	emake DESTDIR="${D}" install || die "emake install failed"
}
