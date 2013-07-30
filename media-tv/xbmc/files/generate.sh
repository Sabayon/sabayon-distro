#!/bin/bash

set -eux

PV=$1
PN=xbmc
P="${PN}-${PV}"
DISTDIR="/usr/portage/distfiles"

rm -rf ${PN}-*/
tar xf ${DISTDIR}/${P}.tar.gz
cd ${PN}-*/
make codegenerated -f codegenerator.mk -j
cd ..
tar cf - ${PN}-*/xbmc/interfaces/python/generated/*.cpp | xz > ${DISTDIR}/${P}-generated-addons.tar.xz
rm -rf ${PN}-*/
