# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit enlightenment

DESCRIPTION="library to simplify the use of devices"
HOMEPAGE="http://trac.enlightenment.org/e/wiki/Eeze"

KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

DEPEND="dev-libs/ecore"
RDEPEND=${DEPEND}
