# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=3

DESCRIPTION="Iottinka Artwork at DeviantArt"
HOMEPAGE="http://iottinka.deviantart.com"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="as-is"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
DEPEND="media-gfx/imagemagick"
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

	# GNOME
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

	# KDE
	dodir /usr/share/wallpapers
	for img in *.jpg; do
		short_name="Iottinka_${img%%_*}"
		img_dir="/usr/share/wallpapers/${short_name}"
		img_size="$(/usr/bin/identify -format '%wx%h' ${img})"
		[[ -z "${img_size}" ]] && die "cannot determine image size using imagemagick"
		images_dir="${img_dir}/contents/images"
		dodir "${images_dir}"
		dosym "${bg_dir}/${img}" "${images_dir}/${img_size}.jpg"
		echo "[Desktop Entry]" > metadata.desktop
		echo "Name=${short_name}" >> metadata.desktop
		echo "X-KDE-PluginInfo-Name=${short_name}" >> metadata.desktop
		echo "X-KDE-PluginInfo-Author=iottinka.deviantart.com" >> metadata.desktop
		echo "X-KDE-PluginInfo-Email=martina.moyola@gmail.com" >> metadata.desktop
		echo "X-KDE-PluginInfo-License=as-is" >> metadata.desktop
		insinto "${img_dir}"
		doins metadata.desktop
	done
}
