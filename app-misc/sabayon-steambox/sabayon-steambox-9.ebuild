# Copyright 2004-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )
EGIT_REPO_URI="git://github.com/Sabayon/steambox.git"
EGIT_COMMIT="v${PV}"

inherit eutils python-single-r1 systemd git-2

DESCRIPTION="Sabayon Steam Box provisioning tools"
HOMEPAGE="http://www.sabayon.org"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE=""

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${PYTHON_DEPS}
	>=app-misc/sabayon-live-8
	|| ( dev-python/pygobject-cairo:3 dev-python/pygobject:3[cairo] )
	x11-apps/xsetroot
	x11-libs/gtk+:3
	x11-libs/vte:2.90
	x11-wm/metacity"

src_install() {
	emake DESTDIR="${D}" SYSV_INITDIR="/etc/init.d" \
		SYSTEMD_UNITDIR="$(systemd_get_unitdir)" \
		install || die
}
