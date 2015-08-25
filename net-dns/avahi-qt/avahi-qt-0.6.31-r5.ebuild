# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

AVAHI_MODULE="${AVAHI_MODULE:-${PN/avahi-}}"
MY_P=${P/-${AVAHI_MODULE}}
MY_PN=${PN/-${AVAHI_MODULE}}

WANT_AUTOMAKE=1.11

PYTHON_COMPAT=( python{2_6,2_7} )
PYTHON_REQ_USE="gdbm"

inherit autotools eutils flag-o-matic multilib multilib-minimal \
	python-r1 systemd user

DESCRIPTION="System which facilitates service discovery on a local network (qt4 pkg)"
HOMEPAGE="http://avahi.org/"
SRC_URI="http://avahi.org/download/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
IUSE="dbus gdbm introspection nls python utils"

S="${WORKDIR}/${MY_P}"

COMMON_DEPEND="
	~net-dns/avahi-base-${PV}[dbus=,gdbm=,introspection=,nls=,python=,${MULTILIB_USEDEP}]
	dev-qt/qtcore:4
"

DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

MULTILIB_WRAPPED_HEADERS=(
	# necessary until the UI libraries are ported
	/usr/include/avahi-qt4/qt-watch.h
)

src_prepare() {
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

	# We need to unset DISPLAY, else the configure script might have problems detecting the pygtk module
	unset DISPLAY

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myconf=( --disable-static )

	if ! multilib_is_native_abi; then
		myconf+=(
			# used by daemons only
			--disable-libdaemon
			--with-xml=none
		)
	fi

	if use python; then
		myconf+=(
			$(multilib_native_use_enable dbus python-dbus)
		)
	fi

	econf \
		--localstatedir="${EPREFIX}/var" \
		--with-distro=gentoo \
		--disable-python-dbus \
		--disable-xmltoman \
		--disable-monodoc \
		--disable-pygtk \
		--enable-glib \
		--enable-gobject \
		$(use_enable dbus) \
		$(multilib_native_use_enable python) \
		$(use_enable nls) \
		$(multilib_native_use_enable introspection) \
		--disable-qt3 \
		--disable-gtk3 \
		--disable-gtk --disable-gtk-utils \
		$(multilib_is_native_abi && echo -n --enable-qt4 || echo -n --disable-qt4) \
		$(use_enable gdbm) \
		$(systemd_with_unitdir) \
		"${myconf[@]}"
}

multilib_src_compile() {
	if multilib_is_native_abi; then
		cd "${BUILD_DIR}"/avahi-common || die
		emake || die
		cd "${BUILD_DIR}"/avahi-qt || die
		emake || die
		cd "${BUILD_DIR}" || die
		emake avahi-qt4.pc || die
	fi
}

multilib_src_install() {
	if multilib_is_native_abi; then
		mkdir -p "${D}/usr/bin" || die

		cd "${BUILD_DIR}"/avahi-qt || die
		emake install DESTDIR="${D}" || die

		cd "${BUILD_DIR}" || die
		dodir /usr/$(get_libdir)/pkgconfig
		insinto /usr/$(get_libdir)/pkgconfig
		doins avahi-qt4.pc
	fi
}

multilib_src_install_all() {
	prune_libtool_files --all
}
