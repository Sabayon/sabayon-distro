# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=3
inherit eutils kde4-base 

DESCRIPTION="Sabayon Linux Official KDE artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-4.1.99-r1.tar.lzma"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="x11-themes/sabayon-artwork-core
	!<=x11-themes/sabayonlinux-artwork-4
	x11-themes/qtcurve-qt4
	x11-themes/gtk-engines-qtcurve"

S="${WORKDIR}/${PN}"

src_prepare() {
	cd ${S}/kdm4/Glassified
	epatch ${FILESDIR}/4.1.99-r2/fixbackgroundlocation.patch
}

src_configure() {
	einfo "nothing to configure"
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	# KDE 3.5
	# KDM theme
	cd ${S}/kdm3.5
	mv Sabayon-4.0 Sabayon
	mv Sabayon-4.0-wide Sabayon-wide
	insinto /usr/kde/3.5/share/apps/kdm/themes/
	doins -r ./

        # ksplash
	cd ${S}/ksplash3.5/Lines
	dodir /usr/kde/3.5/share/apps/ksplash/Themes/Lines
	insinto /usr/kde/3.5/share/apps/ksplash/Themes/Lines
	doins -r ./

        # theme
	dodir /usr/share/apps/kthememanager/themes
	insinto /usr/share/apps/kthememanager/themes
	cd ${S}/kde3.5
	mkdir Sabayon4
	tar xf Sabayon4.kth -C Sabayon4
	rm *.kth
	doins -r ./

	#KDE 4
	# KDM
	dodir ${KDEDIR}/share/apps/kdm/themes
	cd ${S}/kdm4
	insinto ${KDEDIR}/share/apps/kdm/themes
	doins -r ./

	# KSplash
	dodir ${KDEDIR}/share/apps/ksplash/Themes
	cd ${S}/ksplash4
	insinto ${KDEDIR}/share/apps/ksplash/Themes
	doins -r ./
	rm ${D}/usr/kde/4.2/share/apps/ksplash/Themes/Sabayon/Theme.rc~ -f
}
