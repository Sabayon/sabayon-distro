#!/bin/sh

for X in `find -name kde-l10n-*4.3.2*.ebuild`; do
        echo
        echo " ________ DOING "${X}" ________"
        echo
        cp ${X} ${X/4.3.2/4.3.3}
        ebuild ${X} manifest
done

