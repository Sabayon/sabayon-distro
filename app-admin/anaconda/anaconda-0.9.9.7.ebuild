# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

if [ "${PV}" = "9999" ]; then
	EGIT_COMMIT="master"
	EGIT_REPO_URI="git://sabayon.org/projects/anaconda.git"
	MY_ECLASS="git"
fi
inherit flag-o-matic base python libtool autotools eutils ${MY_ECLASS}

AUDIT_VER="1.7.9"
AUDIT_SRC_URI="http://people.redhat.com/sgrubb/audit/audit-${AUDIT_VER}.tar.gz"
DESCRIPTION="Sabayon Redhat Anaconda Installer Port"
HOMEPAGE="http://gitweb.sabayon.org/?p=anaconda.git;a=summary"
if [ "${PV}" = "9999" ]; then
	SRC_URI="${AUDIT_SRC_URI}"
	KEYWORDS=""
else
	SRC_URI="http://distfiles.sabayon.org/${CATEGORY}/${PN}-${PVR}.tar.bz2 ${AUDIT_SRC_URI}"
	KEYWORDS="~amd64 ~x86"
fi
S="${WORKDIR}"/${PN}-${PVR}
AUDIT_S="${WORKDIR}/audit-${AUDIT_VER}"

LICENSE="GPL-2"
SLOT="0"
IUSE="+ipv6 +nfs selinux ldap"

AUDIT_DEPEND="dev-lang/swig"
AUDIT_RDEPEND="ldap? ( net-nds/openldap )"
COMMON_DEPEND="app-admin/system-config-keyboard
	>=app-arch/libarchive-2.8
	app-cdr/isomd5sum
	dev-libs/newt
	nfs? ( net-fs/nfs-utils )
	selinux? ( sys-libs/libselinux )
	sys-fs/lvm2
	=sys-block/open-iscsi-2.0.870.3-r1"
DEPEND="${COMMON_DEPEND} ${AUDIT_DEPEND}"
RDEPEND="${COMMON_DEPEND} ${AUDIT_RDEPEND}
	>=app-misc/anaconda-runtime-1"
# FIXME:
# for anaconda-gtk we would require also
#   dev-python/pygtk
#   x11-libs/pango

src_unpack() {
	if [ "${PV}" = "9999" ]; then
		git_src_unpack
		base_src_unpack
	else
		base_src_unpack
	fi
}

src_prepare() {

	# Setup CFLAGS, LDFLAGS
	append-cflags "-I${D}/usr/include/anaconda-runtime"
	append-ldflags "-L${D}/usr/$(get_libdir)/anaconda-runtime -R/usr/$(get_libdir)/anaconda-runtime"

	# Setup anaconda
	cd "${S}"
	./autogen.sh || die "cannot run autogen"

	##
	## Setup audit stuff
	##
	cd "${AUDIT_S}"
        # Do not build GUI tools
        sed -i \
                -e '/AC_CONFIG_SUBDIRS.*system-config-audit/d' \
                "${AUDIT_S}"/configure.ac
        sed -i \
                -e 's,system-config-audit,,g' \
                -e '/^SUBDIRS/s,\\$,,g' \
                "${AUDIT_S}"/Makefile.am
        rm -rf "${AUDIT_S}"/system-config-audit

        if ! use ldap; then
                sed -i \
                        -e '/^AC_OUTPUT/s,audisp/plugins/zos-remote/Makefile,,g' \
                        "${AUDIT_S}"/configure.ac
                sed -i \
                        -e '/^SUBDIRS/s,zos-remote,,g' \
                        "${AUDIT_S}"/audisp/plugins/Makefile.am
        fi
	eautoreconf

}

copy_audit_data_over() {
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

	# Compiling audit here, anaconda configure needs libaudit
	einfo "compiling audit"
	cd "${AUDIT_S}"
	base_src_compile

	# Installing audit
	einfo "installing audit libs into /usr/$(get_libdir)/anaconda-runtime"
	cd "${AUDIT_S}"
	mkdir fakeroot
	emake DESTDIR="${AUDIT_S}/fakeroot" install
	copy_audit_data_over # for proper linking

	# configure anaconda
	cd "${S}"
	einfo "configuring anaconda"
	econf \
		$(use_enable ipv6) $(use_enable selinux) \
		$(use_enable nfs) || die "configure failed"
}

src_install() {

	cd "${S}"
	copy_audit_data_over # ${D} is cleared
	base_src_install

	# install liveinst for user
	dodir /usr/bin
	exeinto /usr/bin
	doexe "${FILESDIR}"/liveinst
	dosym /usr/bin/liveinst /usr/bin/installer
}

pkg_postrm() {
	python_mod_cleanup $(python_get_sitedir)/py${PN}
}

pkg_postinst() {
	python_mod_optimize $(python_get_sitedir)/py${PN}
}
