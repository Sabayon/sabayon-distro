# Copyright 2004-2014 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit base flag-o-matic python-r1 libtool autotools eutils

AUDIT_VER="2.1.3"
AUDIT_SRC_URI="http://people.redhat.com/sgrubb/audit/audit-${AUDIT_VER}.tar.gz"

SEPOL_VER="2.3"
LSELINUX_VER="2.2.2"
LSELINUX_SRC_URI="https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/files/releases/20131030/libselinux-${LSELINUX_VER}.tar.gz"

DESCRIPTION="Sabayon Redhat Anaconda Installer Port"
HOMEPAGE="https://github.com/Sabayon/anaconda"

SRC_URI="mirror://sabayon/${CATEGORY}/${PN}-${PV}.tar.bz2 ${AUDIT_SRC_URI} ${LSELINUX_SRC_URI}"
KEYWORDS="~amd64 ~x86"

AUDIT_S="${WORKDIR}/audit-${AUDIT_VER}"
LSELINUX_S="${WORKDIR}/libselinux-${LSELINUX_VER}"

LICENSE="GPL-2 public-domain"
SLOT="0"
IUSE="gtk-dep +ipv6 +nfs ldap selinux"
RESTRICT="nomirror"

AUDIT_DEPEND="dev-lang/swig"
AUDIT_RDEPEND="ldap? ( net-nds/openldap )"
LSELINUX_DEPEND="=sys-libs/libsepol-${SEPOL_VER}* >=dev-lang/swig-2.0.9"
LSELINUX_RDEPEND="=sys-libs/libsepol-${SEPOL_VER}*"

COMMON_DEPEND="
	>=app-arch/libarchive-3.0.4
	dev-python/dbus-python
	dev-python/nose
	dev-python/pygobject-base
	dev-util/intltool
	gnome-base/libgnomekbd
	>=net-misc/networkmanager-0.9.8.0
	>=sys-apps/dbus-1.2.3
	sys-apps/systemd
	>=sys-apps/util-linux-2.15.1
	>=sys-block/parted-1.8.1
	sys-devel/gettext
	x11-libs/libxklavier
	x11-libs/pango
	virtual/pkgconfig
	"
DEPEND="${COMMON_DEPEND} ${AUDIT_DEPEND} ${LSELINUX_DEPEND}
	app-arch/rpm
	dev-util/gtk-doc
	dev-util/gtk-doc-am
	sys-apps/sed"
RDEPEND="${COMMON_DEPEND} ${AUDIT_RDEPEND}
	${LSELINUX_RDEPEND}
	app-admin/authconfig
	app-admin/sudo
	app-cdr/isomd5sum
	app-emulation/spice-vdagent
	app-i18n/langtable
	dev-libs/gobject-introspection
	>=dev-libs/keybinder-0.3.0-r300
	dev-libs/libpwquality[python]
	>=dev-libs/libreport-2.0.20
	dev-python/ipy
	>=dev-python/pyparted-2.5
	=dev-python/python-blivet-0.23*
	dev-python/python-bugzilla
	>=dev-python/python-meh-0.30-r1
	dev-python/python-nss
	dev-python/python-ntplib
	dev-python/pytz
	>=dev-python/urlgrabber-3.9.1
	dev-util/desktop-file-utils
	gnome-base/libglade
	gnome-base/libgnomekbd
	>=dev-util/pykickstart-1.99.52
	gnome-extra/zenity
	net-firewall/firewalld
	net-misc/chrony
	net-misc/dhcp
	net-misc/fcoe-utils
	>=net-misc/libteam-1.10
	net-misc/tightvnc
	sys-apps/dmidecode
	sys-apps/kbd
	sys-auth/realmd
	sys-block/open-iscsi
	sys-libs/libuser
	x11-themes/gnome-icon-theme
	x11-themes/gnome-icon-theme-symbolic
	x11-themes/gnome-themes-standard
	gtk-dep? ( x11-libs/gtk+:3 )"

src_prepare() {
	# Setup CFLAGS, LDFLAGS
	append-cppflags "-I${D}/usr/include/anaconda-runtime"
	append-ldflags "-L${D}/usr/$(get_libdir)/anaconda-runtime"

	# Upstreamed patches
	epatch "${FILESDIR}/0001-bootloader-fix-UEFI-install.patch"

	##
	## Setup libaudit
	##
	cd "${AUDIT_S}"
        # Do not build GUI tools
        sed -i \
                -e '/AC_CONFIG_SUBDIRS.*system-config-audit/d' \
                "${AUDIT_S}"/configure.ac || die "cannot sed libaudit configure.ac"
        sed -i \
                -e 's,system-config-audit,,g' \
                -e '/^SUBDIRS/s,\\$,,g' \
                "${AUDIT_S}"/Makefile.am || die "cannot sed libaudit Makefile.am"
        rm -rf "${AUDIT_S}"/system-config-audit

        if ! use ldap; then
                sed -i \
                        -e '/^AC_OUTPUT/s,audisp/plugins/zos-remote/Makefile,,g' \
                        "${AUDIT_S}"/configure.ac || die "cannot sed libaudit configure.ac (ldap)"
                sed -i \
                        -e '/^SUBDIRS/s,zos-remote,,g' \
                        "${AUDIT_S}"/audisp/plugins/Makefile.am || die "cannot sed libaudit Makefile.am (ldap)"
        fi
	eautoreconf

	##
	## Setup libselinux
	##
	cd "${LSELINUX_S}" || die
	epatch "${FILESDIR}/0006-build-related-fixes-bug-500674.patch"
}

_copy_audit_data_over() {
	dodir "/usr/$(get_libdir)/anaconda-runtime"
	cp -Ra "${AUDIT_S}/fakeroot/usr/$(get_libdir)/anaconda-runtime/"* \
		"${D}/usr/$(get_libdir)/anaconda-runtime" || die "cannot cp audit data"
	dodir "/usr/include/anaconda-runtime"
	cp -Ra "${AUDIT_S}/fakeroot/usr/include/anaconda-runtime/"* \
		"${D}/usr/include/anaconda-runtime" || die "cannot cp audit include data"
}

src_configure() {
	# configure audit
	cd "${AUDIT_S}"
	einfo "configuring audit"
	econf --sbindir=/sbin --libdir=/usr/$(get_libdir)/anaconda-runtime \
		--includedir=/usr/include/anaconda-runtime \
		--without-prelude || die

	# compiling audit here, anaconda configure needs libaudit
	einfo "compiling audit"
	cd "${AUDIT_S}" || die "cannot cd into ${AUDIT_S}"
	base_src_compile

	# installing audit
	einfo "installing audit libs into ${AUDIT_S}/fakeroot temporarily"
	cd "${AUDIT_S}" || die "cannot cd into ${AUDIT_S}"
	( rm -rf fakeroot && mkdir fakeroot ) || die "cannot mkdir"
	emake DESTDIR="${AUDIT_S}/fakeroot" install || die "cannot install libaudit"
	_copy_audit_data_over # for proper linking

	# configure anaconda
	cd "${S}" || die
	einfo "configuring anaconda"
	econf --disable-static --enable-introspection \
		$(use_enable ipv6) $(use_enable selinux) \
		$(use_enable nfs) || die "configure failed"
}

src_compile() {
	cd "${S}" || die

	base_src_compile

	tc-export PKG_CONFIG RANLIB
	local PCRE_CFLAGS=$(${PKG_CONFIG} libpcre --cflags)
	local PCRE_LIBS=$(${PKG_CONFIG} libpcre --libs)
	export PCRE_{CFLAGS,LIBS}

	# compiling libselinux
	einfo "compiling libselinux"
	cd "${LSELINUX_S}" || die "cannot cd into ${LSELINUX_S}"

	LD_RUN_PATH="/usr/$(get_libdir)/anaconda-runtime" \
	emake \
		AR="$(tc-getAR)" \
		CC="$(tc-getCC)" \
		LDFLAGS="-fPIC ${LDFLAGS} -pthread" \
		LIBDIR="\$(PREFIX)/$(get_libdir)/anaconda-runtime" \
		SHLIBDIR="\$(DESTDIR)/usr/$(get_libdir)/anaconda-runtime" \
		INCDIR="\$(DESTDIR)/include/anaconda-runtime" \
		all

	building() {
		python_export PYTHON_INCLUDEDIR PYTHON_LIBPATH

		LD_RUN_PATH="/usr/$(get_libdir)/anaconda-runtime" \
		emake \
			CC="$(tc-getCC)" \
			PYINC="-I${PYTHON_INCLUDEDIR}" \
			PYPREFIX="${EPYTHON##*/}" \
			LDFLAGS="-fPIC ${LDFLAGS} -lpthread" \
		pywrap
	}
	python_foreach_impl building
}

src_install() {
	# installing libselinux
	cd "${LSELINUX_S}" || die

	LD_RUN_PATH="/usr/$(get_libdir)/anaconda-runtime" \
	emake DESTDIR="${D}" \
		LIBDIR="\$(PREFIX)/$(get_libdir)/anaconda-runtime" \
		SHLIBDIR="\$(DESTDIR)/usr/$(get_libdir)/anaconda-runtime" \
		INCDIR="\$(DESTDIR)/include/anaconda-runtime" \
		install || die

	installation() {
		LD_RUN_PATH="/usr/$(get_libdir)/anaconda-runtime" \
		LIBDIR="\$(PREFIX)/$(get_libdir)" \
			emake DESTDIR="${D}" install-pywrap
	}
	python_foreach_impl installation

	# fix libselinux.so link
	dosym libselinux.so.1 /usr/$(get_libdir)/anaconda-runtime/libselinux.so

	# anaconda expects to find auditd in /sbin
	dosym ../usr/libexec/anaconda/auditd /sbin/auditd

	# install liveinst for user
	dodir /usr/bin
	exeinto /usr/bin
	doexe "${FILESDIR}"/liveinst
	dosym liveinst /usr/bin/installer

	cd "${S}" || die
	_copy_audit_data_over # ${D} is cleared
	base_src_install

	# Drop any static library
	rm "${D}"/usr/lib*/anaconda-runtime/*.a
	# drop .la files for God sake
	find "${D}" -name "*.la" -delete

	# Cleanup .pyc .pyo
	find "${D}" -name "*.py[co]" -type f -delete

	# Fix analog collision
	mv "${D}"/usr/bin/{analog,anaconda-analog} || die
}
