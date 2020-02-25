# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

AVAHI_MODULE="${AVAHI_MODULE:-${PN/avahi-}}"
MY_P=${P/-${AVAHI_MODULE}}
MY_PN=${PN/-${AVAHI_MODULE}}

inherit autotools eutils flag-o-matic systemd

DESCRIPTION="System which facilitates service discovery on a local network (gtk pkg)"
HOMEPAGE="http://avahi.org/"
SRC_URI="https://github.com/lathiat/avahi/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
IUSE="dbus gdbm nls"

S="${WORKDIR}/${MY_P}"

COMMON_DEPEND="
	~net-dns/avahi-base-${PV}[dbus=,gdbm=,nls=]
	x11-libs/gtk+:2
"

DEPEND="${COMMON_DEPEND}
	dev-util/glib-utils"
RDEPEND="${COMMON_DEPEND}"
PATCHES=(
	"${FILESDIR}/${MY_P}-qt5.patch"
	"${FILESDIR}/${MY_P}-CVE-2017-6519.patch"
	"${FILESDIR}/${MY_P}-remove-empty-avahi_discover.patch"
	"${FILESDIR}/${MY_P}-python3.patch"
	"${FILESDIR}/${MY_P}-python3-unittest.patch"
	"${FILESDIR}/${MY_P}-python3-gdbm.patch"
)

src_prepare() {
	default

	# Prevent .pyc files in DESTDIR
	>py-compile

	eautoreconf
}

src_configure() {
	# those steps should be done once-per-ebuild rather than per-ABI
	use sh && replace-flags -O? -O0

	local myconf=(
		--disable-static
		--localstatedir="${EPREFIX}/var" \
		--with-distro=gentoo \
		--disable-python-dbus \
		--disable-manpages \
		--disable-xmltoman \
		--disable-mono \
		--disable-monodoc \
		--enable-glib \
		--enable-gobject \
		$(use_enable dbus) \
		--disable-python \
		$(use_enable nls) \
		--disable-introspection \
		--disable-qt3 \
		--disable-qt4 \
		--disable-qt5
		--enable-gtk \
		--disable-gtk3 \
		$(use_enable gdbm) \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
	)

	econf "${myconf[@]}"
}

src_compile() {
	for target in avahi-common avahi-client avahi-glib avahi-ui; do
		emake -C "${target}" || die
	done
	emake avahi-ui.pc || die
}

src_install() {
	mkdir -p "${D}/usr/bin" || die

	emake -C avahi-ui DESTDIR="${D}" install || die
	dodir /usr/$(get_libdir)/pkgconfig
	insinto /usr/$(get_libdir)/pkgconfig
	doins avahi-ui.pc

	# Workaround for avahi-ui.h collision between avahi-gtk and avahi-gtk3
	root_avahi_ui="${ROOT}/usr/include/avahi-ui/avahi-ui.h"
	if [ -e "${root_avahi_ui}" ]; then
		rm -rf "${D}/usr/include/"
	fi

	# provided by avahi-gtk3
	rm "${D}"/usr/bin/bshell || die
	rm "${D}"/usr/bin/bssh || die
	rm "${D}"/usr/bin/bvnc || die
	rm -rf "${D}"/usr/bin/ || die
	rm "${D}"/usr/share/applications/bssh.desktop || die
	rm "${D}"/usr/share/applications/bvnc.desktop || die
	rm -rf "${D}"/usr/share/ || die

	find "${ED}" -name '*.la' -type f -delete || die
}
