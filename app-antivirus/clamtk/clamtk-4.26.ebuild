# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils perl-module

DESCRIPTION="A frontend for ClamAV using Gtk2-perl"
HOMEPAGE="http://clamtk.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="Artistic GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

LANGS="ar bg cs da de el en_GB es fr gl he hr hu it ja ko ms nb nl nn pl pt_BR ro ru sk sl sv th tr zh_CN"
IUSE="nls"
for i in ${LANGS}; do
	IUSE="${IUSE} linguas_${i}"
done

DEPEND=""
RDEPEND=">=dev-perl/gtk2-perl-1.140
	dev-perl/File-Find-Rule
	dev-perl/libwww-perl
	dev-perl/Net-DNS
	dev-perl/Date-Calc
	dev-util/desktop-file-utils
	>=app-antivirus/clamav-0.90
	nls? ( dev-perl/Locale-gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	perlinfo
	sed -i -e "s:'/usr/lib':'${VENDOR_LIB}':"  clamtk \
		|| die "sed failed"
	gunzip ${PN}.1.gz || die "gunzip failed"
}

src_install() {
	dobin ${PN} || die "dobin failed"

	doicon ${PN}.png || die "doicon failed"
	domenu ${PN}.desktop || die "domenu failed"

	dodoc CHANGES README || die "dodoc failed"
	doman ${PN}.1 || die "doman failed"

	# The custom Perl modules
	perlinfo
	insinto ${VENDOR_LIB}/ClamTk
	doins lib/*.pm || die "doins failed"

	if use nls ; then
		domo po/*.mo || die "domo failed"
	fi
}
