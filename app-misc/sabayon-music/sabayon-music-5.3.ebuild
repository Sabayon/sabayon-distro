# Copyright 2004-2008 Sabayon Linux (Fabio Erculiani)
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Sabayon Linux Boot Music Infrastructure (BMI)"
HOMEPAGE="http://www.sabayon.org"
BOOT_MUSIC_OGG_FILE="08_-_rock'n'roll_hall_of_fame.ogg"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${BOOT_MUSIC_OGG_FILE}"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="media-sound/vorbis-tools"


src_unpack() {
	cp "${DISTDIR}/${BOOT_MUSIC_OGG_FILE}" "${WORKDIR}/boot.ogg"
	cp "${FILESDIR}/music" "${WORKDIR}/"
}

src_install () {

	cd ${WORKDIR}
	dodir /usr/share/sounds
	insinto /usr/share/sounds
	doins boot.ogg
	newinitd music music

}

pkg_postinst() {

	einfo "Song by: Pornophonique"
	einfo "Album: 8-bit lagerfeuer"
	einfo "Title: Rock 'n Roll Hall of Fame"
	einfo "Visit: http://www.jamendo.com/en/album/7505"

}
