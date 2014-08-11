# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/pithos/pithos-20130808.ebuild,v 1.2 2014/04/06 10:45:27 eva Exp $

EAPI=5
PYTHON_COMPAT=(python2_7)
inherit eutils distutils-r1

if [[ ${PV} == 99999999 ]]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/kevinmehall/pithos.git
					https://github.com/kevinmehall/pithos.git"
else
	MY_PV="6c9a9ff1660bb8c35b846cb5763f8a131228b6d4"
	SRC_URI="https://github.com/kevinmehall/${PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${MY_PV}"
fi

DESCRIPTION="A Pandora Radio (pandora.com) player for the GNOME Desktop"
HOMEPAGE="http://kevinmehall.net/p/pithos/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

RDEPEND="dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/pygobject:2[${PYTHON_USEDEP}]
	dev-python/notify-python[${PYTHON_USEDEP}]
	dev-python/pygtk[${PYTHON_USEDEP}]
	dev-python/gst-python:0.10[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	media-plugins/gst-plugins-meta:0.10[aac,http,mp3]
	gnome? ( gnome-base/gnome-settings-daemon )
	!gnome? ( dev-libs/keybinder[python] )"

PATCHES=(
	"${FILESDIR}"/${P}-detect-datadir.patch
	"${FILESDIR}"/${P}-dont-notify-volume.patch
)

src_prepare() {
	# replace the build system with something more sane
	cp "${FILESDIR}"/setup.py "${S}"

	distutils-r1_src_prepare
}
