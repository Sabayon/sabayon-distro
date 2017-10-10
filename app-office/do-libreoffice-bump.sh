#!/bin/sh

FROM_PV="5.4.0.3"
TO_PV="5.4.2.2"
FAILED_LANGS=""
DONE_LANGS=""
for item in `find -name libreoffice-l10n-*${FROM_PV}*.ebuild`; do

	echo $item
	newfile=${item/${FROM_PV}/${TO_PV}}
	cp "${item}" "${newfile}" || exit 1

	# uncomment if you like it (but please don't remove)
	manifest=${newfile%/*}/Manifest
	#if [ -e "$manifest" ]; then
	#	# Note: does not guarantee that a langpack won't be downloaded... it is possible
	#	# that the overlay has a particular language pack which isn't present in Portage tree.
	#	grep DIST /usr/portage/app-office/libreoffice-l10n/Manifest >> "$manifest" || exit 1
	#fi

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
