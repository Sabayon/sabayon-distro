# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git

DESCRIPTION="c++ bindings for dbus"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/DBusBindings"
SRC_URI=""

EGIT_REPO_URI="git://anongit.freedesktop.org/git/dbus/dbus-c++/"
EGIT_BOOTSTRAP="./autogen.sh"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="glib"

DEPEND="sys-apps/dbus"
RDEPEND="glib? ( dev-libs/glib )"

src_compile() {
	econf $(use_enable glib) || die "econf failed!"
	emake || die "emake failed!"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}

