# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kde-meta/kde-meta-3.5.9.ebuild,v 1.1 2008/02/20 22:42:01 philantrop Exp $

EAPI="1"
inherit kde-functions
DESCRIPTION="kde - merge this to pull in all kde packages"
HOMEPAGE="http://www.kde.org/"

LICENSE="GPL-2"
SLOT="3.5"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="accessibility nls"

RDEPEND="~kde-base/kdelibs-${PV}
>=kde-base/kdeaddons-meta-${PV}:${SLOT}
>=kde-base/kdeadmin-meta-${PV}:${SLOT}
>=kde-base/kdebase-meta-${PV}:${SLOT}
>=kde-base/kdeedu-meta-${PV}:${SLOT}
>=kde-base/kdegames-meta-${PV}:${SLOT}
>=kde-base/kdegraphics-meta-${PV}:${SLOT}
>=kde-base/kdemultimedia-meta-${PV}:${SLOT}
>=kde-base/kdenetwork-meta-${PV}:${SLOT}
>=kde-base/kdepim-meta-${PV}:${SLOT}
>=kde-base/kdetoys-meta-${PV}:${SLOT}
>=kde-base/kdeutils-meta-${PV}:${SLOT}
>=kde-base/kdeartwork-meta-${PV}:${SLOT}
>=kde-base/kdewebdev-meta-${PV}:${SLOT}
accessibility? ( >=kde-base/kdeaccessibility-meta-${PV}:${SLOT} )
nls? ( || ( >=kde-base/kde-i18n-${PV}:${SLOT} >=kde-base/kde-i18n-meta-${PV}:${SLOT} ) )
!kde-base/kde:3.5"
