# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="LibreOffice.org localisation meta-package"
HOMEPAGE="http://www.documentfoundation.org"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
SRC_URI=""
RDEPEND=""
DEPEND=""
IUSE=""

SPELL_DIRS="af bg ca cs cy da de el en eo es et fo fr ga gd gl he hr hu ia id it \
ku ky lt lv mi mk ms nb nl nn pap pl pt ps ro ru sk sl sv sw ti tn uk zu"

LANGS="af ar as ast be_BY bg bn bo br brx bs ca ca_XV cs cy da de dgo dz el \
en_GB en_ZA eo es et eu fa fi fr ga gl gu he hi hr hu id is it ja ka kk km kn \
ko kok ks ku lo lt lv mai mk ml mn mni mr my nb ne nl nn nr ns oc om or pa_IN \
pl pt pt_BR ro ru rw sa_IN sat sd sh si sk sl sq sr ss st sv sw_TZ ta te tg \
th tn tr ts ug uk uz ve vi xh zh_CN zh_TW zu"

for X in ${LANGS}; do
	IUSE+=" linguas_${X}"
	RDEPEND+=" linguas_${X}? ( ~app-office/libreoffice-l10n-${X}-${PV} )"
done
for X in ${SPELL_DIRS}; do
	IUSE+=" linguas_${X}"
	RDEPEND+=" linguas_${X}? ( app-dicts/myspell-${X} )"
done
