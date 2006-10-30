# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Thanks to kucrut for modifying this ;)

inherit kde

DESCRIPTION="The SabayonLinux ksplash theme"
HOMEPAGE="http://www.sabayonlinux.org"
THEME_URI="http://sabayonlinux.org/distfiles/kde-misc"

SRC_URI="${THEME_URI}/SabayonLinux-1.0.tar.gz"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64 x86 ppc ppc64"
IUSE=""
RESTRICT="nomirror"

DEPEND=">=kde-misc/ksplash-engine-moodin-0.4.2"

need-kde 3.4

src_unpack() {
  mkdir ${S}
  cd ${S}
  for theme in ${SRC_URI} ; do
  unpack $(basename $theme)
  done
}

src_install() {
  dodir /home/.kde3.5/share/apps/ksplash/Themes/
  keepdir /home/.kde3.5/share/apps/ksplash/Themes/
  rm -rf /home/.kde3.5/share/apps/ksplash/Themes/*
  cd ${S}
  ewarn "Ignore any errors"
  chmod -R g-sw+rx *
  chmod -R o-sw+rx *
  chmod -R u-s+rwx *
  cp -pR * ${D}/home/.kde3.5/share/apps/ksplash/Themes/
}