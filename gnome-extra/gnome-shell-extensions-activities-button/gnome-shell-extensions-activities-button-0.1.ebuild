# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="A gnome-shell extension to add the distributor logo beside the Activities button"
HOMEPAGE="http://www.fpmurphy.com/gnome-shell-extensions"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="
	>=dev-libs/glib-2.26
	>=gnome-base/gnome-desktop-3:3"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gnome-desktop:3[introspection]
	media-libs/clutter:1.0[introspection]
	net-libs/telepathy-glib[introspection]
	x11-libs/gtk+:3[introspection]
	x11-libs/pango[introspection]"
DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.22
	>=dev-util/intltool-0.26
	gnome-base/gnome-common"

src_prepare() {
	 sed -i -e "s:fedora-logo-icon:distributor-logo:" "activitiesbutton@fpmurphy.com/extension.js" || die "sed failed!"
}

S="${WORKDIR}"

src_install()	{
	insinto /usr/share/gnome-shell/extensions
	doins -r activitiesbutton@fpmurphy.com
}
