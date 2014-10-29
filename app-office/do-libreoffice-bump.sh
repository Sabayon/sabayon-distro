#!/bin/sh

FROM_PV="4.2.5"
TO_PV="4.2.6"
FAILED_LANGS=""
DONE_LANGS=""
for item in `find -name libreoffice-l10n-*${FROM_PV}*.ebuild`; do

	echo $item
	newfile=${item/${FROM_PV}/${TO_PV}}
	cp "${item}" "${newfile}" || exit 1

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
