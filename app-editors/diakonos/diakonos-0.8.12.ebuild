# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
USE_RUBY="ruby19"

inherit ruby-ng

DESCRIPTION="A Linux editor for the masses"
HOMEPAGE="http://purepistos.net/diakonos"
SRC_URI="http://purepistos.net/${PN}/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

each_ruby_install() {
	${RUBY} install.rb --dest-dir "${D}" || die "install failed"
}
