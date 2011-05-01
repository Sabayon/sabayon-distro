# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kde-l10n/kde-l10n-4.6.2.ebuild,v 1.2 2011/04/11 18:58:24 dilfridge Exp $

EAPI=4

inherit kde4-meta-pkg

DESCRIPTION="KDE internationalization package meta includer"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""

# ignored: ca@valencia
MY_LANGS="ar bg ca cs da de el en_GB es et eu fi fr ga gl gu he hi
hr hu ia id is it ja kk km kn ko lt lv mai nb nds nl nn pa pl pt pt_BR ro ru sk
sl sr sv th tr uk wa zh_CN zh_TW"

DEPEND=""
RDEPEND="${DEPEND}"
for MY_LANG in ${MY_LANGS} ; do
	IUSE="${IUSE} linguas_${MY_LANG}"
	RDEPEND="${RDEPEND}
		linguas_${MY_LANG}? ( kde-base/kde-l10n-${MY_LANG} )"
done

unset MY_LANG
unset MY_LANGS
