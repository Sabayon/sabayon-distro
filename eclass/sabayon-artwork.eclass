# Copyright 2004-2009 Sabayon Project
# Distributed under the terms of the GNU General Public License v2
# $

inherit eutils

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

        for bootfile in `find ${ROOT}boot -name initramfs-genkernel*sabayon`; do
                einfo "Updating boot splash for ${bootfile}"
                update_kernel_initramfs_splash sabayon "${bootfile}"
        done

}
