#!/bin/sh
if [ -z "$2" ]; then
	echo do-kernel-bump.sh OLDVER NEWVER
	exit
fi

OLD=$1
NEW=$2
PACKAGES="sys-kernel/sabayon-sources sys-kernel/linux-sabayon
	sys-kernel/server-sources sys-kernel/linux-server
	sys-kernel/panda-sources sys-kernel/linux-panda
	sys-kernel/beagle-sources sys-kernel/linux-beagle"

for package in ${PACKAGES}; do
	name=$(echo ${package} | cut -d/ -f2)
	cp ${package}/${name}-${OLD}.ebuild ${package}/${name}-${NEW}.ebuild
	git add ${package}/${name}-${NEW}.ebuild
	ebuild ${package}/${name}-${NEW}.ebuild manifest
done
