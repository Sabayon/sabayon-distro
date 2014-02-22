# Copyright 2014 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: sab-patches.eclass
# @MAINTAINER:
# slawomir.nizio@sabayon.org
# @AUTHOR:
# Sławomir Nizio <slawomir.nizio@sabayon.org>
# @BLURB: eclass that makes it easier to apply patches from multiple packages
# @DESCRIPTION:
# Adds a patch or patches to SRC_URI and makes it easy to apply them,
# with the intention to make the task easier for Sabayon split ebuilds.
# (Plain patches kept in a VCS are very nice, but in the case of split
# ebuilds, duplicating the patches is not effective.)
# The eclass does not define any phase function.

# @ECLASS-VARIABLE: SAB_PATCHES_SRC
# @DEFAULT_UNSET
# @DESCRIPTION:
# Array that contains URIs of patches to be added to SRC_URI. Mandatory!

# @ECLASS-VARIABLE: SAB_PATCHES_SKIP
# @DESCRIPTION:
# Array that contains patterns of patch names to be skipped.
# It does not need to be a global variable.

inherit eutils

if [[ ${#SAB_PATCHES_SRC[@]} -eq 0 ]]; then
	die "SAB_PATCHES_SRC is not set"
fi

for _sab_patch in "${SAB_PATCHES_SRC[@]}"; do
	SRC_URI=${_sab_patch}
done
unset _sab_patch

# @FUNCTION: sab-patches_apply_all
# @DESCRIPTION:
# Applies patches specified using SAB_PATCHES_SRC, skipping patches
# with names matched in SAB_PATCHES_SKIP.
# Two possible cases are supported.
# 1. A patch path which is a tarball (assumed file name: *.tar*).
# Such a tarball must unpack to ${WORKDIR}/<tarball name without *.tar*>
# and must contain a file 'order,' which is used to determine order
# of patches to apply.
# 2. A patch which is not a tarball, which will be simply applied (if
# it is not skipped).
sab-patches_apply_all() {
	local p
	for p in "${SAB_PATCHES_SRC[@]}"; do
		if [[ ${p} = *.tar* ]]; then
			local dir=${p##*/}
			dir=${dir%.tar*}
			_sab-patches_apply_from_dir "${WORKDIR}/${dir}"
		else
			local name=${p##*/}
			_sab-patches_apply_nonskipped "${DISTDIR}" "${name}"
		fi
	done
}

# @FUNCTION: sab-patches_apply
# @DESCRIPTION:
# Apply selected patches. Arguments are the directory containing
# the patch, followed by one or more patch names.
sab-patches_apply() {
	[[ $# -lt 2 ]] && die "sab-patches_apply: missing arguments"
	local dir=$1
	shift
	local patch
	for patch; do
		epatch "${dir}/${patch}"
	done
}

# @FUNCTION: _sab-patches_apply_nonskipped
# @INTERNAL
# @DESCRIPTION:
# Apply selected patches - only those which should not be skipped.
# Arguments are the directory containing the patch, followed by
# one or more patch names.
# This function is not intended to be used by ebuilds because there
# is a better way: use sab-patches_apply and skip the unwanted ones.
_sab-patches_apply_nonskipped() {
	if [[ $# -lt 2 ]]; then
		die "_sab-patches_apply_nonskipped: missing arguments"
	fi

	local dir=$1
	shift

	local patch
	for patch; do
		if [[ ${patch} = */* ]]; then
			die "_sab-patches_apply_nonskipped: '${patch}' contains slashes"
		fi

		if _sab-patches_is_skipped "${patch}"; then
			einfo "(skipping ${patch})"
		else
			epatch "${dir}/${patch}"
		fi
	done
}

# @FUNCTION: _sab-patches_apply_from_dir
# @INTERNAL
# @DESCRIPTION:
# Apply all patches from a directory in order. Obeys SAB_PATCHES_SKIP.
_sab-patches_apply_from_dir() {
	local dir=$1
	local order_file=${dir}/order
	if [[ ! -r ${order_file} ]] || [[ ! -f ${order_file} ]]; then
		die "Problems with '${order_file}'... (Does it exist?)"
	fi

	local patch
	while read patch; do
		local patch_path=${dir}/${patch}
		if \
			[[ -z ${patch} ]]    || \
			[[ ${patch} = *\ * ]] || \
			[[ ${patch} = */* ]] || \
			[[ ! -f ${patch_path} ]]; then
			die "Problems with the patch '${patch}', see ${order_file}."
		fi

		_sab-patches_apply_nonskipped "${dir}" "${patch}"
	done < "${order_file}"

	[[ $? -ne 0 ]] && die "_sab-patches_apply_from_dir: loop failed"
}

# @FUNCTION: _sab-patches_is_skipped
# @INTERNAL
# @DESCRIPTION:
# Returns success if the patch should be skipped. O(n). :)
_sab-patches_is_skipped() {
	local arg=$1
	local p
	for p in "${SAB_PATCHES_SKIP[@]}"; do
		[[ ${arg} = ${p} ]] && return 0
	done
	return 1
}
