# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils

DESCRIPTION="XSane plugin for GIMP"
HOMEPAGE="http://www.xsane.org/"
MY_P="${P/-gimp}"
SRC_URI="http://www.xsane.org/download/${MY_P}.tar.gz
	http://dev.gentoo.org/~dilfridge/distfiles/xsane-0.998-patches-2.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

RDEPEND="media-gfx/sane-backends
	~media-gfx/xsane-${PV}[-gimp]
	media-gfx/gimp"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# Apply multiple fixes from different distributions
	# Drop included patch and reuse patchset from prior version
	rm "${WORKDIR}/xsane-0.998-patches-2"/005-update-param-crash.patch || die
	epatch "${WORKDIR}/xsane-0.998-patches-2"/*.patch

	# Fix compability with libpng15 wrt #377363
	sed -i -e 's:png_ptr->jmpbuf:png_jmpbuf(png_ptr):' src/xsane-save.c || die

	# Fix AR calling directly (bug #442606)
	sed -i -e 's:ar r:$(AR) r:' lib/Makefile.in || die
	tc-export AR
}

src_configure() {
	econf --enable-gtk2 \
		$(use_enable nls) \
		--disable-jpeg \
		--disable-png \
		--disable-tiff \
		--enable-gimp \
		--disable-lcms
}

src_install() {
	# link xsane so it is seen as a plugin in gimp
	local plugindir
	if [ -x "${EPREFIX}"/usr/bin/gimptool ]; then
		plugindir="$(gimptool --gimpplugindir)/plug-ins"
	elif [ -x "${EPREFIX}"/usr/bin/gimptool-2.0 ]; then
		plugindir="$(gimptool-2.0 --gimpplugindir)/plug-ins"
	else
		die "Can't find GIMP plugin directory."
	fi
	dodir "${plugindir#${EPREFIX}}"
	newbin src/xsane xsane-gimp
	dosym /usr/bin/xsane-gimp "${plugindir#${EPREFIX}}"/xsane
}
