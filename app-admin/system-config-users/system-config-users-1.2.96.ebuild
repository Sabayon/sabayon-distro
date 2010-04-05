# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"
inherit python base

DESCRIPTION="The system-config-users tool lets you manage the users and groups on your computer."
HOMEPAGE="http://fedoraproject.org/wiki/SystemConfig/users"
SRC_URI="https://fedorahosted.org/released/${PN}/${P}.tar.bz2"

LICENSE="GPL-1"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

DEPEND="dev-util/desktop-file-utils
	dev-util/intltool
	sys-apps/findutils
	sys-devel/gettext"

# FIXME: would require rpm-python
RDEPEND=">=sys-libs/libuser-0.56
	>=dev-python/pygtk-2.6
	sys-libs/cracklib
	sys-process/procps
	x11-misc/xdg-utils"

pkg_postrm() {
        python_mod_cleanup /usr/share/${PN}
}
