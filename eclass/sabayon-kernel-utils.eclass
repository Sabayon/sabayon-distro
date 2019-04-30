# Copyright 2019 Sabayon Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: sabayon-kernel-utils.eclass
# @MAINTAINER:
# geaaru
# @AUTHOR:
# geaaru
# @DESCRIPTION:
# Sabayon kernel doesn't contain KV_PATCH version.
# So, we need a tool for retrieve real version for
# external kernel module compilation (like wireguard).

case "${EAPI:-0}" in
	5|6|7)
		;;
	*)
		die "Unsupporteed EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

inherit toolchain-funcs

# @FUNCTION: sabayon-kernel-detect_version
# @USAGE:
# @DESCRIPTION: Retrieve the right KV_PATCH of sabayon source.
sabayon-kernel-detect_version() {
	KV_BRANCH="${KV_MAJOR}.${KV_MINOR}"

	local kpath="/etc/kernels/linux-sabayon-${KV_MAJOR}.${KV_MINOR}*"
	local check=$(ls --color=none -d ${kpath} 2>/dev/null | wc -l)
	[ "$check" != 1 ] && die "No kernel found for branch ${KV_BRANCH}"

	local v=$(basename $(ls --color=none -d  ${kpath}))
	v="${v/linux-sabayon-/}"

	KV_PATCH=$(ver_cut 3 ${v})
}
