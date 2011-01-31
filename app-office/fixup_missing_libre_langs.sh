#!/bin/sh
LANGS="af ar as ast be_BY bg bn bo br brx bs ca ca_XV cs cy da de dgo dz el en \
en_GB en_ZA eo es et eu fa fi fr ga gd gl gu he hi hr hu id is it ja ka kk km kn \
ko kok ks ku ky lo lt lv mai mk ml mn mni mr ms my nb ne nl nn nr ns oc om or pa_IN \
pap pl ps pt pt_BR ro ru rw sa_IN sat sd sh si sk sl sq sr ss st sv sw_TZ ta te tg \
th ti tn tr ts ug uk uz ve vi xh zh_CN zh_TW zu"

FAILED=""
source_ebuild="libreoffice-l10n-af/libreoffice-l10n-af-3.3.0.ebuild"
for lang in ${LANGS}; do
	dir="libreoffice-l10n-${lang}"
	if [ -d "${dir}" ]; then
		continue
	fi
	echo "creating ${dir}"
	mkdir "${dir}" || exit 1
	new_ebuild="${dir}/${dir}-3.3.0.ebuild"
	cp "${source_ebuild}" "${new_ebuild}" || exit 1
	ebuild "${new_ebuild}" manifest || FAILED+="${new_ebuild}"
done
echo "failed: ${FAILED}"
