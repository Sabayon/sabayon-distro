#!/bin/sh

# The purpose of this script is to delete old versions
# of the kde-l10n ebuilds.
#
# This script requires two preset parameters:
# DEL_VERSION:  The versions to be deleted.
# SURVIVOR_VERSION: A survivor version to be used
#                   for rebuilding the manifests

DEL_VERSION="4.6.1"
SURVIVOR_VERSION="4.6.2"

# Remove/Delete the old versions.
for X in `find -name kde-l10n-*${DEL_VERSION}*.ebuild`; do
        echo ""
        echo " ________ Removing "${X}" ________"
	rm ${X}
done

# Regenerate the manifests based on a survivor version
for X in `find -name kde-l10n-*${SURVIVOR_VERSION}*.ebuild`; do
        echo " ________ Re-manifesting "${X}" ________"
	ebuild ${X} manifest
done
