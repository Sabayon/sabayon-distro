#!/bin/sh
if [ -z "$3" ]; then
	echo do-kernel-bump.sh NAME OLDVER NEWVER
	exit
fi

NAME=$1
OLD=$2
NEW=$3
PACKAGES="sys-kernel/${NAME}-sources sys-kernel/linux-${NAME}"

for package in ${PACKAGES}; do
	name=$(echo ${package} | cut -d/ -f2)
	cp ${package}/${name}-${OLD}.ebuild ${package}/${name}-${NEW}.ebuild
	git add ${package}/${name}-${NEW}.ebuild
	ebuild ${package}/${name}-${NEW}.ebuild manifest
done
