# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

KMNAME="playground/utils"
inherit kde4-base

MY_P=${P/_/-}

DESCRIPTION="Filelight creates an interactive map of concentric, segmented rings that help visualise disk usage."
HOMEPAGE="http://kde-apps.org/content/show.php/filelight?content=99561"
SRC_URI="http://kde-apps.org/CONTENT/content-files/99561-${MY_P}.tgz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="2"
IUSE="debug"

RDEPEND="
	!kdeprefix? ( !kde-misc/filelight:0 )
	x11-apps/xdpyinfo
"

S="${WORKDIR}/${MY_P}"
