# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite,xml"
inherit eutils flag-o-matic python-single-r1 toolchain-funcs

MY_P=${P/_beta/BETA}

DESCRIPTION="A utility for network discovery and security auditing"
HOMEPAGE="http://nmap.org/"
SRC_URI="
	http://nmap.org/dist/${MY_P}.tar.bz2
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE="ipv6 libressl +nse system-lua ncat ndiff nls nmap-update nping ssl zenmap"
# not used in split nmap ebuild, but retained for compatibility with Portage
NMAP_LINGUAS=( de fr hi hr it ja pl pt_BR ru zh )
IUSE+=" ${NMAP_LINGUAS[@]/#/linguas_}"

REQUIRED_USE="
	system-lua? ( nse )
	ndiff? ( ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	dev-libs/liblinear:=
	dev-libs/libpcre
	|| ( >=net-libs/libpcap-1.8.0 <net-libs/libpcap-1.8.0[ipv6?] )
	system-lua? ( >=dev-lang/lua-5.2[deprecated] )
	ndiff? ( ${PYTHON_DEPS} )
	nmap-update? ( dev-libs/apr dev-vcs/subversion )
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
"
DEPEND="
	${RDEPEND}
"

PDEPEND="zenmap? ( ~net-analyzer/zenmap-${PV} )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use ndiff || use zenmap; then
		python-single-r1_pkg_setup
	fi
}

src_unpack() {
	# prevent unpacking the logo
	unpack ${MY_P}.tar.bz2
}

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-4.75-nolua.patch \
		"${FILESDIR}"/${PN}-5.10_beta1-string.patch \
		"${FILESDIR}"/${PN}-5.21-python.patch \
		"${FILESDIR}"/${PN}-6.46-uninstaller.patch \
		"${FILESDIR}"/${PN}-6.47-no-libnl.patch \
		"${FILESDIR}"/${PN}-6.49-no-FORTIFY_SOURCE.patch \
		"${FILESDIR}"/${PN}-6.25-liblua-ar.patch

	if false && use nls; then # skipped in split nmap ebuild
		local lingua=''
		for lingua in ${NMAP_LINGUAS[@]}; do
			if ! use linguas_${lingua}; then
				rm -r zenmap/share/zenmap/locale/${lingua} || die
				rm zenmap/share/zenmap/locale/${lingua}.po || die
			fi
		done
	else
		# configure/make ignores --disable-nls
		for lingua in ${NMAP_LINGUAS[@]}; do
			rm -r zenmap/share/zenmap/locale/${lingua} || die
			rm zenmap/share/zenmap/locale/${lingua}.po || die
		done
	fi

	sed -i \
		-e '/^ALL_LINGUAS =/{s|$| id|g;s|jp|ja|g}' \
		Makefile.in || die

	sed -i \
		-e '/rm -f $@/d' \
		$(find . -name Makefile.in) \
		|| die

	# Fix desktop files wrt bug #432714
	# not needed in Sabayon's split nmap ebuild
	#sed -i \
	#	-e '/^Encoding/d' \
	#	-e 's|^Categories=.*|Categories=Network;System;Security;|g' \
	#	zenmap/install_scripts/unix/zenmap-root.desktop \
	#	zenmap/install_scripts/unix/zenmap.desktop || die

	epatch_user
}

src_configure() {
	# The bundled libdnet is incompatible with the version available in the
	# tree, so we cannot use the system library here.
	econf \
		$(use_enable ipv6) \
		$(use_enable nls) \
		--without-zenmap \
		$(usex nse --with-liblua=$(usex system-lua /usr included '' '') --without-liblua) \
		$(use_with ncat) \
		$(use_with ndiff) \
		$(use_with nmap-update) \
		$(use_with nping) \
		$(use_with ssl openssl) \
		--with-libdnet=included \
		--with-pcre=/usr
	#	--with-liblinear=/usr \
	#	Commented because configure does weird things, while autodetection works
}

src_compile() {
	local directory
	for directory in . libnetutil nsock/src \
		$(usex ncat ncat '') \
		$(usex nmap-update nmap-update '') \
		$(usex nping nping '')
	do
		emake -C "${directory}" makefile.dep
	done

	emake \
		AR=$(tc-getAR) \
		RANLIB=$(tc-getRANLIB)
}

src_install() {
	LC_ALL=C emake -j1 \
		DESTDIR="${D}" \
		STRIP=: \
		nmapdatadir="${EPREFIX}"/usr/share/nmap \
		install
	if use nmap-update;then
		LC_ALL=C emake -j1 \
			-C nmap-update \
			DESTDIR="${D}" \
			STRIP=: \
			nmapdatadir="${EPREFIX}"/usr/share/nmap \
			install
	fi

	dodoc CHANGELOG HACKING docs/README docs/*.txt

	#if use zenmap; then
	#	doicon "${DISTDIR}/nmap-logo-64.png"
	#	python_optimize
	#fi
}
