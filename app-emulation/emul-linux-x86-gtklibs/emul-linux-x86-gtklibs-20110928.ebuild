# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-gtklibs/emul-linux-x86-gtklibs-20110928.ebuild,v 1.1 2011/09/28 13:55:16 pacho Exp $

EAPI="4"

inherit emul-linux-x86

LICENSE="GPL-3 GPL-2 LGPL-2 LGPL-2.1 FTL MIT || ( LGPL-2.1 MPL-1.1 )"
KEYWORDS="-* ~amd64"

DEPEND=""
RDEPEND="~app-emulation/emul-linux-x86-baselibs-${PV}
	~app-emulation/emul-linux-x86-xlibs-${PV}
	~app-emulation/emul-linux-x86-opengl-${PV}"
# RDEPEND on opengl stuff shouldn't be needed, but add it anyway until bug #354943 is properly solved

# similar to http://bugs.sabayon.org/show_bug.cgi?id=2761
# but note -32 in gdk-pixbuf-query-loaders32 and lib32
my_gdk_pixbuf_query_loaders() {
	# causes segfault if set
	unset __GL_NO_DSO_FINALIZER

	tmp_file=$(mktemp --suffix=gdk_pixbuf_ebuild)
	# be atomic!
	if gdk-pixbuf-query-loaders32 > "${tmp_file}"; then
		cat "${tmp_file}" > "${ROOT}usr/lib32/gdk-pixbuf-2.0/2.10.0/loaders.cache"
	else
		ewarn "Warning, gdk-pixbuf-query-loaders32 failed."
	fi
	rm "${tmp_file}"
}

src_prepare() {
	query_tools="${S}/usr/bin/gtk-query-immodules-2.0|${S}/usr/bin/gdk-pixbuf-query-loaders|${S}/usr/bin/pango-querymodules"
	ALLOWED="(${S}/etc/env.d|${S}/etc/gtk-2.0|${S}/etc/pango/i686-pc-linux-gnu|${query_tools})"
	emul-linux-x86_src_prepare

	# these tools generate an index in /etc/{pango,gtk-2.0}/${CHOST}
	mv -f "${S}/usr/bin/pango-querymodules"{,32} || die
	mv -f "${S}/usr/bin/gtk-query-immodules-2.0"{,-32} || die
	mv -f "${S}/usr/bin/gdk-pixbuf-query-loaders"{,32} || die
}

pkg_preinst() {
	#bug 169058
	for l in "${ROOT}/usr/lib32/{pango,gtk-2.0}" ; do
		[[ -L ${l} ]] && rm -f ${l}
	done
}

pkg_postinst() {
	PANGO_CONFDIR="/etc/pango/i686-pc-linux-gnu"
	if [[ ${ROOT} == "/" ]] ; then
		einfo "Generating pango modules listing..."
		mkdir -p ${PANGO_CONFDIR}
		pango-querymodules32 > ${PANGO_CONFDIR}/pango.modules
	fi

	GTK2_CONFDIR="/etc/gtk-2.0/i686-pc-linux-gnu"
	einfo "Generating gtk+ immodules/gdk-pixbuf loaders listing..."
	mkdir -p ${GTK2_CONFDIR}
	gtk-query-immodules-2.0-32 > "${ROOT}${GTK2_CONFDIR}/gtk.immodules"
	my_gdk_pixbuf_query_loaders

	# gdk-pixbuf.loaders should be in their CHOST directories respectively.
	if [[ -e ${ROOT}/etc/gtk-2.0/gdk-pixbuf.loaders ]] ; then
		ewarn
		ewarn "File /etc/gtk-2.0/gdk-pixbuf.loaders shouldn't be present on"
		ewarn "multilib systems, please remove it by hand."
		ewarn
	fi
}
