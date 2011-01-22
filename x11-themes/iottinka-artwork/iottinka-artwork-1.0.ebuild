# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=3

DESCRIPTION="Iottinka Artwork at DeviantArt"
HOMEPAGE="http://iottinka.deviantart.com"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="as-is"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
DEPEND=""
RDEPEND=""
S="${WORKDIR}/${PN}"

src_install() {
	local bg_dir="/usr/share/backgrounds/iottinka"
	dodir "${bg_dir}"
	local gnome_bg_dir="/usr/share/gnome-background-properties"
	dodir "${gnome_bg_dir}"

	cd "${S}"

	insinto "${bg_dir}"
	doins -r *.jpg

	local xml_bg="iottinka.xml"
	echo '<?xml version="1.0" encoding="UTF-8"?>' > ${xml_bg}
	echo '<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">' >> ${xml_bg}
	echo '<wallpapers>' >> ${xml_bg}
	for img in *.jpg; do
		echo '  <wallpaper deleted="false">' >> ${xml_bg}
		echo "  <name>iottinka.deviantart.com</name>" >> ${xml_bg}
		echo "  <filename>${bg_dir}/${img}</filename>" >> ${xml_bg}
		echo "  <options>zoom</options>" >> ${xml_bg}
		echo "  </wallpaper>" >> ${xml_bg}
	done
	echo "</wallpapers>" >> "${xml_bg}"

	insinto "${gnome_bg_dir}"
	doins "${xml_bg}"
}
