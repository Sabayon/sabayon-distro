# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit autotools flag-o-matic eutils 

IUSE=""
LANGS="ca_ES de_DE en_GB es_AR es_ES fr_FR hu_HU it_IT ja_JP ko_KR ru_RU pl_PL pt_BR pt_PT sv_FI sv_SE uk_UA zh_CN zh_HK zh_TW"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

DESCRIPTION="Beryl Window Decorator Settings"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND=">=x11-libs/gtk+-2.8.0
	~x11-wm/beryl-core-${PV}"

pkg_setup() {
	strip-linguas ${LANGS}

	if [ -z "${LINGUAS}" ]; then
		export LINGUAS_BERYL="en_GB"
		ewarn
		ewarn " To get a localized build, set the according LINGUAS variable(s). "
		ewarn
	else
		export LINGUAS_BERYL=`echo ${LINGUAS}`
	fi
}

src_compile() {
	econf --with-lang="${LINGUAS_BERYL}" || die "econf failed"
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
