# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/bluefish/bluefish-2.0.1.ebuild,v 1.2 2010/07/15 20:22:16 billie Exp $

EAPI=2

PYTHON_DEPEND="python? 2"

inherit autotools eutils fdo-mime python

MY_P=${P/_/-}

DESCRIPTION="A GTK HTML editor for the experienced web designer or programmer."
SRC_URI="http://www.bennewitz.com/bluefish/stable/source/${MY_P}.tar.bz2"
HOMEPAGE="http://bluefish.openoffice.nl/"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
SLOT="0"
IUSE="gucharmap nls python spell"

RDEPEND="
	x11-libs/gtk+:2
	spell? ( app-text/enchant[aspell] )"

DEPEND="${RDEPEND}
	dev-libs/glib:2
	dev-libs/libxml2
	dev-util/pkgconfig
	x11-libs/pango
	gucharmap? ( gnome-extra/gucharmap )
	nls? ( sys-devel/gettext dev-util/intltool )"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	if use python ; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_prepare () {
	# Needs Makefile.in.in from system gettext (bug #321721)
	if use nls ; then
		intltoolize --copy --force || die
		for po_dir in "${S}"/src/plugin_{about,charmap,entities,htmlbar,infbrowser,snippets}/po ; do
			cp /usr/share/gettext/po/Makefile.in.in ${po_dir} || die
		done
	fi

	# Fixes automagic installation of charmap plugin
	# Upstream bug: https://bugzilla.gnome.org/show_bug.cgi?id=570990
	epatch "${FILESDIR}"/${PN}-2.0.0-gucharmap-automagic.patch
	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-update-databases \
		--disable-xml-catalog-update \
		$(use_enable nls) \
		$(use_enable spell spell-check) \
		$(use_enable gucharmap charmap) \
		$(use_enable python)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	einfo "Adding XML catalog entries..."
	/usr/bin/xmlcatalog  --noout \
		--add 'public' 'Bluefish/DTD/Bflang' 'bflang.dtd' \
		--add 'system' 'http://bluefish.openoffice.nl/DTD/bflang.dtd' 'bflang.dtd' \
		--add 'rewriteURI' 'http://bluefish.openoffice.nl/DTD' '/usr/share/xml/bluefish-unstable' \
		/etc/xml/catalog \
		|| ewarn "Failed to add XML catalog entries."
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	einfo "Removing XML catalog entries..."
	/usr/bin/xmlcatalog  --noout \
		--del 'Bluefish/DTD/Bflang' \
		--del 'http://bluefish.openoffice.nl/DTD/bflang.dtd' \
		--del 'http://bluefish.openoffice.nl/DTD' \
		/etc/xml/catalog \
		|| ewarn "Failed to remove XML catalog entries."
}
