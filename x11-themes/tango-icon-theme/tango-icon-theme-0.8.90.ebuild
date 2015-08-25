# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4
SLREV=4
inherit gnome2-utils

DESCRIPTION="SVG and PNG icon theme from the Tango project"
HOMEPAGE="http://tango.freedesktop.org"
SRC_URI="http://tango.freedesktop.org/releases/${P}.tar.gz
	branding? ( mirror://sabayon/x11-themes/fdo-icons-sabayon${SLREV}.tar.gz )"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="branding png"

RDEPEND=">=x11-themes/hicolor-icon-theme-0.12"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig
	>=gnome-base/librsvg-2.12.3
	|| ( media-gfx/imagemagick[png?] media-gfx/graphicsmagick[imagemagick,png?] )
	sys-devel/gettext
	>=x11-misc/icon-naming-utils-0.8.90"

RESTRICT="binchecks strip"

DOCS="AUTHORS ChangeLog README"

src_prepare() {
	sed -i -e '/svgconvert_prog/s:rsvg:&-convert:' configure || die #413183
}

src_configure() {
	econf \
		$(use_enable png png-creation) \
		$(use_enable png icon-framing)
}

src_install() {
	addwrite /root/.gnome2
	default

	if use branding; then
		# replace tango icon start-here.{png,svg} with Sabayon ones
		for dir in "${D}"/usr/share/icons/Tango/*/places; do
			base_dir=$(dirname "${dir}")
			icon_dir=$(basename "${base_dir}")
			sabayon_svg_file="${WORKDIR}"/fdo-icons-sabayon/scalable/places/start-here.svg
			if [ "${icon_dir}" = "scalable" ]; then
				cp "${sabayon_svg_file}" "${dir}/start-here.svg" || die
			else
				convert  -background none -resize \
					"${icon_dir}" "${sabayon_svg_file}" \
					"${dir}/start-here.png" || die
			fi
		done
	fi
}

pkg_preinst() {	gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
