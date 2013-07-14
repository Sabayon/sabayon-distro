#!/bin/bash
if [ -z "$1" ]; then
	echo do-kernel-bump.sh ver
	exit 1
fi

ver=$1
packages=(
	"sys-kernel/sabayon-sources"
	"sys-kernel/linux-sabayon"
	"sys-kernel/ec2-sources"
	"sys-kernel/linux-ec2"
)

for package in "${packages[@]}"; do
	name="${package/*\/}"
	eb_name="${package}/${name}-${ver}.ebuild"
	cp "${package}/${name}.skel" "${eb_name}" || exit 1
	git add "${eb_name}" || exit 1
	ebuild "${eb_name}" manifest || exit 1
	git add "${package}/Manifest" || exit 1
done
