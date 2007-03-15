# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header:  Exp $

inherit autotools flag-o-matic eutils 

IUSE=""
LANGS="ar_AR ca_ES de_DE es_AR es_ES fr_FR gl_ES gl_GL hu_HU it_IT ja_JP ko_KR my_MY nb_NO nl_BE nl_NL it_IT pl_PL pt_BR pt_PT ru_RU sk_SK sv_FI sv_SE tr_TR uk_UA zh_CN zh_HK zh_TW"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

DESCRIPTION="Beryl Window Decorator Manager"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"
RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"

DEPEND=">=x11-libs/gtk+-2.8.0"

RDEPEND="${DEPEND}
	x11-apps/xlsclients
	x11-apps/xvinfo"

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
	# --with-lang="${LINGUAS_BERYL}"
	econf  || die "econf failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
