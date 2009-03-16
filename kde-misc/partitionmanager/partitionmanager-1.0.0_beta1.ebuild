# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
NEED_KDE="4.2"
inherit kde4-base

KDEAPPS_ID="89595"
MY_PD="${PN}-${PVR/_beta1/-BETA1a}"
MY_PN="${PN}-${PVR/_beta1/-BETA1}"

DESCRIPTION="KDE utility for easy management of disks, partitions and file systems."
HOMEPAGE="http://www.kde-apps.org/content/show.php?content=${KDEAPPS_ID}"
SRC_URI="mirror://sourceforge/${PN/manager/man}/${MY_PD}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="sys-apps/parted"

S="${WORKDIR}/${MY_PN}"
