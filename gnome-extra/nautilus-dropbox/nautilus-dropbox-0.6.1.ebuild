# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils multilib

DESCRIPTION="Store, Sync and Share Files Online"
HOMEPAGE="http://www.getdropbox.com/"
SRC_URI="http://www.getdropbox.com/download?dl=packages/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug"

#app-backup/dropbox
RDEPEND=">=gnome-base/nautilus-2.16
	>=dev-python/docutils-0.4
	>=x11-libs/gtk+-2.12
	>=net-misc/wget-1.10
	>=dev-libs/glib-2.14
	>=x11-libs/libnotify-0.4.4"
DEPEND="${RDEPEND}"

DOCS="AUTHORS NEWS README"

pkg_setup () {
	G2CONF="${G2CONF} $(use_enable debug)"

	# create the group for the daemon, if necessary
	# truthfully this should be run for any dropbox plugin
	enewgroup dropbox
}

src_install () {
	gnome2_src_install

	# Allow only for users in the dropbox group
	# see http://forums.getdropbox.com/topic.php?id=3329&replies=5#post-22898
	fowners root:dropbox /usr/$(get_libdir)/nautilus/extensions-2.0/libnautilus-dropbox.{a,la,so}
	fperms 750 /usr/$(get_libdir)/nautilus/extensions-2.0/libnautilus-dropbox.{la,so}
	fperms 640 /usr/$(get_libdir)/nautilus/extensions-2.0/libnautilus-dropbox.a
}

pkg_postinst () {
	gnome2_pkg_postinst

	einfo
	einfo "Add any users who wish to have access to the dropbox nautilus"
	einfo "plugin to the group 'dropbox'."
	einfo
}

