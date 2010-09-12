# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gdesklets

DESKLET_NAME="gauges-desklet"
MY_P=${DESKLET_NAME}-${PV}

DESCRIPTION="A Scalable, themeable, configurable, set of system monitors (automobile gauges look) for gdesklets."
HOMEPAGE="http://www.gdesklets.info/archive/"
SRC_URI="http://www.gdesklets.info/archive/${MY_P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=">=gnome-extra/gdesklets-core-0.34.3"
DEPEND="${RDEPEND}"

S=${WORKDIR}/Displays/${DESKLET_NAME}
