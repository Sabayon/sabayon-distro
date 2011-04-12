# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit perl-module

DESCRIPTION="Listadmin is a Perl script designed to administer Mailman mailinglists easily."
HOMEPAGE="http://heim.ifi.uio.no/kjetilho/hacks/#listadmin"
SRC_URI="http://heim.ifi.uio.no/kjetilho/hacks/${PN}-${PV}.tar.gz"

IUSE=""
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 x86"

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}"
