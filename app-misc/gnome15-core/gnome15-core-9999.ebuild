EAPI="3"
SUPPORT_PYTHON_ABIS="1"

inherit autotools bzr # python

DESCRIPTION="Gnome tools for the Logitech G Series Keyboards And Z-10 Speakers"
HOMEPAGE="http://www.gnome15.org/"

EBZR_REPO_URI="lp:gnome15"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="cairo lg4l-module title"

RDEPEND="dev-python/pygtk
		 dev-python/pyusb
		 dev-python/gconf-python
		 dev-python/dbus-python
		 dev-python/libgtop-python
		 dev-python/lxml
		 dev-python/pycairo
		 dev-python/imaging
		 dev-python/python-xlib
		 dev-python/librsvg-python
		 dev-python/pyalsa
		 dev-python/pyalsaaudio
		 dev-python/feedparser
		 dev-python/pyinotify
		 dev-python/libwnck-python
cairo? ( x11-misc/cairo-clock )
lg4l-module? ( dev-python/pyinputevent
			   app-misc/lgsetled  )
title? ( dev-python/setproctitle )"
DEPEND="${RDEPEND}"


MY_SUBPACKAGE="gnome15"

src_prepare() {
	cd ${MY_SUBPACKAGE} && eautoreconf || die "eautoreconf failed"
}

src_configure() {
	cd ${MY_SUBPACKAGE} && econf || die "econf failed"
}

src_install() {
	cd ${MY_SUBPACKAGE} && emake DESTDIR="${D}" install || die "emake install failed"

	insinto /etc/udev/rules.d
	doins ${MY_SUBPACKAGE}/src/udev/99-gnome15-kernel.rules
}

# pkg_postinst() {
# 	python_mod_optimize ${PN}
# }

# pkg_postrm() {
# 	python_mod_cleanup ${PN}
# }


