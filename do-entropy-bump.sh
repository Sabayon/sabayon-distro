#!/bin/sh
if [ -z "$2" ]; then
	echo do-entropy-bump.sh OLDVER NEWVER
	exit
fi

OLD=$1
NEW=$2
PACKAGES="sys-apps/entropy sys-apps/entropy-client-services app-admin/equo app-admin/spritz sys-apps/entropy-server app-admin/entropy-notification-applet kde-misc/entropy-kioslaves"

for package in ${PACKAGES}; do
	name=$(echo ${package} | cut -d/ -f2)
	cp ${package}/${name}-${OLD}.ebuild ${package}/${name}-${NEW}.ebuild
	git add ${package}/${name}-${NEW}.ebuild
	ebuild ${package}/${name}-${NEW}.ebuild manifest
done
