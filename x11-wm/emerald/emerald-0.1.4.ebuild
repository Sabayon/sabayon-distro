# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/emerald/emerald-0.1.2.ebuild,v 1.1 2006/11/15 04:05:42 tsunam Exp $

LANGS="ca_ES de_DE es_AR es_ES fr_FR hu_HU it_IT ja_JP ko_KR ru_RU pl_PL pt_BR pt_PT sv_FI sv_SE uk_UA zh_CN zh_HK zh_TW"

USE_KEG_PACKAGING=1

inherit gnome2 flag-o-matic eutils 

DESCRIPTION="Beryl Window Decorator"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

PDEPEND="~x11-themes/emerald-themes-${PV}"

DEPEND=">=x11-libs/gtk+-2.8.0
	>=x11-libs/libwnck-2.14.2
	~x11-wm/beryl-core-${PV}"

src_compile() {
	append-flags -fno-inline

	local myconf="
		--disable-mime-update
		"

	gnome2_src_compile
}
