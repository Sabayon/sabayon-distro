# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils python fdo-mime versionator

DESCRIPTION="GUI utility for making software releases on SourceForge"
HOMEPAGE="http://www.subdownloader.net/"
SRC_URI="http://launchpad.net/subdownloader/trunk/$(get_version_component_range 1-3)/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/PyQt4
	|| ( dev-python/kaa-metadata dev-python/mmpython )"

S="${WORKDIR}/${PN}-${PV}"

src_unpack() {
	unpack ${A}
}

src_install() {
	insinto /usr/$(get_libdir)/subdownloader
	doins -r cli FileManagement gui languages modules run.py || die "doins failed"
	fperms 755 /usr/$(get_libdir)/subdownloader/run.py
	dosym /usr/$(get_libdir)/subdownloader/run.py /usr/bin/subdownloader
	doman subdownloader.1 || die "doman failed"
	dodoc README ChangeLog || die "dodoc failed"
	doicon gui/images/subdownloader.png || die "doicon failed"
	domenu subdownloader.desktop || die "domenu failed"
}

pkg_postinst() {
	python_mod_optimize /usr/$(get_libdir)/subdownloader
	fdo-mime_desktop_database_update
        fdo-mime_mime_database_update
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/subdownloader
	fdo-mime_desktop_database_update
        fdo-mime_mime_database_update
}
