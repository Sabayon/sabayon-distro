#!/bin/sh

for X in `find -name kde-i18n-*3.5.8*.ebuild`; do
	echo
	echo " ________ DOING "${X}" ________"
	echo
	svn cp ${X} ${X/3.5.8/3.5.9}
	ebuild ${X} manifest
done
