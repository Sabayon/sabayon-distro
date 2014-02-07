#!/bin/sh

# The purpose of this script it to generate new ebuilds for
# kde l10n pacakges based on using prior version as
# a template.
#
# Two variables must be manually supplied to the script:
# EXISTING_VER:  An existing version to be used as a template
# NEW_VER: The new version number to be generated.

EXISTING_VER="4.12.1"
NEW_VER="4.12.2"
BROKEN_ONES=""

for X in `find -name kde-l10n-*${EXISTING_VER}*.ebuild`; do
        echo
        echo " ________ DOING "${X}" ________"
        echo
        if [ ! -e ${X/${EXISTING_VER}/${NEW_VER}} ]; then
                cp ${X} ${X/${EXISTING_VER}/${NEW_VER}} || exit 1
        fi
        ebuild ${X} manifest
	if [ "${?}" != "0" ]; then
		BROKEN_ONES+=" ${X}"
	fi
done
echo "BROKEN: ${BROKEN_ONES}"
