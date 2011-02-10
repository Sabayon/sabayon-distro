# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit gnome2 python eutils

MY_P=${PN/genesis/genesis-sync}_${PV}
S=${WORKDIR}/genesis-sync

DESCRIPTION="Genesis is a graphical frontend for SyncEvolution written in PyGTK. It makes SyncEvolution accessible without having to use a command line and provides 
graphical feedback of transaction results."
HOMEPAGE="https://launchpad.net/genesis-sync"
SRC_URI="http://launchpadlibrarian.net/50282719/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug"

RDEPEND="dev-python/pygtk
	dev-python/notify-python
	dev-python/dbus-python
	dev-python/pyxdg
	dev-python/evolution-python
	dev-python/configobj
	dev-python/python-distutils-extra
	dev-python/libwnck-python
	app-pda/syncevolution"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog NEWS README"

src_configure(){
  :
}

src_compile(){
  :
}

src_install() {
  python setup.py install --root="${D}"  || die "setup.py install failed"
}
