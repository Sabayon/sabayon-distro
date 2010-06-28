# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
PYTHON_DEPEND="2"

inherit eutils multilib python base

DESCRIPTION="Release metatool used for creating Sabayon (and Gentoo) releases"
HOMEPAGE="http://www.sabayon.org"
SRC_URI="http://distfiles.sabayon.org/dev-util/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+doc"

DEPEND="${DEPEND}
	sys-devel/gettext"
RDEPEND="${RDEPEND}
	app-cdr/cdrtools
	net-misc/rsync
	sys-fs/squashfs-tools"

src_install() {
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" \
		PREFIX="/usr" SYSCONFDIR="/etc" install \
		|| die "emake install failed"
}

pkg_postrm() {
	python_mod_cleanup "/usr/$(get_libdir)/molecule"
}
