# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils toolchain-funcs

DESCRIPTION="D-Bus methods provided for convenience"
SRC_URI="http://www.sabayonlinux.org/distfiles/sys-libs/${PN}/liblazy-${PV}.tar.bz2"
# FIXME: wtf?? no homepage??
HOMEPAGE=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# empty for now
RDEPEND=""
DEPEND=">=sys-apps/dbus-0.62"

src_compile() {

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
