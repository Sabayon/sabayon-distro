#!/bin/sh

for X in `find -name kde-l10n-*4.2.95*.ebuild`; do
        echo
        echo " ________ DOING "${X}" ________"
        echo
        cp ${X} ${X/4.2.95/4.3.0}
        ebuild ${X} manifest
done

