# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
NEED_KDE="4.2"

inherit kde4-base

KDEAPPS_ID="75442"
MY_PN="KGRUBEditor"

DESCRIPTION="A KDE utility that edits GRUB configuration files."
HOMEPAGE="http://www.kde-apps.org/content/show.php?content=${KDEAPPS_ID}"
SRC_URI="mirror://sourceforge/${PN}/${MY_PN}-${PV}-src.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="sys-boot/grub"
