# Copyright 2004-2009 Sabayon Project
# Distributed under the terms of the GNU General Public License v2
# $

inherit eutils

# @ECLASS-VARIABLE: KERN_INITRAMFS_SEARCH_NAME
# @DESCRIPTION:
# Argument used by `find` to search inside ${ROOT}boot Linux
# Kernel initramfs files to patch
KERN_INITRAMFS_SEARCH_NAME="${KERN_INITRAMFS_SEARCH_NAME:-initramfs-genkernel*}"

# @ECLASS-VARIABLE: GFX_SPLASH_NAME
# @DESCRIPTION:
# Default splash theme name to use
GFX_SPLASH_NAME="${GFX_SPLASH_NAME:-sabayon}"

# @ECLASS-VARIABLE: PLYMOUTH_THEME
# @DESCRIPTION:
# Default plymouth theme name to use
PLYMOUTH_THEME="${PLYMOUTH_THEME:-sabayon}"

# @FUNCTION: update_kernel_initramfs_splash
# @USAGE: update_kernel_initramfs_splash [splash_theme] [splash_file]
# @RETURN: 1, if something went wrong
#
# @MAINTAINER:
# Fabio Erculiani
update_kernel_initramfs_splash() {

	[[ -z "${2}" ]] && die "wrong update_kernel_splash arguments"

	if ! has_version "media-gfx/splashutils"; then
		ewarn "media-gfx/splashutils not found, cannot update kernel splash"
		return 1
	fi
	splash_geninitramfs -a "${2}" ${1}
	return ${?}

}

# @FUNCTION: update_sabayon_kernel_initramfs_splash
# @USAGE: update_sabayon_kernel_initramfs_splash
#
# @MAINTAINER:
# Fabio Erculiani
update_sabayon_kernel_initramfs_splash() {
	local splash_name="${GFX_SPLASH_NAME}"
	local override_splash_file="${ROOT}etc/oem/splash_name"
	if [ -f "${override_splash_file}" ]; then
		found_splash_name=$(cat "${override_splash_file}" | cut -d" " -f 1)
		if [ -d "/etc/splash/${found_splash_name}" ]; then
			splash_name="${found_splash_name}"
		fi
	fi
	for bootfile in `find ${ROOT}boot -name "${KERN_INITRAMFS_SEARCH_NAME}"`; do
		einfo "Updating boot splash for ${bootfile}"
		update_kernel_initramfs_splash "${GFX_SPLASH_NAME}" "${bootfile}"
	done
}
