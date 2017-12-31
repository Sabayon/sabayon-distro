# Copyright 2004-2017 Sabayon
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit flag-o-matic python-r1 libtool autotools eutils

SEPOL_VER="2.6"
AUDIT_VER="2.6"

DESCRIPTION="Sabayon Redhat Anaconda Installer Port"
HOMEPAGE="https://github.com/Sabayon/anaconda"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Sabayon/anaconda.git"
	EGIT_BRANCH="future"
	KEYWORDS=""
else
	KEYWORDS="amd64"
	SRC_URI="mirror://sabayon/${CATEGORY}/${PN}-${PV}.tar.bz2 ${SRC_URI}"
fi

LICENSE="GPL-2 public-domain"
SLOT="0"
IUSE="gtk +ipv6 +nfs ldap selinux"
RESTRICT="mirror"

AUDIT_DEPEND="dev-lang/swig
	      =sys-process/audit-${AUDIT_VER}*"
AUDIT_RDEPEND="ldap? ( net-nds/openldap )"
LSELINUX_DEPEND="=sys-libs/libsepol-${SEPOL_VER}*
		 =sys-libs/libselinux-${SEPOL_VER}*
		 =sys-libs/libsemanage-${SEPOL_VER}*
		 >=dev-lang/swig-2.0.9
		 =sys-apps/policycoreutils-${SEPOL_VER}*"
LSELINUX_RDEPEND="=sys-libs/libsepol-${SEPOL_VER}*
		  =sys-libs/libselinux-${SEPOL_VER}*
		  =sys-libs/libsemanage-${SEPOL_VER}*
		  =sys-apps/policycoreutils-${SEPOL_VER}*"

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
	>=x11-libs/libxklavier-5.4
	x11-libs/pango
	virtual/pkgconfig
	"
DEPEND="${COMMON_DEPEND} ${AUDIT_DEPEND} ${LSELINUX_DEPEND}
	app-arch/rpm
	>=dev-util/glade-3.10
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
	dev-libs/libtimezonemap
	dev-libs/newt
	dev-python/ipy
	>=dev-python/pyparted-2.5
	=dev-python/python-blivet-1.0*
	dev-python/python-bugzilla
	>=dev-python/python-meh-0.30-r1
	dev-python/python-nss
	dev-python/ntplib
	dev-python/pytz
	dev-python/requests
	>=dev-python/urlgrabber-3.9.1
	dev-util/desktop-file-utils
	gnome-base/libglade
	gnome-base/libgnomekbd
	>=dev-util/pykickstart-1.99.66
	gnome-extra/zenity
	net-firewall/firewalld
	net-misc/chrony
	net-misc/dhcp
	net-misc/fcoe-utils
	>=net-misc/libteam-1.10
	net-misc/tightvnc
	sys-apps/dmidecode
	sys-apps/kbd
	sys-apps/usermode
	sys-auth/realmd
	sys-block/open-iscsi
	sys-boot/os-prober
	sys-libs/libuser
	x11-themes/gnome-icon-theme
	x11-themes/gnome-icon-theme-symbolic
	x11-themes/gnome-themes-standard
	gtk? ( x11-libs/gtk+:3 )"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	fi
	default
}

src_prepare() {
	default
	epatch "${FILESDIR}"/0018-remove-libsepol-libsemanage-policycoreutils.patch
	epatch "${FILESDIR}"/0019-add-some-other-packages-to-the-delete-list.patch
	# Setup CFLAGS, LDFLAGS
	append-cppflags "-I${D}/usr/include/anaconda-runtime"
	append-ldflags "-L${D}/usr/$(get_libdir)/anaconda-runtime"
	eautoreconf
}

src_configure() {
	einfo "configuring anaconda"
	if [[ ${PV} == 9999 ]]; then
		rm po/LINGUAS || die
		./autogen.sh || die
	fi
	econf --disable-static --enable-introspection \
		$(use_enable ipv6) $(use_enable selinux) \
		$(use_enable nfs) || die "configure failed"
}

src_compile() {
	default

	tc-export PKG_CONFIG RANLIB
	local PCRE_CFLAGS=$(${PKG_CONFIG} libpcre --cflags)
	local PCRE_LIBS=$(${PKG_CONFIG} libpcre --libs)
	export PCRE_{CFLAGS,LIBS}
}

src_install() {
	default
	# install liveinst for user
	dodir /usr/bin
	# Use our own liveinst.
	rm "${D}/usr/bin/liveinst" || die
	exeinto /usr/bin
	doexe "${FILESDIR}"/liveinst
	# /usr/bin/installer is currently taken by calamares
	dosym liveinst /usr/bin/anaconda-installer

	# Drop any static library
	rm "${D}"/usr/lib*/anaconda-runtime/*.a
	# drop .la files for God sake
	find "${D}" -name "*.la" -delete

	# Cleanup .pyc .pyo
	find "${D}" -name "*.py[co]" -type f -delete

	# Fix analog collision
	mv "${D}"/usr/bin/{analog,anaconda-analog} || die
}
