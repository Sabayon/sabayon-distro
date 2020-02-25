# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

AVAHI_MODULE="${AVAHI_MODULE:-${PN/avahi-}}"
MY_P=${P/-${AVAHI_MODULE}}
MY_PN=${PN/-${AVAHI_MODULE}}

PYTHON_COMPAT=( python3_{6,7} )
PYTHON_REQ_USE="gdbm"

inherit autotools flag-o-matic multilib-minimal python-r1 systemd mono-env

DESCRIPTION="System which facilitates service discovery on a local network (base pkg)"
HOMEPAGE="http://avahi.org/"
SRC_URI="https://github.com/lathiat/avahi/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
IUSE="autoipd bookmarks dbus doc gdbm howl-compat +introspection ipv6 kernel_linux mdnsresponder-compat nls python selinux test mono"

S="${WORKDIR}/${MY_P}"

REQUIRED_USE="
	python? ( dbus gdbm ${PYTHON_REQUIRED_USE} )
	mono? ( dbus )
	howl-compat? ( dbus )
	mdnsresponder-compat? ( dbus )
"

COMMON_DEPEND="
	dev-libs/libdaemon
	dev-libs/expat
	dev-libs/glib:2[${MULTILIB_USEDEP}]
	gdbm? ( sys-libs/gdbm:=[${MULTILIB_USEDEP}] )
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	kernel_linux? ( sys-libs/libcap )
	introspection? ( dev-libs/gobject-introspection:= )
	python? (
		${PYTHON_DEPS}
		dbus? ( dev-python/dbus-python[${PYTHON_USEDEP}] )
		introspection? ( dev-python/pygobject:3[${PYTHON_USEDEP}] )
	)
	mono? (
		dev-lang/mono
	)
	bookmarks? (
		${PYTHON_DEPS}
		>=dev-python/twisted-16.0.0[${PYTHON_USEDEP}]
	)
"

DEPEND="
	${COMMON_DEPEND}
	dev-util/glib-utils
	doc? ( app-doc/doxygen )
	app-doc/xmltoman
	dev-util/intltool
	virtual/pkgconfig[${MULTILIB_USEDEP}]
"

RDEPEND="
	acct-user/avahi
	acct-group/avahi
	acct-group/netdev
	autoipd? (
		acct-user/avahi-autoipd
		acct-group/avahi-autoipd
	)
	${COMMON_DEPEND}
	howl-compat? ( !net-misc/howl )
	mdnsresponder-compat? ( !net-misc/mDNSResponder )
	selinux? ( sec-policy/selinux-avahi )
"

MULTILIB_WRAPPED_HEADERS=( /usr/include/avahi-qt5/qt-watch.h )
PATCHES=(
	"${FILESDIR}/${MY_P}-qt5.patch"
	"${FILESDIR}/${MY_P}-CVE-2017-6519.patch"
	"${FILESDIR}/${MY_P}-remove-empty-avahi_discover.patch"
	"${FILESDIR}/${MY_P}-python3.patch"
	"${FILESDIR}/${MY_P}-python3-unittest.patch"
	"${FILESDIR}/${MY_P}-python3-gdbm.patch"
)

pkg_setup() {
	use mono && mono-env_pkg_setup
	use python || use bookmarks && python_setup
}

src_prepare() {
	default

	if ! use ipv6; then
		sed -i \
			-e s/use-ipv6=yes/use-ipv6=no/ \
			avahi-daemon/avahi-daemon.conf || die
	fi

	sed -i\
		-e "s:\\.\\./\\.\\./\\.\\./doc/avahi-docs/html/:../../../doc/${PF}/html/:" \
		doxygen_to_devhelp.xsl || die

	# Prevent .pyc files in DESTDIR
	>py-compile

	eautoreconf

	# bundled manpages
	multilib_copy_sources
}

src_configure() {
	# those steps should be done once-per-ebuild rather than per-ABI
	use sh && replace-flags -O? -O0

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myconf=(
		--disable-static
		--localstatedir="${EPREFIX}/var"
		--with-distro=gentoo
		--enable-manpages
		--enable-xmltoman
		--disable-monodoc
		--enable-glib
		--enable-gobject
		$(multilib_native_use_enable test tests)
		$(multilib_native_use_enable autoipd)
		$(use_enable mdnsresponder-compat compat-libdns_sd)
		$(use_enable howl-compat compat-howl)
		$(multilib_native_use_enable doc doxygen-doc)
		$(use_enable dbus)
		$(multilib_native_use_enable python)
		$(use_enable nls)
		$(multilib_native_use_enable introspection)
		--disable-qt3
		--disable-qt4
		--disable-qt5
		--disable-gtk
		--disable-gtk3
		$(use_enable gdbm)
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
	)


	if use python; then
		myconf+=(
			$(multilib_native_use_enable dbus python-dbus)
			$(multilib_native_use_enable introspection pygobject)
		)
	fi

	if use mono; then
		myconf+=( $(multilib_native_use_enable doc monodoc) )
	fi

	if ! multilib_is_native_abi; then
		myconf+=(
			# used by daemons only
			--disable-libdaemon
			--with-xml=none
		)
	fi

	econf "${myconf[@]}"
}

multilib_src_compile() {
	emake

	multilib_is_native_abi && use doc && emake avahi.devhelp
}

multilib_src_install() {
	emake install DESTDIR="${D}"

	# https://github.com/lathiat/avahi/issues/28
	use howl-compat && dosym avahi-compat-howl.pc /usr/$(get_libdir)/pkgconfig/howl.pc
	use mdnsresponder-compat && dosym avahi-compat-libdns_sd/dns_sd.h /usr/include/dns_sd.h

	if multilib_is_native_abi && use doc; then
		docinto html
		dodoc -r doxygen/html/.
		insinto /usr/share/devhelp/books/avahi
		doins avahi.devhelp || die
	fi

	# The build system creates an empty "/run" directory, so we clean it up here
	rmdir "${ED}"/run
}

multilib_src_install_all() {
	if use bookmarks; then
		rm "${ED}/usr/bin/avahi-bookmarks" || die
	fi
	rm "${ED}/usr/bin/avahi-discover" \
		"${ED}/usr/share/applications/avahi-discover.desktop" \
		|| die
	find "${ED}"/usr/lib*/python* -type d -empty -delete

	if use autoipd; then
		insinto /lib/rcscripts/net
		doins "${FILESDIR}"/autoipd.sh

		insinto /lib/netifrc/net
		newins "${FILESDIR}"/autoipd-openrc.sh autoipd.sh
	fi

	dodoc docs/{AUTHORS,NEWS,README,TODO}

	find "${ED}" -name '*.la' -type f -delete || die
}

pkg_postinst() {
	if use autoipd; then
		elog
		elog "To use avahi-autoipd to configure your interfaces with IPv4LL (RFC3927)"
		elog "addresses, just set config_<interface>=( autoipd ) in /etc/conf.d/net!"
		elog
	fi
}
