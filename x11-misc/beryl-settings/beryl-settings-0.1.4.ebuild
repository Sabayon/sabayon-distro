# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/beryl-settings/beryl-settings-0.1.2.ebuild,v 1.1 2006/11/15 04:00:20 tsunam Exp $

DESCRIPTION="Beryl Window Decorator Settings"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
LANGS="ca_ES de_DE es_AR es_ES fr_FR hu_HU it_IT ja_JP ko_KR ru_RU pl_PL
pt_BR pt_PT sv_FI sv_SE uk_UA zh_CN zh_HK zh_TW"

DEPEND=">=x11-libs/gtk+-2.8.0
	~x11-wm/beryl-core-${PV}"

src_compile() {
	econf || die "econf failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	ebeep
	einfo
	einfo "If you cannot see the beryl splash sreen or snow"
	einfo "Please re-enabled png and svg support in beryl-settings"
	einfo "Then reload beryl and it will show up"
	einfo
}
