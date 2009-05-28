 
# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# Ian Whyman <ian.whyman@sabayonlinux.org> (v0.1)

EAPI="2"
inherit flag-o-matic kde4-base

MY_P="QtCurve-KDE4"
MY_PV="${MY_P}-${PV}"
DESCRIPTION="A set of widget styles for Qt4 based apps, also available for KDE3 and GTK2"
HOMEPAGE="http://www.kde-look.org/content/show.php?content=40492"
SRC_URI="http://distfiles.sabayonlinux.org/x11-themes/${PN}/${MY_PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="kde kdeprefix"

DEPEND="x11-libs/qt-gui:4[dbus]
	>=kde-base/kwin-4.1.0
	x11-libs/qt-gui:4[dbus]
	kde? ( >=kde-base/kwin-4.1.0 x11-libs/qt-gui:4[dbus] )"

S="${WORKDIR}/${MY_PV}"
DOCS="ChangeLog README TODO"

src_compile() {
if use !kde ; then
  append-cppflags "-DQTC_NO_KDE4_LINKING=true -DQTC_DISABLE_KDEFILEDIALOG_CALLS=true";
  sed -i "s/find_package(KDE4)/#&/" "${S}"/CMakeLists.txt
fi
kde4-base_src_configure
}
