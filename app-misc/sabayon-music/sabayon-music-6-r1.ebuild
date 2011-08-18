# Copyright 2004-2008 Sabayon Linux (Fabio Erculiani)
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Sabayon Boot Music"
HOMEPAGE="http://www.sabayon.org"
BOOT_MUSIC_OGG_FILE="titan.ogg"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${BOOT_MUSIC_OGG_FILE}"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="media-sound/vorbis-tools"


src_unpack() {
	cp "${DISTDIR}/${BOOT_MUSIC_OGG_FILE}" "${WORKDIR}/boot.ogg" || die
	cp "${FILESDIR}/music" "${WORKDIR}/" || die
}

src_install () {

	cd "${WORKDIR}" || die
	dodir /usr/share/sounds
	insinto /usr/share/sounds
	doins boot.ogg
	newinitd music music

}

pkg_postinst() {

	einfo "Song by: Epic Soul Factory"
	einfo "Album: Volume One"
	einfo "Title: TITAN"
	einfo "Visit: http://www.jamendo.com/it/artist/Epic_Soul_Factory"

}
