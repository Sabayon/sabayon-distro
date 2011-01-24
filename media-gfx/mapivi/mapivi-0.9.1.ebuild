# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

MY_P="${PN}091"
DESCRIPTION="picture manager / organizer written in Perl/Tk"
HOMEPAGE="http://mapivi.sourceforge.net/mapivi.shtml"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tgz"

IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-lang/perl
	>=dev-perl/perl-tk-804.025
	dev-perl/ImageInfo
	media-gfx/jhead
	media-gfx/imagemagick
	media-libs/jpeg
	dev-perl/Image-MetaData-JPEG"
RDEPEND=${DEPEND}

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's:$configdir/PlugIns:/usr/share/mapivi/plugins:' mapivi || die
}

src_install() {
	dobin mapivi || die

	exeinto /usr/share/mapivi/plugins
	doexe PlugIns/{Channel-Separator,Join-RGB,checkDir-plugin,filelist-plugin,test-plugin} || die
	dodoc Changes.txt FAQ README Tips.txt ToDo || die
}

pkg_postinst() {
	ewarn "If your Gimp version is 2.3 from CVS you should run:"
	ewarn "sed -i 's:gimp-remote -n  :gimp-remote:g' /usr/bin/mapivi"
	ewarn "sed -i '22732,22734s:^.:\#:g' /usr/bin/mapivi"
	ewarn "sed -i '22735s:\#execute:execute:g' /usr/bin/mapivi"
	ewarn "after instalation to have edit in Gimp option work."
}
