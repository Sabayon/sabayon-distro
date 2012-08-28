# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
WANT_AUTOMAKE="none"
MY_P="${P/_/-}"

MY_SVN_PN="subversion"
MY_SVN_P="${MY_SVN_PN}-${PV}"
MY_SVN_PF="${MY_SVN_PN}-${PVR}"
MY_SVN_CATEGORY="${CATEGORY}"

# note: java-pkg-2, not java-pkt-opt-2
inherit autotools eutils flag-o-matic java-pkg-2 libtool multilib

DESCRIPTION="Java bindings for Subversion"
HOMEPAGE="http://subversion.apache.org/"
SRC_URI="http://subversion.tigris.org/downloads/${MY_SVN_P}.tar.bz2"
S="${WORKDIR}/${MY_SVN_P/_/-}"

LICENSE="Subversion GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE="debug doc nls"

COMMON_DEPEND="~dev-vcs/subversion-${PV}"
RDEPEND="
	${COMMON_DEPEND}
	>=virtual/jre-1.5"
DEPEND="${COMMON_DEPEND}
	>=virtual/jdk-1.5"

pkg_setup() {
	java-pkg-2_pkg_setup

	if use debug; then
		append-cppflags -DSVN_DEBUG -DAP_DEBUG
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${MY_SVN_PN}-1.5.4-interix.patch \
		"${FILESDIR}"/${MY_SVN_PN}-1.5.6-aix-dso.patch \
		"${FILESDIR}"/${MY_SVN_PN}-1.6.3-hpux-dso.patch \
		"${FILESDIR}"/${MY_SVN_PN}-${PV}-revert-mod_dontdothat-move.patch

	fperms +x build/transform_libtool_scripts.sh

	sed -i \
		-e "s/\(BUILD_RULES=.*\) bdb-test\(.*\)/\1\2/g" \
		-e "s/\(BUILD_RULES=.*\) test\(.*\)/\1\2/g" configure.ac

	sed -e "/SWIG_PY_INCLUDES=/s/\$ac_cv_python_includes/\\\\\$(PYTHON_INCLUDES)/" -i build/ac-macros/swig.m4 || die "sed failed"

	# this bites us in particular on Solaris
	sed -i -e '1c\#!/usr/bin/env sh' build/transform_libtool_scripts.sh || \
		die "/bin/sh is not POSIX shell!"

	eautoconf
	elibtoolize

	sed -e "s/libsvn_swig_py-1\.la/libsvn_swig_py-\$(PYTHON_VERSION)-1.la/" -i build-outputs.mk || die "sed failed"
}

src_configure() {
	local myconf

	myconf+=" --without-swig"
	myconf+=" --without-junit"

	if use nls; then
		myconf+=" --enable-nls"
	else
		myconf+=" --disable-nls"
	fi

	case ${CHOST} in
		*-aix*)
			# avoid recording immediate path to sharedlibs into executables
			append-ldflags -Wl,-bnoipath
		;;
		*-interix*)
			# loader crashes on the LD_PRELOADs...
			myconf+=" --disable-local-library-preloading"
		;;
	esac

	#workaround for bug 387057
	has_version =dev-vcs/subversion-1.6* && myconf+=" --disable-disallowing-of-undefined-references"

	econf --libdir="${EPREFIX}/usr/$(get_libdir)" \
		--without-apxs \
		--without-berkeley-db \
		--without-ctypesgen \
		--disable-runtime-module-search \
		--without-gnome-keyring \
		--enable-javahl \
		--with-jdk="${JAVA_HOME}" \
		--without-kwallet \
		--without-sasl \
		--without-neon \
		--without-serf \
		${myconf} \
		--with-apr="${EPREFIX}/usr/bin/apr-1-config" \
		--with-apr-util="${EPREFIX}/usr/bin/apu-1-config" \
		--disable-experimental-libtool \
		--without-jikes \
		--enable-local-library-preloading \
		--disable-mod-activation \
		--disable-neon-version-check \
		--disable-static
}

src_compile() {
	emake -j1 JAVAC_FLAGS="$(java-pkg_javac-args) -encoding iso8859-1" javahl || die "Building of Subversion JavaHL library failed"

	if use doc; then
		emake doc-javahl || die "Building of Subversion JavaHL library HTML documentation failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install-javahl || die "Installation of Subversion JavaHL library failed"
	java-pkg_regso "${ED}"usr/$(get_libdir)/libsvnjavahl*$(get_libname)
	java-pkg_jarinto /usr/share/"${MY_SVN_PN}"/lib
	java-pkg_dojar "${ED}"usr/$(get_libdir)/svn-javahl/svn-javahl.jar
	rm -fr "${ED}"usr/$(get_libdir)/svn-javahl/*.jar

	mv "${ED}usr/share/${PN}/package.env" "${ED}/usr/share/${MY_SVN_PN}/" || die

	if use doc; then
		java-pkg_dojavadoc doc/javadoc
	fi

	find "${D}" '(' -name '*.la' ')' -print0 | xargs -0 rm -f
}
