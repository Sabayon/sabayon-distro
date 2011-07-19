# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils base

MY_PN="PackageKit"
MY_P=${MY_PN}-${PV}

DESCRIPTION="GTK+ PackageKit backend library"
HOMEPAGE="http://www.packagekit.org/"
SRC_URI="http://www.packagekit.org/releases/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-libs/dbus-glib
	media-libs/fontconfig
	>=x11-libs/gtk+-2.14.0:2
	x11-libs/pango
	~app-admin/packagekit-base-${PV}"
DEPEND="${RDEPEND} dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_configure() {
	econf \
		--localstatedir=/var \
		--enable-introspection=no \
		--disable-dependency-tracking \
		--enable-option-checking \
		--enable-libtool-lock \
		--disable-strict \
		--disable-local \
		--disable-gtk-doc \
		--disable-command-not-found \
		--disable-debuginfo-install \
		--disable-gstreamer-plugin \
		--disable-service-packs \
		--disable-managed \
		--disable-man-pages \
		--disable-cron \
		--enable-gtk-module \
		--disable-networkmanager \
		--disable-browser-plugin \
		--disable-pm-utils \
		--disable-device-rebind \
		--disable-tests \
		--disable-qt
}

src_compile() {
	( cd "${S}"/contrib/gtk-module && emake ) || die "emake install failed"
}

src_install() {
	( cd "${S}"/contrib/gtk-module && emake DESTDIR="${D}" install ) || die "emake install failed"
}
