# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gems

DESCRIPTION="Ruby wrapper around the Twitter API"
HOMEPAGE="http://twitter.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-ruby/hpricot
	dev-ruby/activesupport
	>=dev-ruby/hoe-1.4.0"

src_install() {
	gems_src_install

	cd ${D}/${GEMSDIR}/gems/${P}
	
	# Simple post patch
	epatch "${FILESDIR}/simple_post.patch"

	# More flexible on commands
	epatch "${FILESDIR}/flexi_commands.patch"
}
