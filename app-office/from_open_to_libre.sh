#!/bin/sh

TO_LIBRE_VER="3.3.0"
FAILED=""

for dir in openoffice-l10n-*; do
	libre_name="${dir/open/libre}"
	if [ ! -d "${libre_name}" ]; then
		mkdir "${libre_name}" || exit 1
		echo "making directory: ${libre_name}"
	fi
	open_ebuild=$(find "${dir}" -name "${dir}*.ebuild" | sort | tail -n 1)
	if [ -z "${open_ebuild}" ]; then
		echo "no ebuilds for: ${dir}"
		continue
	fi
	echo "copying to: ${libre_name}, used: ${open_ebuild}"
	open_ebuild_name=$(basename "${open_ebuild}")
	dest_libre_ebuild="${libre_name}"/"${open_ebuild_name/open/libre}"
	if [ -n "${TO_LIBRE_VER}" ]; then
		dest_libre_ebuild="${dest_libre_ebuild%-*}-${TO_LIBRE_VER}.ebuild"

	fi
	cp "${open_ebuild}" "${dest_libre_ebuild}" || exit 1
	sed -i "s:inherit openoffice-l10n:inherit libreoffice-l10n:g" \
		"${dest_libre_ebuild}" || exit 1
	echo "doing manifest of ${dest_libre_ebuild}"
	ebuild "${dest_libre_ebuild}" manifest || FAILED+=" ${dest_libre_ebuild}"
done

echo "Failed: ${FAILED}"
