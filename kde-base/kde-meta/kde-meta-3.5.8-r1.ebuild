# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kde-meta/kde-meta-3.5.8.ebuild,v 1.1 2007/10/19 22:09:58 philantrop Exp $
MAXKDEVER=$PV

inherit kde-functions
DESCRIPTION="kde - merge this to pull in all kde packages"
HOMEPAGE="http://www.kde.org/"

LICENSE="GPL-2"
SLOT="3.5"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="accessibility nls"

RDEPEND="~kde-base/kdelibs-${PV}
$(deprange $PV $MAXKDEVER kde-base/kdeaddons-meta)
$(deprange $PV $MAXKDEVER kde-base/kdeadmin-meta)
$(deprange $PV $MAXKDEVER kde-base/kdebase-meta)
$(deprange $PV $MAXKDEVER kde-base/kdeedu-meta)
$(deprange $PV $MAXKDEVER kde-base/kdegames-meta)
$(deprange $PV $MAXKDEVER kde-base/kdegraphics-meta)
$(deprange $PV $MAXKDEVER kde-base/kdemultimedia-meta)
$(deprange $PV $MAXKDEVER kde-base/kdenetwork-meta)
$(deprange $PV $MAXKDEVER kde-base/kdepim-meta)
$(deprange $PV $MAXKDEVER kde-base/kdetoys-meta)
$(deprange $PV $MAXKDEVER kde-base/kdeutils-meta)
$(deprange $PV $MAXKDEVER kde-base/kdeartwork-meta)
$(deprange $PV $MAXKDEVER kde-base/kdewebdev-meta)
accessibility? ( $(deprange $PV $MAXKDEVER kde-base/kdeaccessibility-meta) )
nls? ( || ( $(deprange $PV $MAXKDEVER kde-base/kde-i18n) $(deprange $PV $MAXKDEVER kde-base/kde-i18n-meta ) ) )
!kde-base/kde"
