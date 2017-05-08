# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils git-2
DESCRIPTION="Raspberry Pi kernel updater tool"
HOMEPAGE="https://github.com/asb/raspi-config"
EGIT_PROJECT="rpi-update"
EGIT_REPO_URI="https://github.com/Hexxeh/rpi-update.git"

EGIT_COMMIT="d41725bf702b3ce33ce722b6d2eb219c1f20d479"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm"
IUSE=""
RDEPEND="net-misc/curl"

src_install()
{
  sed -i "s/\tupdate_vc_libs/\#\tupdate_vc_libs/g" rpi-update || die "Cannot exclude update_vc_libs"
  sed -i "s/^UPDATE_SELF=\${UPDATE_SELF:-1}/UPDATE_SELF=\${UPDATE_SELF:-0}/g" rpi-update || die "Cannot disable auto updates on rpi-update"
  dosbin rpi-update
}

pkg_postinst()
{
  ewarn "To upgrade the RaspberryPi kernel, just run 'rpi-update'"
}
