# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

AVAHI_MODULE="${AVAHI_MODULE:-${PN/avahi-}}"
MY_P=${P/-${AVAHI_MODULE}}
MY_PN=${PN/-${AVAHI_MODULE}}

PYTHON_COMPAT=( python{2_6,2_7} )
PYTHON_REQ_USE="gdbm"

WANT_AUTOMAKE=1.11

inherit autotools eutils flag-o-matic multilib multilib-minimal \
	python-r1 systemd user

DESCRIPTION="System which facilitates service discovery on a local network (base pkg)"
HOMEPAGE="http://avahi.org/"
SRC_URI="http://avahi.org/download/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
IUSE="autoipd bookmarks dbus doc gdbm howl-compat +introspection ipv6 kernel_linux mdnsresponder-compat nls python selinux test"

S="${WORKDIR}/${MY_P}"

REQUIRED_USE="
	python? ( dbus gdbm )
	howl-compat? ( dbus )
	mdnsresponder-compat? ( dbus )
"

COMMON_DEPEND="
	dev-libs/libdaemon
	dev-libs/expat
	dev-libs/glib:2[${MULTILIB_USEDEP}]
	gdbm? ( sys-libs/gdbm[${MULTILIB_USEDEP}] )
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	kernel_linux? ( sys-libs/libcap )
	introspection? ( dev-libs/gobject-introspection )
	python? (
		${PYTHON_DEPS}
		dbus? ( dev-python/dbus-python )
	)
	selinux? ( sec-policy/selinux-avahi )
	bookmarks? (
		dev-python/twisted-core
		dev-python/twisted-web
	)
"

DEPEND="
	${COMMON_DEPEND}
	dev-util/intltool
	virtual/pkgconfig[${MULTILIB_USEDEP}]
	doc? (
		app-doc/doxygen
	)
"

RDEPEND="
	${COMMON_DEPEND}
	howl-compat? ( !net-misc/howl )
	mdnsresponder-compat? ( !net-misc/mDNSResponder )
"

pkg_preinst() {
	enewgroup netdev
	enewgroup avahi
	enewuser avahi -1 -1 -1 avahi

	if use autoipd; then
		enewgroup avahi-autoipd
		enewuser avahi-autoipd -1 -1 -1 avahi-autoipd
	fi
}

src_prepare() {
	if use ipv6; then
		sed -i \
			-e s/use-ipv6=no/use-ipv6=yes/ \
			avahi-daemon/avahi-daemon.conf || die
	fi

	sed -i\
		-e "s:\\.\\./\\.\\./\\.\\./doc/avahi-docs/html/:../../../doc/${PF}/html/:" \
		doxygen_to_devhelp.xsl || die

	# Make gtk utils optional
	epatch "${FILESDIR}"/${MY_PN}-0.6.30-optional-gtk-utils.patch

	# Fix init scripts for >=openrc-0.9.0, bug #383641
	epatch "${FILESDIR}"/${MY_PN}-0.6.x-openrc-0.9.x-init-scripts-fixes.patch

	# install-exec-local -> install-exec-hook
	epatch "${FILESDIR}"/${MY_P}-install-exec-hook.patch

	# Backport host-name-from-machine-id patch, bug #466134
	epatch "${FILESDIR}"/${MY_P}-host-name-from-machine-id.patch

	# Don't install avahi-discover unless ENABLE_GTK_UTILS, bug #359575
	epatch "${FILESDIR}"/${MY_P}-fix-install-avahi-discover.patch

	epatch "${FILESDIR}"/${MY_P}-so_reuseport-may-not-exist-in-running-kernel.patch

	# allow building client without the daemon
	epatch "${FILESDIR}"/${MY_P}-build-client-without-daemon.patch

	# Drop DEPRECATED flags, bug #384743
	sed -i -e 's:-D[A-Z_]*DISABLE_DEPRECATED=1::g' avahi-ui/Makefile.am || die

	# Fix references to Lennart's home directory, bug #466210
	sed -i -e 's/\/home\/lennart\/tmp\/avahi//g' man/* || die

	# Prevent .pyc files in DESTDIR
	>py-compile

	eautoreconf

	# bundled manpages
	multilib_copy_sources
}

src_configure() {
	# those steps should be done once-per-ebuild rather than per-ABI
	use sh && replace-flags -O? -O0
	use python && python_export_best

	# We need to unset DISPLAY, else the configure script might have problems detecting the pygtk module
	unset DISPLAY

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myconf=( --disable-static )

	if use python; then
		myconf+=(
			$(multilib_native_use_enable dbus python-dbus)
		)
	fi

	if ! multilib_is_native_abi; then
		myconf+=(
			# used by daemons only
			--disable-libdaemon
			--with-xml=none
		)
	fi

	econf \
		--localstatedir="${EPREFIX}/var" \
		--with-distro=gentoo \
		--disable-python-dbus \
		--disable-pygtk \
		--disable-xmltoman \
		--disable-monodoc \
		--disable-mono \
		--enable-glib \
		--enable-gobject \
		$(multilib_native_use_enable test tests) \
		$(multilib_native_use_enable autoipd) \
		$(use_enable mdnsresponder-compat compat-libdns_sd) \
		$(use_enable howl-compat compat-howl) \
		$(multilib_native_use_enable doc doxygen-doc) \
		$(use_enable dbus) \
		$(multilib_native_use_enable python) \
		$(use_enable nls) \
		$(multilib_native_use_enable introspection) \
		--disable-qt3 \
		--disable-qt4 \
		--disable-gtk \
		--disable-gtk3 \
		$(use_enable gdbm) \
		$(systemd_with_unitdir) \
		"${myconf[@]}"
}

multilib_src_compile() {
	emake

	multilib_is_native_abi && use doc && emake avahi.devhelp
}

multilib_src_install() {
	emake install DESTDIR="${D}"
	rm -f "${ED}"/usr/bin/avahi-bookmarks

	use howl-compat && dosym avahi-compat-howl.pc /usr/$(get_libdir)/pkgconfig/howl.pc
	use mdnsresponder-compat && dosym avahi-compat-libdns_sd/dns_sd.h /usr/include/dns_sd.h

	if multilib_is_native_abi && use doc; then
		dohtml -r doxygen/html/. || die
		insinto /usr/share/devhelp/books/avahi
		doins avahi.devhelp || die
	fi
}

multilib_src_install_all() {
	if use autoipd; then
		insinto /$(get_libdir)/rcscripts/net
		doins "${FILESDIR}"/autoipd.sh

		insinto /$(get_libdir)/rc/net
		newins "${FILESDIR}"/autoipd-openrc.sh autoipd.sh
	fi

	dodoc docs/{AUTHORS,NEWS,README,TODO}

	prune_libtool_files --all
}

pkg_postinst() {
	if use autoipd; then
		elog
		elog "To use avahi-autoipd to configure your interfaces with IPv4LL (RFC3927)"
		elog "addresses, just set config_<interface>=( autoipd ) in /etc/conf.d/net!"
		elog
	fi
}
