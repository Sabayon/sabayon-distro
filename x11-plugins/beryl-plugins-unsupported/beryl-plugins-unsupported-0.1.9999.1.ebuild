# Copyright 2004-2007 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $
inherit autotools eutils

DESCRIPTION="Beryl Window Decorator Plugins"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://sabayonlinux.org/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="~x11-plugins/beryl-plugins-${PV}"

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
#	filter-ldflags -znow -z,now -Wl,-znow -Wl,-z,now
	#--with-lang="${LINGUAS_BERYL}"
	econf || die "econf failed"
	emake -j1 || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
