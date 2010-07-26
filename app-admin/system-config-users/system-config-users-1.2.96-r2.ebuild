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
IUSE="X"

DEPEND="dev-util/desktop-file-utils
	dev-util/intltool
	sys-apps/findutils
	sys-devel/gettext"

# FIXME: would require rpm-python
RDEPEND="
	X? (	>=dev-python/pygtk-2.6
		x11-misc/xdg-utils
	)
	>=sys-libs/libuser-0.56
	sys-libs/cracklib
	sys-process/procps"

PATCHES=( "${FILESDIR}/${PN}-kill-rpm.patch" )

pkg_postrm() {
        python_mod_cleanup /usr/share/${PN}
}

# FIXME: this package should depend against sys-apps/usermode
# which has been removed from Portage in May, 2009.
# If you intend to provide a full package in future (and not
# just stuff required by app-admin/anaconda, please consider
# to re-add sys-apps/usermode (version bumping, QA checking)
# and remove the hackish code in src_install below
src_install() {
	base_src_install

	# See FIXME above
	rm -rf "${D}/usr/share/"{man,applications}
	rm -rf "${D}/etc/"{pam.d,sysconfig,security}
	rm -rf "${D}/etc/sysconfig"
	rm -rf "${D}/usr/bin"
	find "${D}" -name "*.pyc" | xargs rm -f
}
