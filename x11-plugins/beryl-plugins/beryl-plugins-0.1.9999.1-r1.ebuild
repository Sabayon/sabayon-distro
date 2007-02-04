# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/beryl-plugins/beryl-plugins-0.1.2.ebuild,v 1.1 2006/11/15 04:03:06 tsunam Exp $

inherit flag-o-matic autotools eutils

#IUSE=""
#LANGS="ca_ES de_DE en_GB es_AR es_ES fr_FR hu_HU it_IT ja_JP ko_KR ru_RU pl_PL pt_BR pt_PT sv_FI sv_SE uk_UA zh_CN zh_HK zh_TW"
#
#for X in ${LANGS} ; do
#	IUSE="${IUSE} linguas_${X}"
#done

DESCRIPTION="Beryl Window Decorator Plugins"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://sabayonlinux.org/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="~x11-wm/beryl-core-${PV}
	>=gnome-base/librsvg-2.16.1"

#pkg_setup() {
#	strip-linguas ${LANGS}
#
#	if [ -z "${LINGUAS}" ]; then
#		export LINGUAS_BERYL="en_GB"
#		ewarn
#		ewarn " To get a localized build, set the according LINGUAS variable(s). "
#		ewarn
#	else
#		export LINGUAS_BERYL=`echo ${LINGUAS}`
#	fi
#}

src_compile() {
	# filter ldflags to follow upstream
	filter-ldflags -znow -z,now -Wl,-znow -Wl,-z,now
	#--with-lang="${LINGUAS_BERYL}"
	econf || die "econf failed"
	emake -j1 || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
