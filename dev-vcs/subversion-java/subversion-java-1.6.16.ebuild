# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

WANT_AUTOMAKE="none"

# note: java-pkg-2, not java-pkt-opt-2
inherit autotools eutils flag-o-matic java-pkg-2 libtool multilib

DESCRIPTION="Java bindings for Subversion"
HOMEPAGE="http://subversion.apache.org/"

MY_SVN_PN="subversion"
MY_SVN_P="${MY_SVN_PN}-${PV}"
MY_SVN_PF="${MY_SVN_PN}-${PVR}"
MY_SVN_CATEGORY="${CATEGORY}"
SRC_URI="http://subversion.tigris.org/downloads/${MY_SVN_P}.tar.bz2"

LICENSE="Subversion"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug doc nls test"

COMMON_DEPEND="~dev-vcs/subversion-${PV}"
RDEPEND="
	${COMMON_DEPEND}
	>=virtual/jre-1.5"
DEPEND="${COMMON_DEPEND}
	>=virtual/jdk-1.5
	test? ( dev-java/junit:4 )"

S="${WORKDIR}/${MY_SVN_P/_/-}"

print() {
	local blue color green normal red

	if [[ "${NOCOLOR:-false}" =~ ^(false|no)$ ]]; then
		red=$'\e[1;31m'
		green=$'\e[1;32m'
		blue=$'\e[1;34m'
		normal=$'\e[0m'
	fi

	while (($#)); do
		case "$1" in
			--red)
				color="${red}"
				;;
			--green)
				color="${green}"
				;;
			--blue)
				color="${blue}"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	echo " ${green}*${normal} ${color}$@${normal}"
}

pkg_setup() {
	java-pkg-2_pkg_setup

	if use debug; then
		append-cppflags -DSVN_DEBUG -DAP_DEBUG
	fi

	if use test; then
		if ! has_version "=${CATEGORY}/${PF}" || \
				! has_version "~${MY_SVN_CATEGORY}/${MY_SVN_P}"; then
			die "${CATEGORY}/${PF} and ${MY_SVN_CATEGORY}/${MY_SVN_P} must be installed"
		fi
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${MY_SVN_PN}-1.6.0-disable_linking_against_unneeded_libraries.patch"
	epatch "${FILESDIR}/${MY_SVN_PN}-1.6.2-local_library_preloading.patch"
	epatch "${FILESDIR}/${MY_SVN_PN}-1.6.3-kwallet_window.patch"
	chmod +x build/transform_libtool_scripts.sh || die "chmod failed"

	if ! use test; then
		sed -i \
			-e "s/\(BUILD_RULES=.*\) bdb-test\(.*\)/\1\2/g" \
			-e "s/\(BUILD_RULES=.*\) test\(.*\)/\1\2/g" configure.ac
	fi

	sed -e "/SWIG_PY_INCLUDES=/s/\$ac_cv_python_includes/\\\\\$(PYTHON_INCLUDES)/" -i build/ac-macros/swig.m4 || die "sed failed"

	eautoconf
	elibtoolize

	sed -e "s/libsvn_swig_py-1\.la/libsvn_swig_py-\$(PYTHON_VERSION)-1.la/" -i build-outputs.mk || die "sed failed"
}

src_configure() {
	local myconf

	if use test; then
		myconf+=" --with-junit=${EPREFIX}/usr/share/junit-4/lib/junit.jar"
	else
		myconf+=" --without-junit"
	fi

	econf --libdir="${EPREFIX}/usr/$(get_libdir)" \
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
		--with-sqlite="${EPREFIX}/usr"
}

src_compile() {
	print
	print "Building of Subversion JavaHL library"
	print
	emake -j1 JAVAC_FLAGS="$(java-pkg_javac-args) -encoding iso8859-1" javahl || die "Building of Subversion JavaHL library failed"

	if use doc; then
		print
		print "Building of Subversion JavaHL library HTML documentation"
		print
		emake doc-javahl || die "Building of Subversion JavaHL library HTML documentation failed"
	fi
}

src_test() {
	local test_failed

	print
	print --blue "Testing of Subversion JavaHL library"
	print
	time emake check-javahl || test_failed="1"

	if [[ -n "${test_failed}" ]]; then
		ewarn
		ewarn "\e[1;31mTest failed\e[0m"
		ewarn
	fi
}

src_install() {
	print
	print "Installation of Subversion JavaHL library"
	print
	emake -j1 DESTDIR="${D}" install-javahl || die "Installation of Subversion JavaHL library failed"
	java-pkg_regso "${ED}"usr/$(get_libdir)/libsvnjavahl*.so
	java-pkg_jarinto /usr/share/"${MY_SVN_PN}"/lib
	java-pkg_dojar "${ED}"usr/$(get_libdir)/svn-javahl/svn-javahl.jar
	rm -fr "${ED}"usr/$(get_libdir)/svn-javahl/*.jar

	mv "${ED}usr/share/${PN}/package.env" "${ED}/usr/share/${MY_SVN_PN}/"

	if use doc; then
		java-pkg_dojavadoc doc/javadoc
	fi
}
