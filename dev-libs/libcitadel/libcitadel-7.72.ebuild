# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base

DESCRIPTION="Contains code which is shared across all the components which make up the Citadel system"
HOMEPAGE="http://citadel.org/"
SRC_URI="http://easyinstall.citadel.org/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-libs/db
	>=dev-libs/libical-0.43
	mail-filter/libsieve
	dev-libs/expat
	net-misc/curl"

RDEPEND="${DEPEND}"
