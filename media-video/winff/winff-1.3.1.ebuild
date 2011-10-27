# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils

DESCRIPTION="GUI for the command line video converter ffmpeg"
HOMEPAGE="http://winff.org/"
SRC_URI="http://winff.googlecode.com/files/${P}-source.tar.gz
	http://winff.googlecode.com/files/presets-libavcodec52-v7.xml.gz"

LICENSE="GPL-3 doc? ( FDL-1.3 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

COMMON_DEPENDS="
	dev-libs/atk
	dev-libs/glib:2
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/pango
"
DEPEND="
	${COMMON_DEPENDS}
	dev-lang/lazarus
"
RDEPEND="
	${COMMON_DEPENDS}
	virtual/ffmpeg
	|| ( x11-terms/xterm x11-terms/gnome-terminal )
"

S="${WORKDIR}/${PN}"

src_compile() {
	lazbuild --widgetset=gtk2 -B winff.lpr || die
}

src_install() {
	dobin ${PN}
	dodoc README* changelog.txt
	doman ${PN}.1
	insinto /usr/share/${PN}
	newins "${WORKDIR}"/presets-libavcodec52-v7.xml presets.xml
	doins -r languages
	local res
	for res in 16x16 24x24 32x32 48x48; do
		insinto /usr/share/icons/hicolor/${res}/apps
		doins ${PN}-icons/${res}/${PN}.png
	done
	doicon ${PN}-icons/48x48/${PN}.png || die
	make_desktop_entry ${PN} WinFF ${PN} "AudioVideo;AudioVideoEditing;GTK;"
	if use doc; then
		dodoc docs/WinFF*
		# don't compress the odt files
		docompress -x /usr/share/doc/${PF}
	fi
}

# if a version with new presets comes, inform user that he would
# need to remove ~/.winff/presets.xml to use them
# (and that will remove any custom presets)
