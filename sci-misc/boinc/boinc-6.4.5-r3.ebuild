# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-misc/boinc/boinc-6.4.5-r2.ebuild,v 1.3 2009/05/29 16:42:45 scarabeus Exp $

#
# Don't forget to keep things in sync with binary boinc package!
#

EAPI="2"

inherit flag-o-matic depend.apache eutils wxwidgets

DESCRIPTION="The Berkeley Open Infrastructure for Network Computing"
HOMEPAGE="http://boinc.ssl.berkeley.edu/"
SRC_URI="http://dev.gentooexperimental.org/~scarabeus/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="X cuda server"

RDEPEND="
	!sci-misc/boinc-bin
	!app-admin/quickswitch
	>=app-misc/ca-certificates-20080809
	dev-libs/openssl
	net-misc/curl
	sys-apps/util-linux
	sys-libs/zlib
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-2.1
		>=x11-drivers/nvidia-drivers-180.22
	)
	server? (
		>=virtual/mysql-5.0
		dev-python/mysql-python
	)
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	server? ( virtual/imap-c-client )
	X? (
		media-libs/freeglut
		media-libs/jpeg
		x11-libs/wxGTK:2.8[X,opengl]
	)
"

src_prepare() {
	# use system ssl certificates
	mkdir "${S}"/curl
	cp /etc/ssl/certs/ca-certificates.crt "${S}"/curl/ca-bundle.crt
	# copy icons to correct location
	cp "${S}"/sea/*.png "${S}"/clientgui/res/
	# RSA Security bug fix. Per bug #258011
	# GCC 4.4 Compilation issue. Per bug #269618
	# Fix stripping. Per bug #257297
	epatch \
		"${FILESDIR}"/${PV}-RSA_security.patch \
		"${FILESDIR}"/${PV}-gcc44.patch \
		"${FILESDIR}"/${PV}-glibc210.patch \
		"${FILESDIR}"/${PV}-nostrip.patch
}

src_configure() {
	local wxconf=""
	local config=""

	# define preferable CFLAGS (recommended by upstream)
	append-flags -O3 -funroll-loops -fforce-addr -ffast-math

	# look for wxGTK
	if use X; then
		WX_GTK_VER="2.8"
		need-wxwidgets unicode
		wxconf="${wxconf} --with-wx-config=${WX_CONFIG}"
	else
		wxconf="${wxconf} --without-wxdir"
	fi

	# nonstandard enable
	use server || config="--disable-server"

	# Bug #248769: don't use strlcat and friends from kerberos or similar
	local func
	for func in strlcat strlcpy; do
		eval "export ac_cv_func_${func}=no"
		append-cppflags -D${func}=boinc_${func}
	done

	# configure
	econf \
		--disable-dependency-tracking \
		--with-gnu-ld \
		--enable-unicode \
		--enable-client \
		--with-ssl \
		${wxconf} \
		${config} \
		$(use_with X x)

	# Fix LDFLAGS. Link to compiled stuff and not to installed one
	sed -i \
		-e "s|LDFLAGS = |LDFLAGS = -L../lib |g" \
		*/Makefile || die "sed failed"
}

src_compile() {
	# disable parallel build.
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodir /var/lib/${PN}/
	keepdir /var/lib/${PN}/

	if use X; then
		newicon "${S}"/sea/${PN}mgr.48x48.png ${PN}.png
		make_desktop_entry boinc_gui "${PN}" "${PN}" "Math;Science" /var/lib/${PN}
	fi

	# cleanup cruft
	rm "${D}"/usr/bin/ca-bundle.crt
	rm -rf "${D}"/etc/

	newinitd "${FILESDIR}"/${PN}.init ${PN}
	newconfd "${FILESDIR}"/${PN}.conf ${PN}
}

pkg_setup() {
	enewgroup ${PN}
	# note this works only for first install so we have to
	# elog user about the need of being in video group
	if use cuda; then
		enewuser ${PN} -1 -1 /var/lib/${PN} "${PN},video"
	else
		enewuser ${PN} -1 -1 /var/lib/${PN} "${PN}"
	fi
}

pkg_postinst() {
	echo
	elog "You are using the source compiled version."
	elog "The manager can be found at /usr/bin/${PN}_gui"
	elog
	elog "You need to attach to a project to do anything useful with ${PN}."
	elog "You can do this by running /etc/init.d/${PN} attach"
	elog "The howto for configuration is located at:"
	elog "http://boinc.berkeley.edu/wiki/Anonymous_platform"
	elog
	# Add warning about the new password for the client, bug 121896.
	elog "If you need to use the graphical client the password is in:"
	elog "/var/lib/${PN}/gui_rpc_auth.cfg"
	elog "Where /var/lib/ is default RUNTIMEDIR, that can be changed in:"
	elog "/etc/conf.d/${PN}"
	elog "You should change this to something more memorable (can be even blank)."
	elog
	elog "Remember to launch init script before using manager. Or changing the password."
	if use cuda; then
		elog "To be able to use CUDA you should add boinc user to video group."
		elog "To do so run as root:"
		elog "gpasswd -a boinc video"
	fi
}
