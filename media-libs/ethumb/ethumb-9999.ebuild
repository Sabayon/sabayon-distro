# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit enlightenment

DESCRIPTION="Enlightenment thumbnailing library (meant to replace epsilon)"
HOMEPAGE="http://trac.enlightenment.org/e/wiki/Ethumb"
LICENSE="LGPL-3"

IUSE="+dbus emotion epdf static-libs"

KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-libs/eina-9999
	>=dev-libs/ecore-9999
	>=media-libs/edje-9999
	>=media-libs/evas-9999
	media-libs/libexif

	dbus? ( >=dev-libs/e_dbus-9999 )
	emotion? ( >=media-libs/emotion-9999 )
	epdf? ( >=app-text/epdf-9999 )"

RDEPEND="${DEPEND}"

src_configure() {
	MY_ECONF="$(use_enable dbus ethumbd)
		$(use_enable emotion)
		$(use_enable epdf)"

	enlightenment_src_configure
}
