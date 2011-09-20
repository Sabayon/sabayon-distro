# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
EGIT_REPO_URI="git://github.com/Enlik/querypkg.git"
EGIT_COMMIT="v${PV}"
inherit git-2

DESCRIPTION="A simple CLI interface to packages.sabayon.org"
HOMEPAGE="http://github.com/Enlik/querypkg/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/perl-5.10
	dev-perl/JSON-XS
	dev-perl/URI
	dev-perl/libwww-perl"
DEPEND=""

src_install() {
	newbin "${PN}.pl" "${PN}"
	dodoc "README"
}
