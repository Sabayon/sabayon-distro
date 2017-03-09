# Copyright 2004-2009 Sabayon Project
# Distributed under the terms of the GNU General Public License v2

inherit eutils

# @ECLASS-VARIABLE: KERN_INITRAMFS_SEARCH_NAME
# @DESCRIPTION:
# Argument used by `find` to search inside ${ROOT}boot Linux
# Kernel initramfs files to patch
KERN_INITRAMFS_SEARCH_NAME="${KERN_INITRAMFS_SEARCH_NAME:-initramfs-genkernel*}"

# @ECLASS-VARIABLE: PLYMOUTH_THEME
# @DESCRIPTION:
# Default plymouth theme name to use
PLYMOUTH_THEME="${PLYMOUTH_THEME:-sabayon-artwork-plymouth-default}"

# @ECLASS-VARIABLE: SDDM_THEME
# @DESCRIPTION:
# Default sddm theme name to use
SDDM_THEME="${SDDM_THEME:-sabayon-artwork-sddm-default}"

