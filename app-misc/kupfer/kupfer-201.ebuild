# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="kupfer, a convenient command and access tool"
HOMEPAGE="http://kaizer.se/wiki/kupfer/"

MY_P="${PN}-v${PV}"

SRC_URI="http://kaizer.se/publicfiles/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+keybinder"

DEPEND=">=dev-lang/python-2.6
	sys-devel/gcc
	dev-python/pygtk
	dev-python/pyxdg
	dev-python/dbus-python
	dev-python/libwnck-python
	dev-python/pygobject
	dev-python/libgnome-python
	dev-python/gnome-keyring-python
	keybinder? ( dev-python/keybinder )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i "s/keyring/gnomekeyring/" wscript || die
	sed -i "s/import keyring/import gnomekeyring/" \
		kupfer/core/settings.py || \
		die "Error: src_prepare failed!"
}

src_configure() {
	./waf configure --prefix=/usr || die "Error: configure failed!"
}

src_compile() {
	./waf || die "Error: src_compile failed!"
}

src_install() {
	./waf --destdir="${D}" install || die "Error: src_install failed!"
}
