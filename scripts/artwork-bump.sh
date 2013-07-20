#!/bin/bash
if [ -z "$2" ]; then
	echo do-artwork-bump.sh OLDVER NEWVER
	exit
fi

OLD=$1
NEW=$2
PACKAGES="x11-themes/sabayon-artwork-core x11-themes/sabayon-artwork-extra \
		x11-themes/sabayon-artwork-kde x11-themes/sabayon-artwork-gnome \
			x11-themes/sabayon-artwork-loo x11-themes/sabayon-artwork-lxde\
			x11-themes/sabayon-artwork-grub x11-themes/sabayon-artwork-isolinux"

for package in ${PACKAGES}; do
	name=$(echo ${package} | cut -d/ -f2)
	if [ -a ${package}/${name}-${NEW}.ebuild ]; then
		echo "${name}-${NEW}.ebuild found, not overwriting"
	else
		cp ${package}/${name}-${OLD}.ebuild ${package}/${name}-${NEW}.ebuild
	fi
	ebuild ${package}/${name}-${NEW}.ebuild manifest --force clean install clean
	git add ${package}/${name}-${NEW}.ebuild
	git add ${package}/Manifest
done
