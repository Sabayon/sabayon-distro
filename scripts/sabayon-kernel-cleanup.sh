#!/bin/bash
if [ -z "$1" ]; then
	echo "$0 <ver> <ver 2> ..."
	exit 1
fi

packages=(
	"sys-kernel/sabayon-sources"
	"sys-kernel/linux-sabayon"
	"sys-kernel/ec2-sources"
	"sys-kernel/linux-ec2"
)

for package in ${packages[@]}; do
	for ver in "${@}"; do
		dirn=$(dirname ${package})
		name=$(basename ${package})
		files=$(find "${package}" -name "${name}*${ver}.ebuild")
		[ -z "${files}" ] && continue
		git rm ${files} || continue
	done

	eb_file=$(find "${package}" -name "*.ebuild" | head -n 1)
	[ -z "${eb_file}" ] && continue

	ebuild "${eb_file}" manifest || continue
	git add -u "${package}"
done
