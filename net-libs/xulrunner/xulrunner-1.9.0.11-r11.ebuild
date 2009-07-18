# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/xulrunner/xulrunner-1.9.0.11.ebuild,v 1.5 2009/06/18 01:39:01 ranger Exp $
EAPI="2"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib java-pkg-opt-2 python autotools
PATCH="${PN}-1.9.0.10-patches-0.1"

DESCRIPTION="Mozilla runtime package that can be used to bootstrap XUL+XPCOM applications"
HOMEPAGE="http://developer.mozilla.org/en/docs/XULRunner"
SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://dev.gentoo.org/~armin76/dist/${P}.tar.bz2
	mirror://gentoo/${PATCH}.tar.bz2
	http://dev.gentoo.org/~armin76/dist/${PATCH}.tar.bz2"

KEYWORDS="alpha ~amd64 arm hppa ia64 ppc ppc64 sparc x86"
SLOT="1.9"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE=""

RDEPEND="java? ( >=virtual/jre-1.4 )
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.2
	>=dev-libs/nspr-4.7.4
	>=app-text/hunspell-1.1.9
	>=media-libs/lcms-1.17
	x11-libs/cairo[X]
	x11-libs/pango[X]"

DEPEND="java? ( >=virtual/jdk-1.4 )
	${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/mozilla"

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export MOZ_CO_PROJECT=xulrunner
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

pkg_setup() {
	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	# Apply our patches
	cd "${S}" || die "cd failed"
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"/patch
	
	# Bad mozilla-js.pc, causes stuff like bug 275318
	epatch "${FILESDIR}/066-fix-includedir-mozilla-js.patch"

	eautoreconf || die "failed  running eautoreconf"

	# We need to re-patch this because autoreconf overwrites it
	epatch "${WORKDIR}"/patch/000_flex-configure-LANG.patch
}

src_configure() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-1.9"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	MEXTENSIONS="default"
#	if use python; then
#		MEXTENSIONS="${MEXTENSIONS},python/xpcom"
#	fi

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-mochitest
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-system-hunspell
	#mozconfig_annotate '' --enable-system-sqlite
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	#mozconfig_annotate '' --enable-js-binary
	mozconfig_annotate '' --enable-embedding-tests
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	mozconfig_annotate '' --enable-system-lcms
	mozconfig_annotate '' --with-system-bz2
	# Bug 60668: Galeon doesn't build without oji enabled, so enable it
	# regardless of java setting.
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places --enable-places_bookmarks
	mozconfig_annotate '' --enable-safe-browsing

	# Other ff-specific settings
	mozconfig_annotate '' --enable-jsd
	mozconfig_annotate '' --enable-xpctools
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}

	#disable java
	if ! use java ; then
		mozconfig_annotate '-java' --disable-javaxpcom
	fi

	# Finalize and report settings
	mozconfig_final

	####################################
	#
	#  Configure and build
	#
	####################################

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	CPPFLAGS="${CPPFLAGS} -DARON_WAS_HERE" \
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die

	# It would be great if we could pass these in via CPPFLAGS or CFLAGS prior
	# to econf, but the quotes cause configure to fail.
	sed -i -e \
		's|-DARON_WAS_HERE|-DGENTOO_NSPLUGINS_DIR=\\\"/usr/'"$(get_libdir)"'/nsplugins\\\" -DGENTOO_NSBROWSER_PLUGINS_DIR=\\\"/usr/'"$(get_libdir)"'/nsbrowser/plugins\\\"|' \
		"${S}"/config/autoconf.mk \
		"${S}"/toolkit/content/buildconfig.html
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-1.9"

	emake DESTDIR="${D}" install || die "emake install failed"

	rm "${D}"/usr/bin/xulrunner

	dodir /usr/bin
	dosym ${MOZILLA_FIVE_HOME}/xulrunner /usr/bin/xulrunner-1.9

	# Add vendor
	echo "pref(\"general.useragent.vendor\",\"Sabayon\");" \
		>> "${D}"${MOZILLA_FIVE_HOME}/defaults/pref/vendor.js

	if use java ; then
	    java-pkg_regjar "${D}"${MOZILLA_FIVE_HOME}/javaxpcom.jar
	    java-pkg_regjar "${D}"${MOZILLA_FIVE_HOME}/sdk/lib/MozillaGlue.jar
	    java-pkg_regjar "${D}"${MOZILLA_FIVE_HOME}/sdk/lib/MozillaInterfaces.jar
	fi
}
