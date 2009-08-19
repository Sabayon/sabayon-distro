#!/bin/sh

SOURCE_DIR="kde-l10n-it"
SOURCE_VER="4.3.0"
DEST_VER="4.3.0"

for arg in $@; do

	echo "doing ${arg}"

	mkdir "kde-l10n-${arg}"
	[[ "${?}" != "0" ]] && echo "error at mkdir ${arg}" && exit 1

	source="${SOURCE_DIR}/${SOURCE_DIR}-${SOURCE_VER}.ebuild"
	dest="kde-l10n-${arg}/kde-l10n-${arg}-${DEST_VER}.ebuild"

	echo "copying ${source} to ${dest}"

	cp ${source} ${dest}
	[[ "${?}" != "0" ]] && echo "error at cp ${source} ${dest}" && exit 2
	ebuild ${dest} manifest	

done
