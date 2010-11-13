# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils base

MY_PN="PackageKit"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Qt4 PackageKit backend library"
HOMEPAGE="http://www.packagekit.org/"
SRC_URI="http://www.packagekit.org/releases/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=x11-libs/qt-core-4.4.0
	>=x11-libs/qt-dbus-4.4.0
	>=x11-libs/qt-sql-4.4.0
	~app-admin/packagekit-base-${PV}"
DEPEND="${RDEPEND}
	dev-libs/libxslt
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_configure() {
	econf \
		--enable-introspection=no \
		--localstatedir=/var \
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
		--disable-gtk-module \
		--disable-networkmanager \
		--disable-browser-plugin \
		--disable-pm-utils \
		--disable-device-rebind \
		--disable-tests \
		--enable-qt
}

src_compile() {
        ( cd ${S}/lib/packagekit-qt && emake ) || die "emake install failed"
}

src_install() {
	( cd ${S}/lib/packagekit-qt && emake DESTDIR="${D}" install ) || die "emake install failed"
}
