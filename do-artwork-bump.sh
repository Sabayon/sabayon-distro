#!/bin/sh
if [ -z "$2" ]; then
	echo do-artwork-bump.sh OLDVER NEWVER
	exit
fi

OLD=$1
NEW=$2
PACKAGES="x11-themes/sabayon-artwork-core x11-themes/sabayon-artwork-extra \
		x11-themes/sabayon-artwork-kde x11-themes/sabayon-artwork-gnome \
			x11-themes/sabayon-artwork-ooo x11-themes/sabayon-artwork-lxde"

for package in ${PACKAGES}; do
	name=$(echo ${package} | cut -d/ -f2)
	if [ -a ${package}/${name}-${NEW}.ebuild ]; then
		echo "${NEW} ebuild found, not overwriting"
	else
		mv ${package}/${name}-${OLD}.ebuild ${package}/${name}-${NEW}.ebuild
	fi
	git add ${package}/${name}-${NEW}.ebuild
	ebuild ${package}/${name}-${NEW}.ebuild manifest --force
done
