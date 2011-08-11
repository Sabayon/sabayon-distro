# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="A GNOME Shell extension to add the distributor logo beside the Activities button"
HOMEPAGE="http://www.fpmurphy.com/gnome-shell-extensions"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="gnome-base/gnome-shell"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

S="${WORKDIR}"

src_prepare() {
	sed -i -e "s:fedora-logo-icon:distributor-logo:" "activitiesbutton@fpmurphy.com/extension.js" || die "sed failed"
	sed -i -e "s/font-size: 18px;/font-size: 14px;/" "activitiesbutton@fpmurphy.com/stylesheet.css" || die "sed failed"
}

src_install()	{
	insinto /usr/share/gnome-shell/extensions
	doins -r activitiesbutton@fpmurphy.com
}
