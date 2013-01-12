# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="GNOME framework for accessing online accounts"
HOMEPAGE="https://live.gnome.org/GnomeOnlineAccounts"

LICENSE="LGPL-2"
SLOT="0"
IUSE="gnome +introspection kerberos"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"

# pango used in goaeditablelabel
# libsoup used in goaoauthprovider
RDEPEND="
	>=dev-libs/glib-2.32:2
	app-crypt/libsecret
	dev-libs/json-glib
	dev-libs/libxml2:2
	net-libs/libsoup:2.4
	>=net-libs/libsoup-gnome-2.38:2.4
	net-libs/rest:0.7
	net-libs/webkit-gtk:3
	>=x11-libs/gtk+-3.5.1:3
	>=x11-libs/libnotify-0.7:=
	x11-libs/pango

	introspection? ( >=dev-libs/gobject-introspection-0.6.2 )
	kerberos? (
		app-crypt/gcr
		virtual/krb5 )
"
# goa-daemon can launch gnome-control-center
PDEPEND="gnome? ( >=gnome-base/gnome-control-center-3.2[gnome-online-accounts(+)] )"
DEPEND="${RDEPEND}
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.3
	>=dev-util/gdbus-codegen-2.30.0
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	# TODO: Give users a way to set the G/Y!/FB/Twitter/Windows Live secrets
	G2CONF="${G2CONF}
		--disable-static
		--enable-documentation
		--enable-exchange
		--enable-facebook
		--enable-windows-live
		$(use_enable kerberos)"
	gnome2_src_configure
}

pkg_postinst() {
	gnome2_pkg_postinst
	# Upgrading from goa 3.4 to goa 3.6
	# can make GNOME Shell unable to start
	# And this is caused by a bug in goa wrt old
	# goa-1.0 config dir. Forcing a removal, we know
	# it sucks.
	local homes=$(cat /etc/passwd | cut -d":" -f 6)
	local goa_dir=".config/goa-1.0"

	local home=
	local goa_path=
	for home in ${homes}; do
		goa_path="${home}/${goa_dir}"
		if [ -d "${goa_path}" ]; then
			ewarn "Removing broken ${goa_path} dir"
			rm "${goa_path}/"* 2> /dev/null # only remove files
			rmdir "${goa_path}" 2> /dev/null # remove dir if empty
		fi
	done
}
