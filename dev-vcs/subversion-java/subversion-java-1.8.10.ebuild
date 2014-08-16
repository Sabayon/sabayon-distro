# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
WANT_AUTOMAKE="none"
MY_P="${P/_/-}"

MY_SVN_PN="subversion"
MY_SVN_P="${MY_SVN_PN}-${PV}"
MY_SVN_PF="${MY_SVN_PN}-${PVR}"
MY_SVN_CATEGORY="${CATEGORY}"

# note: java-pkg-2, not java-pkt-opt-2
SAB_PATCHES_SRC=( mirror://sabayon/dev-vcs/${MY_SVN_PN}-1.8.9-Gentoo-patches.tar.gz )
inherit sab-patches autotools eutils flag-o-matic java-pkg-2 libtool multilib

DESCRIPTION="Java bindings for Subversion"
HOMEPAGE="http://subversion.apache.org/"
SRC_URI+=" mirror://apache/${PN}/${MY_SVN_P}.tar.bz2"
S="${WORKDIR}/${MY_SVN_P/_/-}"

LICENSE="Subversion"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE="debug doc nls"

COMMON_DEPEND="~dev-vcs/subversion-${PV}
	>=dev-libs/apr-1.3:1
	>=dev-libs/apr-util-1.3:1"
RDEPEND="
	${COMMON_DEPEND}
	app-arch/bzip2
	>=virtual/jre-1.5"
DEPEND="${COMMON_DEPEND}
	>=virtual/jdk-1.5"

pkg_setup() {
	java-pkg-2_pkg_setup

	if use debug ; then
		append-cppflags -DSVN_DEBUG -DAP_DEBUG
	fi
	# http://mail-archives.apache.org/mod_mbox/subversion-dev/201306.mbox/%3C51C42014.3060700@wandisco.com%3E
	[[ ${CHOST} == *-solaris2* ]] && append-cppflags -D__EXTENSIONS__
}

src_prepare() {
	sab-patches_apply_all
	epatch_user

	fperms +x build/transform_libtool_scripts.sh

	sed -i \
		-e "s/\(BUILD_RULES=.*\) bdb-test\(.*\)/\1\2/g" \
		-e "s/\(BUILD_RULES=.*\) test\(.*\)/\1\2/g" configure.ac

	# this bites us in particular on Solaris
	sed -i -e '1c\#!/usr/bin/env sh' build/transform_libtool_scripts.sh || \
		die "/bin/sh is not POSIX shell!"

	eautoconf
	elibtoolize

	sed -e 's/\(libsvn_swig_py\)-\(1\.la\)/\1-$(EPYTHON)-\2/g' \
		-i build-outputs.mk || die "sed failed"
}

src_configure() {
	local myconf

	myconf+=" --without-swig"
	myconf+=" --without-junit"

	case ${CHOST} in
		*-aix*)
			# avoid recording immediate path to sharedlibs into executables
			append-ldflags -Wl,-bnoipath
		;;
		*-interix*)
			# loader crashes on the LD_PRELOADs...
			myconf+=" --disable-local-library-preloading"
		;;
		*-solaris*)
			# need -lintl to link
			use nls && append-libs intl
			# this breaks installation, on x64 echo replacement is 32-bits
			myconf+=" --disable-local-library-preloading"
		;;
		*-mint*)
			myconf+=" --enable-all-static --disable-local-library-preloading"
		;;
		*)
			# inject LD_PRELOAD entries for easy in-tree development
			myconf+=" --enable-local-library-preloading"
		;;
	esac

	#version 1.7.7 again tries to link against the older installed version and fails, when trying to
	#compile for x86 on amd64, so workaround this issue again
	#check newer versions, if this is still/again needed
	myconf+=" --disable-disallowing-of-undefined-references"

	econf --libdir="${EPREFIX}/usr/$(get_libdir)" \
		--without-apache-libexecdir \
		--without-apxs \
		--without-berkeley-db \
		--without-ctypesgen \
		--disable-runtime-module-search \
		--without-gnome-keyring \
		--enable-javahl \
		--with-jdk="${JAVA_HOME}" \
		--without-kwallet \
		$(use_enable nls) \
		--without-sasl \
		--without-serf \
		${myconf} \
		--with-apr="${EPREFIX}/usr/bin/apr-1-config" \
		--with-apr-util="${EPREFIX}/usr/bin/apu-1-config" \
		--disable-experimental-libtool \
		--without-jikes \
		--disable-mod-activation \
		--disable-static
}

src_compile() {
	emake -j1 JAVAC_FLAGS="$(java-pkg_javac-args) -encoding iso8859-1" javahl

	if use doc ; then
		emake doc-javahl
	fi
}

src_install() {
	emake DESTDIR="${D}" install-javahl
	java-pkg_regso "${ED}"usr/$(get_libdir)/libsvnjavahl*$(get_libname)
	java-pkg_jarinto /usr/share/"${MY_SVN_PN}"/lib
	java-pkg_dojar "${ED}"usr/$(get_libdir)/svn-javahl/svn-javahl.jar
	rm -fr "${ED}"usr/$(get_libdir)/svn-javahl/*.jar

	mv "${ED}usr/share/${PN}/package.env" "${ED}/usr/share/${MY_SVN_PN}/" || die

	if use doc ; then
		java-pkg_dojavadoc doc/javadoc
	fi

	prune_libtool_files --all
}
