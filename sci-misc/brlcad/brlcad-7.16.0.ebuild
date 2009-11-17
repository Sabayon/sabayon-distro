# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils autotools flag-o-matic multilib

DESCRIPTION="Powerful Constructive Solid Geometry modeling system."
HOMEPAGE="http://brlcad.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2 BSD BDL"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug doc opengl"

DEPEND="media-libs/libpng
	sys-devel/bison
	sys-devel/flex
	sys-libs/zlib
	>=sci-libs/tnt-3
	sci-libs/jama
	dev-tcltk/itcl
	dev-tcltk/itk
	sys-libs/libtermcap-compat
	media-libs/urt
	doc? ( dev-libs/libxslt )
	"

RDEPEND="${DEPEND}"

brlcadprefix="/usr/brlcad"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# no need to search /usr/local
	epatch ${FILESDIR}/usr-local.patch
	#./autogen.sh
}

src_compile() {
	local myconf
	#filter-ldflags "-Wl,--as-needed"
	# --disable-step-build to disable fedex build
	myconf="${myconf} \
		--enable-libtkimg-build \
		--disable-adrt-build \
		--disable-jove-build \
		--disable-png-build \
		--disable-regex-build \
		--disable-step-build \
		--disable-termlib-build \
		--disable-tnt-build \
		--disable-urt-build \
		--disable-zlib-build \
		$(use_enable doc documentation) \
		$(use_with opengl ogl) \
        $(use_enable debug) \
        $(use_enable debug runtime-debug) \
        $(use_enable debug verbose) \
        $(use_enable debug warnings) \
        $(use_enable debug progress) \
		"
	use amd64 || myconf="${myconf} --enable-64bit"
	use debug || myconf="${myconf} --enable-optimized"
	./configure $myconf || die "configure failed"
	emake || die "emake failed"
}


src_install() {
	einfo install
	emake DESTDIR="${D}" install || die "emake install failed"
	#setting up PATH=${brlcadprefix}/bin
	dodir /etc/env.d || die
	echo "PATH=${brlcadprefix}/bin" > "${D}"/etc/env.d/99brlcad || die
	echo "MANPATH=${brlcadprefix}/man" >> "${D}"/etc/env.d/99brlcad || die
	#PATH=${brlcadprefix}/bin
	#MANPATH=${brlcadprefix}/man
	#EOF
}

pkg_postinst() {
	einfo "The standard starting point for BRL-CAD is the mged command."
	einfo "Examples are available in ${brlcadprefix}/share/${PN}/${PV}/db/"
	einfo "To run an example, try:"
	einfo "${brlcadprefix}/bin/mged ${brlcadprefix}/share/${PN}/${PV}/db/havoc.g"
	einfo "In the mged terminal window, type 'draw havoc' to see the wireframe in the visualization window."
	einfo "For official documents, visit http://brlcad.org/wiki/Documentation"
}
