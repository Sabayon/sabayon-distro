# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils

DESCRIPTION="XSane plugin for GIMP"
HOMEPAGE="http://www.xsane.org/"
MY_P="${P/-gimp}"
SRC_URI="http://www.xsane.org/download/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-gfx/sane-backends
	=media-gfx/xsane-${PV}[-gimp]
	media-gfx/gimp"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_configure() {
	econf --enable-gtk2 \
		--disable-jpeg \
		--disable-png \
		--disable-tiff \
		--disable-lcms \
		--disable-sanetest \
		|| die
}

src_install() {
	# link xsane so it is seen as a plugin in gimp
	local plugindir
	if [ -x /usr/bin/gimptool ]; then
		plugindir="$(gimptool --gimpplugindir)/plug-ins"
	elif [ -x /usr/bin/gimptool-2.0 ]; then
		plugindir="$(gimptool-2.0 --gimpplugindir)/plug-ins"
	else
		die "Can't find GIMP plugin directory."
	fi
	newbin src/xsane xsane-gimp || die
	dodir "${plugindir}" || die
	dosym /usr/bin/xsane-gimp "${plugindir}"/xsane || die
}

pkg_postinst() {
	elog "If a new scanner is added or the device of the the scanner has"
	elog "changed, it is recommended to rebuild the cache:"
	elog "issue \"touch /usr/local/bin/xsane\" or delete the plugin cache"
	elog "(~/.gimp*/pluginrc)."
}
