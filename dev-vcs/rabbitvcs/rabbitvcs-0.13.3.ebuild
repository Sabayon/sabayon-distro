# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 3.*"

inherit gnome2-utils distutils

DESCRIPTION="Integrated version control support for your desktop"
HOMEPAGE="http://rabbitvcs.org"

FRONTENDS="cli gedit nautilus thunar"
IUSE="diff spell ${FRONTENDS}"
SRC_URI="http://rabbitvcs.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="dev-python/pygtk
	dev-python/pygobject
	dev-python/pysvn
	dev-python/configobj
	diff? ( dev-util/meld )
	gedit? ( app-editors/gedit )
	nautilus? ( dev-python/nautilus-python
		dev-python/dbus-python )
	thunar? ( dev-python/thunarx-python
		dev-python/dbus-python )
	spell? ( dev-python/gtkspell-python )"

src_prepare() {
	distutils_src_prepare

	# we should not do gtk-update-icon-cache from setup script
	# we prefer portage for that
	sed 's/"install"/"fakeinstall"/' -i "${S}/setup.py" \
		|| die "Can't update setup script"
}

src_install() {
	distutils_src_install
	use cli && dobin "clients/cli/${PN}"
	use gedit && {
		insinto /usr/$(get_libdir)/gedit-2/plugins
		doins "clients/gedit/${PN}-plugin.py"
		doins "clients/gedit/${PN}.gedit-plugin"
	}
	use nautilus && {
		insinto "/usr/$(get_libdir)/nautilus/extensions-2.0/python"
		doins "clients/nautilus/RabbitVCS.py"
	}
	use thunar && {
		has_version '>=xfce-base/thunar-1.1.0' && tv=2 || tv=1
		insinto "/usr/$(get_libdir)/thunarx-${tv}/python"
		doins "clients/thunar/RabbitVCS.py"
	}
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	distutils_pkg_postinst
	gnome2_icon_cache_update

	elog "You should restart file manager for changes to have effect:"
	use nautilus && elog "\$ nautilus -q && nautilus &"
	use thunar && elog "\$ thunar -q && thunar &"
	elog ""
	elog "Also, you should really look at the known issues page:"
	elog "http://wiki.rabbitvcs.org/wiki/support/known-issues"
}

pkg_postrm() {
	distutils_pkg_postrm
	gnome2_icon_cache_update
}
