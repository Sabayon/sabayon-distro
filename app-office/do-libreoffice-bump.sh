#!/bin/sh

FROM_PV="3.5.3"
TO_PV="3.5.4"
FAILED_LANGS=""
DONE_LANGS=""
for item in `find -name libreoffice-l10n-*${FROM_PV}*.ebuild`; do

	echo $item
	newfile=${item/${FROM_PV}/${TO_PV}}
	cp "${item}" "${newfile}"
	sed -i "/^inherit libreoffice-l10n$/ s/libreoffice-l10n/libreoffice-l10n-2/" "${newfile}" || exit 1

	# do manifest
	ebuild "${newfile}" manifest
	if [ "$?" != "0" ]; then
		FAILED_LANGS="${FAILED_LANGS} ${newfile}"
		rm "${newfile}"
	else
		DONE_LANGS="${DONE_LANGS} ${newfile}"
		git add "${newfile}"
	fi

done

echo "FAILED => ${FAILED_LANGS}"
echo "DONE => ${DONE_LANGS}"
