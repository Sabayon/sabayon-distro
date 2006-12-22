# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/kuroo/kuroo-0.80.2.ebuild,v 1.1 2006/04/11 20:43:16 cryos Exp $

inherit kde

DESCRIPTION="Kuroo is a KDE Portage frontend"
HOMEPAGE="http://kuroo.org/"
SRC_URI="http://files.kuroo.org/${P}.tar.bz2"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86 ~ppc ~sparc ~amd64"
IUSE=""

RDEPEND="kde-misc/kdiff3"

need-kde 3.5