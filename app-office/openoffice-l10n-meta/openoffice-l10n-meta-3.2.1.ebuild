# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="OpenOffice.org localisation meta-package"
HOMEPAGE="http://go-oo.org"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
SRC_URI=""
RDEPEND=""
DEPEND=""
IUSE=""

DISABLED_LANGS="af be_BY br bs cy en_ZA fa he hr ne nr ns rw ss st sw_TZ ta_IN \
tg ti_ER ts ur_IN ve xh zu tn"
SPELL_DIRS="af bg ca cs cy da de el en eo es et fr ga gl he hr hu it ku lt mk \
nb nl nn pl pt ru sk sl sv tn zu"
LANGS="ar as ast bg bn ca cs da de dz el en_GB eo es et fi fr ga gl gu hi hu \
it ja km ko ku lt lv mk ml mr my nb nl nn oc om or pa_IN pl pt pt_BR ro ru sh si \
sk sl sr sv ta te th tr ug uk uz vi zh_CN zh_TW"

for X in ${LANGS}; do
	IUSE="${IUSE} linguas_${X}"
	RDEPEND="${RDEPEND} linguas_${X}? ( ~app-office/openoffice-l10n-${X}-${PV} )"
done
for X in ${SPELL_DIRS}; do
	RDEPEND="${RDEPEND} linguas_${X}? ( app-dicts/myspell-${X} )"
done
