# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite,xml"
inherit flag-o-matic python-single-r1 toolchain-funcs

MY_P=${P/_beta/BETA}
NM_PN=${PN/zenmap/nmap}
NM_P=${MY_P/zenmap/nmap}

DESCRIPTION="Graphical frontend for nmap"
HOMEPAGE="http://nmap.org/"
SRC_URI="
	http://nmap.org/dist/${NM_P}.tar.bz2
	https://dev.gentoo.org/~jer/nmap-logo-64.png
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE="nls"
NMAP_LINGUAS=( de fr hi hr it ja pl pt_BR ru zh )
IUSE+=" ${NMAP_LINGUAS[@]/#/linguas_}"

RDEPEND="
	dev-python/pygtk:2[${PYTHON_USEDEP}]
	${PYTHON_DEPS}
"
DEPEND="
	${RDEPEND}
	~net-analyzer/nmap-${PV}
"

S="${WORKDIR}/${NM_P}"
PATCHES=(
	"${FILESDIR}"/${NM_PN}-5.21-python.patch
	"${FILESDIR}"/${NM_PN}-6.46-uninstaller.patch
)

pkg_setup() {
	#if use ndiff || use zenmap; then
		python-single-r1_pkg_setup
	#fi
}

src_unpack() {
	# prevent unpacking the logo
	unpack ${NM_P}.tar.bz2
}

src_prepare() {
	rm -r libpcap/ || die

	cat "${FILESDIR}"/nls.m4 >> "${S}"/acinclude.m4 || die

	default

	if use nls; then
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
	sed -i \
		-e 's|^Categories=.*|Categories=Network;System;Security;|g' \
		zenmap/install_scripts/unix/zenmap-root.desktop \
		zenmap/install_scripts/unix/zenmap.desktop || die
}

src_configure() {
	# The bundled libdnet is incompatible with the version available in the
	# tree, so we cannot use the system library here.
	# nls disabled for split nmap ebuild - flag used for manipulations above
	econf \
		--enable-ipv6 \
		--disable-nls \
		--without-ncat \
		--without-ndiff \
		--without-nmap-update \
		--without-nping \
		--without-openssl \
		--with-zenmap \
		--without-liblua \
		--cache-file="${S}"/config.cache \
		--with-libdnet=included \
		--with-pcre=/usr
	#	Commented out because configure does weird things
	#	--with-liblinear=/usr \
}

src_compile() {
	emake build-zenmap
}

src_install() {
	emake DESTDIR="${D}" install-zenmap || die
	doicon "${FILESDIR}/nmap-logo-64.png"
	python_optimize
}
