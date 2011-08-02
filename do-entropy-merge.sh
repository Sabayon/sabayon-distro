#!/bin/sh

if [ -z "${3}" ]; then
	echo "${0} <portage CVS dir> <overlay dir> <entropy overlay version>"
	exit 1
fi
PORTDIR="${1}"
OVERLAY_DIR="${2}"
TARGET_VERSION="${3}"

PACKAGES="sys-apps/entropy
	sys-apps/entropy-client-services
	app-admin/equo
	app-admin/sulfur
	sys-apps/entropy-server
	kde-misc/entropy-kioslaves
	sys-apps/magneto-core
	app-misc/magneto-loader
	kde-misc/magneto-kde
	x11-misc/magneto-gtk"

for package in ${PACKAGES}; do
	package_name=$(basename ${package})
	source_ebuild="${OVERLAY_DIR}/${package}/${package_name}-${TARGET_VERSION}.ebuild"
	dest_ebuild="${PORTDIR}/${package}/${package_name}-${TARGET_VERSION}.ebuild"
	cp "${source_ebuild}" "${dest_ebuild}" || exit 1
	dest_ebuild_dir=$(dirname "${dest_ebuild}")
	dest_ebuild_name=$(basename "${dest_ebuild}")
	cd "${dest_ebuild_dir}" || exit 1
	cvs add "${dest_ebuild_name}" || exit 1
	echangelog "version bump" || exit 1
	ebuild "${dest_ebuild_name}" manifest || exit 1
	repoman full || exit 1
	repoman ci -m "version bump" || exit 1
done
