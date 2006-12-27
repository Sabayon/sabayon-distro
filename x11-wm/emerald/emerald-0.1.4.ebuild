# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/emerald/emerald-0.1.2.ebuild,v 1.1 2006/11/15 04:05:42 tsunam Exp $

inherit gnome2 

DESCRIPTION="Beryl Window Decorator"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
LANGS="ca_ES de_DE es_AR es_ES fr_FR hu_HU it_IT ja_JP ko_KR ru_RU pl_PL 
pt_BR pt_PT sv_FI sv_SE uk_UA zh_CN zh_HK zh_TW"

PDEPEND="~x11-themes/emerald-themes-${PV}"

DEPEND=">=x11-libs/gtk+-2.8.0
	>=x11-libs/libwnck-2.14.2
	~x11-wm/beryl-core-${PV}"

src_unpack () {
	unpack ${A}
	cd ${S}/po
	einfo
	einfo "Symlinking en_GB to en and en_US for SL users"
	einfo "This is due to make fail if not done"
	einfo "Email cvill64@sabayonlinux.org if know a better fix"
	einfo
	ln -s en_GB.po en_US.po
	ln -s en_GB.po en.po
}

src_compile() {
	cd ${S}
	gnome2_src_compile --disable-mime-update
}
