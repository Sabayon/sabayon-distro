# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit cmake-utils mercurial

DESCRIPTION="THe Experimental RAw Photo Editor"
HOMEPAGE="http://www.rawtherapee.com/"
SRC_URI=""
EHG_REPO_URI="https://rawtherapee.googlecode.com/hg/"
EHG_REVISION="f094b6694823"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
#LANGS="cs da de en_US en_GB el es eu fr he hu it ja lv nl nn pl ru sk fi sv tr zh_CN zh_TW"
#for lng in ${LANGS}; do
#	IUSE="${IUSE} linguas_${lng}"
#done

RDEPEND=">=dev-cpp/gtkmm-2.12:2.4
	virtual/jpeg
	media-libs/tiff
	media-libs/libpng
	media-libs/libiptcdata
	media-libs/lcms
	>=dev-cpp/glibmm-2.16:2
	dev-libs/libsigc++:2
	media-libs/libiptcdata"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

# S=${WORKDIR}/hg

src_install() {
	cmake-utils_src_install
	rm "${ED}"usr/bin/rtstart
	dodoc "${ED}"usr/share/doc/{AUTHORS,AboutThisBuild}.txt || \
		die "dodoc failed"
	rm -f "${ED}"usr/share/doc/*.txt
	insinto /usr/share/pixmaps
	doins "${FILESDIR}"/rawtherapee.png || die "can't copy png file"
	insinto /usr/share/applications
	doins "${FILESDIR}"/rawtherapee3.desktop || die "can't copy desktop file"
}
