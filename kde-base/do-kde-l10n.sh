#!/bin/sh

for X in `find -name kde-l10n-*4.2.1*.ebuild`; do
        echo
        echo " ________ DOING "${X}" ________"
        echo
        svn cp ${X} ${X/4.2.1/4.2.2}
        ebuild ${X} manifest
done

