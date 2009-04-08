# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gvfs/gvfs-1.0.3-r10.ebuild,v 1.4 2009/01/30 18:52:15 aballier Exp $

EAPI="2"

inherit bash-completion gnome2 eutils

DESCRIPTION="GNOME Virtual Filesystem Layer"
HOMEPAGE="http://www.gnome.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="archive avahi bluetooth cdda doc fuse gnome gnome-keyring gphoto2 hal samba"

RDEPEND=">=dev-libs/glib-2.19
	>=sys-apps/dbus-1.0
	>=net-libs/libsoup-2.25.1[gnome]
	dev-libs/libxml2
	net-misc/openssh
	archive? ( app-arch/libarchive )
	avahi? ( >=net-dns/avahi-0.6 )
	bluetooth? (
		dev-libs/dbus-glib
		net-wireless/bluez
		dev-libs/expat )
	cdda?  (
		>=sys-apps/hal-0.5.10
		>=dev-libs/libcdio-0.78.2[-minimal] )
	fuse? ( sys-fs/fuse )
	gnome? ( >=gnome-base/gconf-2.0 )
	gnome-keyring? ( >=gnome-base/gnome-keyring-1.0 )
	gphoto2? ( >=media-libs/libgphoto2-2.4 )
	hal? ( >=sys-apps/hal-0.5.10 )
	samba? ( >=net-fs/samba-3 )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.19
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--enable-http
		--disable-bash-completion
		$(use_enable archive)
		$(use_enable avahi)
		$(use_enable bluetooth obexftp)
		$(use_enable cdda)
		$(use_enable fuse)
		$(use_enable gnome gconf)
		$(use_enable gphoto2)
		$(use_enable hal)
		$(use_enable gnome-keyring keyring)
		$(use_enable samba)"
}

src_install() {
	gnome2_src_install
	use bash-completion && \
		dobashcompletion programs/gvfs-bash-completion.sh ${PN}

	if use archive; then
		# Fix bug #249829
		insinto /usr/share/applications
		newins "${FILESDIR}/archive-mounter-2.26.0.desktop" archive-mounter.desktop || die "doins failed"
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst
	use bash-completion && bash-completion_pkg_postinst
}
