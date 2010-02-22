#!/bin/sh
if [ -z "$2" ]; then
	echo do-entropy-bump.sh OLDVER NEWVER
	exit
fi

OLD=$1
NEW=$2
PACKAGES="x11-themes/sabayon-artwork-core x11-themes/sabayon-artwork-extra \
		x11-themes/sabayon-artwork-kde x11-themes/sabayon-artwork-gnome \
			x11-themes/sabayon-artwork-ooo"

for package in ${PACKAGES}; do
	name=$(echo ${package} | cut -d/ -f2)
	mv ${package}/${name}-${OLD}.ebuild ${package}/${name}-${NEW}.ebuild
	git add ${package}/${name}-${NEW}.ebuild
	ebuild ${package}/${name}-${NEW}.ebuild manifest --force
done
