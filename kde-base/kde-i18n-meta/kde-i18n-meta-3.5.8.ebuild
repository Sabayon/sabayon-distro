# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit kde-functions

DESCRIPTION="KDE internationalization meta-package - merge this to pull in all kde-i18n packages"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

SLOT="3.5"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

need-kde ${PV}
LANGS="af ar az bg bn br bs ca cs csb cy da de el en_GB eo es et
eu fa fi fr fy ga gl he hi hr hu is it ja kk km ko lt lv mk
mn ms nb nds nl nn pa pl pt pt_BR ro ru rw se sk sl sr
sr_latn ss sv ta tg th tr uk uz vi zh_CN zh_TW"

RDEPEND="!kde-base/kde-i18n"
for X in ${LANGS} ; do
	#SRC_URI="${SRC_URI} linguas_${X}? ( mirror://kde/stable/${PV}/src/kde-i18n/kde-i18n-${X}-${PV}.tar.bz2 )"
	IUSE="${IUSE} linguas_${X}"
	RDEPEND="${RDEPEND} ~kde-base/kde-i18n-${X}-${PV}"
done
