# Copyright 1999-2014 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

AVAHI_MODULE="${AVAHI_MODULE:-${PN/avahi-}}"
MY_P=${P/-${AVAHI_MODULE}}
MY_PN=${PN/-${AVAHI_MODULE}}

PYTHON_COMPAT=( python{2_6,2_7} )
PYTHON_REQ_USE="gdbm"

WANT_AUTOMAKE=1.11

inherit autotools eutils flag-o-matic multilib multilib-minimal \
	python-r1 systemd user

DESCRIPTION="System which facilitates service discovery on a local network (gtk pkg)"
HOMEPAGE="http://avahi.org/"
SRC_URI="http://avahi.org/download/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
IUSE="dbus gdbm introspection nls python utils"

S="${WORKDIR}/${MY_P}"

COMMON_DEPEND="
	~net-dns/avahi-base-${PV}[dbus=,gdbm=,introspection=,nls=,python=,${MULTILIB_USEDEP}]
	x11-libs/gtk+:2
	python? ( dev-python/pygtk )
"

DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

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
			--enable-pygtk
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
		--disable-qt4 \
		$(multilib_is_native_abi && echo -n --enable-gtk || echo -n --disable-gtk) \
		$(multilib_is_native_abi && echo -n --enable-gtk-utils || echo -n --disable-gtk-utils) \
		--disable-gtk3 \
		$(use_enable gdbm) \
		$(systemd_with_unitdir) \
		"${myconf[@]}"
}

multilib_src_compile() {
	if multilib_is_native_abi; then
		for target in avahi-common avahi-client avahi-glib avahi-ui; do
			cd "${BUILD_DIR}"/${target} || die
			emake || die
		done
		cd "${BUILD_DIR}" || die
		emake avahi-ui.pc || die
	fi
}

multilib_src_install() {
	mkdir -p "${D}/usr/bin" || die

	if multilib_is_native_abi; then
		cd "${BUILD_DIR}"/avahi-ui || die
		emake DESTDIR="${D}" install || die
		if use python; then
			cd "${BUILD_DIR}"/avahi-python/avahi-discover || die
			emake install DESTDIR="${D}" || die
		fi
		cd "${BUILD_DIR}" || die
		dodir /usr/$(get_libdir)/pkgconfig
		insinto /usr/$(get_libdir)/pkgconfig
		doins avahi-ui.pc

		# Workaround for avahi-ui.h collision between avahi-gtk and avahi-gtk3
		root_avahi_ui="${ROOT}usr/include/avahi-ui/avahi-ui.h"
		if [ -e "${root_avahi_ui}" ]; then
			rm -f "${D}usr/include/avahi-ui/avahi-ui.h"
		fi

		# provided by avahi-gtk3
		rm "${D}"usr/bin/bshell || die
		rm "${D}"usr/bin/bssh || die
		rm "${D}"usr/bin/bvnc || die
		rm "${D}"usr/share/applications/bssh.desktop || die
		rm "${D}"usr/share/applications/bvnc.desktop || die
	fi
}

multilib_src_install_all() {
	prune_libtool_files --all
}
