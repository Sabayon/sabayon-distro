# Copyright 2014 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: sab-patches.eclass
# @MAINTAINER:
# slawomir.nizio@sabayon.org
# @AUTHOR:
# Sławomir Nizio <slawomir.nizio@sabayon.org>
# @BLURB: eclass that makes it easier to apply patches from tarballs
# @DESCRIPTION:
# Adds a patch or patches to SRC_URI and makes it easy to apply them.
# It is intended to work with tarballs containing patches, and is
# made to make it easier for Sabayon split ebuilds.
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
# Applies patches that can be found under
# ${WORKDIR}/<name of the patch tarball without ext.>, for each tarball.
# Order of patching is specified by the 'order' file, which must exist in
# each tarball.
# Patch names that are listed in SAB_PATCHES_SKIP are skipped
# by _sab-patches_apply_from_dir.
sab-patches_apply_all() {
	local p
	for p in "${SAB_PATCHES_SRC[@]}"; do
		local dir=${p##*/}
		dir=${dir%.tar*}
		_sab-patches_apply_from_dir "${WORKDIR}/${dir}"
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

		if _sab-patches_is_skipped "${patch}"; then
			einfo "(skipping ${patch})"
		else
			epatch "${patch_path}"
		fi
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
