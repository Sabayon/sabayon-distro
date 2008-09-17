#!/bin/sh

for X in `find -name kde-i18n-*3.5.9*.ebuild`; do
	echo
	echo " ________ DOING "${X}" ________"
	echo
	svn cp ${X} ${X/3.5.9/3.5.10}
	ebuild ${X} manifest
done
