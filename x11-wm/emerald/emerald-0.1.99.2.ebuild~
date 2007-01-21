# Copyright 2004-2006 Sabayonlinux
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit gnome2 flag-o-matic eutils 

IUSE=""
LANGS="ca_ES de_DE en_GB es_AR es_ES fr_FR hu_HU it_IT ja_JP ko_KR ru_RU pl_PL pt_BR pt_PT sv_FI sv_SE uk_UA zh_CN zh_HK zh_TW"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

DESCRIPTION="Beryl Window Decorator"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://sabayonlinux.org/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"


PDEPEND="~x11-themes/emerald-themes-${PV}"

DEPEND=">=x11-libs/gtk+-2.8.0
	>=x11-libs/libwnck-2.14.2
	~x11-wm/beryl-core-${PV}"

pkg_setup() {
	strip-linguas ${LANGS}

if [ -z "${LINGUAS}" ]; then
	export LINGUAS_EMERALD="en_GB"
		ewarn
		ewarn " To get a localized build, set the according LINGUAS variable(s). "
		ewarn
	else
		export LINGUAS_EMERALD=`echo ${LINGUAS}`
fi
}

src_compile() {
	append-flags -fno-inline

	gnome2_src_compile --disable-mime-update # --with-lang="${LINGUAS_EMERALD}"
}
