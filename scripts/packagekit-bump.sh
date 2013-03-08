#!/bin/sh
if [ -z "$2" ]; then
	echo $0 OLDVER NEWVER
	exit
fi

OLD=$1
NEW=$2
PACKAGES="app-admin/packagekit-base app-admin/packagekit-qt4 app-admin/packagekit-gtk app-admin/packagekit"

for package in ${PACKAGES}; do
	name=$(echo ${package} | cut -d/ -f2)
	cp ${package}/${name}-${OLD}.ebuild ${package}/${name}-${NEW}.ebuild
	git add ${package}/${name}-${NEW}.ebuild
	ebuild ${package}/${name}-${NEW}.ebuild manifest
done
