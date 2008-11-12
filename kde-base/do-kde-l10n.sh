#!/bin/sh

for X in `find -name kde-l10n-*4.0.5*.ebuild`; do
        echo
        echo " ________ DOING "${X}" ________"
        echo
        svn cp ${X} ${X/4.0.5/4.1.3}
        ebuild ${X} manifest
done

