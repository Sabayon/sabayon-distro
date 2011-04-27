# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit multilib eutils

DESCRIPTION="Tux Commander - Fast and Small filemanager - VFS modules"
HOMEPAGE="http://tuxcmd.sourceforge.net/"
SRC_URI="mirror://sourceforge/tuxcmd/tuxcmd-modules-${PV}.tar.bz2
	unrar? ( mirror://sourceforge/tuxcmd/tuxcmd-modules-unrar-${PV}.tar.bz2 )"

LICENSE="GPL-2 unrar? ( unRAR )"
SLOT="0"
KEYWORDS="~x86 ~amd64" # FreePascal restrictions
IUSE="+gnome +zip unrar +libarchive"

RDEPEND=">=app-misc/tuxcmd-0.6.70
	>=dev-libs/glib-2.18.0
	gnome? ( >=gnome-base/gvfs-1.2.0 )
	libarchive? ( >=app-arch/libarchive-2.5.5 )"
DEPEND="${RDEPEND}"

src_compile() {
	if use gnome; then
		einfo "Making GVFS module"
		pushd gvfs > /dev/null
		emake || die "GVFS module: compilation failed"
		popd > /dev/null
	fi

	if use zip; then
		einfo "Making ZIP module"
		pushd zip > /dev/null
		emake || die "ZIP module: compilation failed"
		popd > /dev/null
	fi

	if use unrar; then
		einfo "Making UNRAR module"
		pushd "${WORKDIR}/tuxcmd-modules-unrar-${PV}/unrar" > /dev/null
		emake || die "UNRAR module: compilation failed"
		popd > /dev/null
	fi

	if use libarchive; then
		einfo "Making LIBARCHIVE module"
		pushd libarchive > /dev/null
		emake shared || die "compilation failed"
		popd > /dev/null
	fi
}

src_install() {
	dodir "/usr/$(get_libdir)/tuxcmd" || die "dodir failed"
	cd "${S}"

	if use gnome; then
		pushd gvfs > /dev/null
		emake DESTDIR="${ED}/usr" install || die "GVFS module: installation failed"
		popd > /dev/null
	fi

	if use zip; then
		pushd zip > /dev/null
		emake DESTDIR="${ED}/usr" install || die "ZIP module: installation failed"
		popd > /dev/null
	fi

	if use unrar; then
		pushd "${WORKDIR}/tuxcmd-modules-unrar-${PV}/unrar" > /dev/null
		emake DESTDIR="${ED}/usr" install || die "UNRAR module: installation failed"
		popd > /dev/null
	fi

	if use libarchive; then
		pushd libarchive > /dev/null
		emake DESTDIR="${ED}/usr" install || die "LIBARCHIVE module: installation failed"
		popd > /dev/null
	fi
}
