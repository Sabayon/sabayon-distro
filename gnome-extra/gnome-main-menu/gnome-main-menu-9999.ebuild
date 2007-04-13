# Copyright 2000-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/slab/slab-1.9999.ebuild,v 1.11 2006/07/02 20:24:08 vapier Exp $

inherit eutils subversion mono gnome2

DESCRIPTION="The new Desktop Menu from SuSE Linux Enterprise by Novell"
HOMEPAGE="http://www.novell.com/products/desktop/preview.html"

# Have to set SRC_URI blank or gnome2 eclass tries to fetch ${P}.tar.gz
SRC_URI=""

ESVN_REPO_URI="http://svn.gnome.org/svn/gnome-main-menu/trunk"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

# We have USE flags depending on each other, which leads to this logic. We
# prefer an activated USE flag and override the dependent USE flags.

RDEPEND=">=net-dns/avahi-0.6.10
	>=net-misc/networkmanager-0.6.3
	>=dev-lang/mono-1.1.10
	>=sys-apps/dbus-0.30
	>=gnome-base/libgtop-2.14.1
	>=sys-apps/hal-0.5.7-r3"
DEPEND="${RDEPEND}
	doc? (
		app-doc/doxygen
		dev-util/gtk-doc
		mono? ( >=dev-util/monodoc-1.1.8 )
	)
	gnome-base/gnome-common
	!gnome-extra/slab"

src_unpack() {
	subversion_src_unpack
	cd ${S}

	gnome2_omf_fix
	epatch ${FILESDIR}/02-${PN}-autogen-noconfigure.patch
	if ! use doc; then
	{
		epatch ${FILESDIR}/03-configure.in-remove-gtk-doc.patch
	}
	fi
	
	./autogen.sh --libexecdir=/usr/libexec --sysconfdir=/etc --libdir=/usr/lib --includedir=/usr/include --sbindir=/sbin
}

src_compile() {

	gnome2_src_compile
}

src_install() {
	gnome2_src_install

	dodoc AUTHORS COPYING ChangeLog README NEWS
}

pkg_postinst() {
	gnome2_pkg_postinst
}
