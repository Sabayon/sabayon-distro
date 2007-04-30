# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="32-bit Netscape plugins support for 64-bit Konqueror"
SRC_URI="mirror://debian/pool/main/k/kdelibs/kdelibs4c2a_3.5.6.dfsg.1-1_i386.deb
	mirror://debian/pool/main/k/kdebase/konqueror-nsplugins_3.5.6.dfsg.1-1_i386.deb
	mirror://debian/pool/main/liba/libart-lgpl/libart-2.0-2_2.3.17-1_i386.deb
	mirror://debian/pool/main/libi/libidn/libidn11_0.6.5-1_i386.deb
	mirror://debian/pool/main/a/acl/libacl1_2.2.42-1_i386.deb
	mirror://debian/pool/main/a/attr/libattr1_2.4.32-1.1_i386.deb"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""
LOCKFILE="/var/lib/nsplugins32/lockfile"
MYPRE=`kde-config --prefix`

DEPEND="|| ( ( ~kde-base/konqueror-3.5.6 ~kde-base/nsplugins-3.5.6 )
			~kde-base/kdebase-3.5.6 )
	app-emulation/emul-linux-x86-baselibs
	app-emulation/emul-linux-x86-compat
	app-emulation/emul-linux-x86-gtklibs
	app-emulation/emul-linux-x86-qtlibs
	app-emulation/emul-linux-x86-sdl
	app-emulation/emul-linux-x86-soundlibs
	app-arch/dpkg"

src_unpack() {
	cd ${WORKDIR}
	for pkg in ${A}
	do
		/usr/bin/dpkg --extract ${DISTDIR}/$pkg ${WORKDIR}
	done
}

src_install() {
	cd ${WORKDIR}
	echo "Installing - please don't remove manually" > ${T}/lockfile || die "Can't create lockfile."
	insinto /var/lib/nsplugins32/
	doins ${T}/lockfile || die "Can't install lockfile."

	insinto /usr/lib32
	insopts -m0755
	doins usr/lib/libDCOP.so* usr/lib/libkdecore.so* usr/lib/libkdefx.so* usr/lib/libkdesu.so* usr/lib/libkdeui.so* usr/lib/libkio.so* usr/lib/libkwalletclient.so* usr/lib/libart_lgpl_2.so* usr/lib/libidn.so* usr/lib/libkparts.so* lib/libattr.so* lib/libacl.so*
	into ${MYPRE}
	dobin usr/bin/nsplugin*
	cp ${MYPRE}/bin/nspluginscan ${D}/${MYPRE}/bin/nspluginscan64
	cp ${MYPRE}/bin/nspluginviewer ${D}/${MYPRE}/bin/nspluginviewer64
}

pkg_postinst() {
	rm ${LOCKFILE}
}

pkg_prerm() {
	if [ ! -r ${LOCKFILE} ]; then
		cp ${MYPRE}/bin/nspluginscan64 /var/lib/nsplugins32/nspluginscan
		cp ${MYPRE}/bin/nspluginviewer64 /var/lib/nsplugins32/nspluginviewer
	fi
}

pkg_postrm() {
	if [ ! -r ${LOCKFILE} ]; then
		einfo "Restoring 64-bit Konqueror plugins"
		mv /var/lib/nsplugins32/nsplugin* ${MYPRE}/bin
	else
		einfo "Upgrading or rebuilding package. Not restoring 64-bit plugins."
	fi
}
