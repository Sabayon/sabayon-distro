# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4
# $Header: $

EAPI=4

KDE_REQUIRED="optional"
KDE_SCM="git"
CMAKE_REQUIRED="never"

PYTHON_DEPEND="2"
PYTHON_USE_WITH="threads,xml"

# experimental ; release ; old
# Usually the tarballs are moved a lot so this should make
# everyone happy.
DEV_URI="
	http://dev-builds.libreoffice.org/pre-releases/src
	http://download.documentfoundation.org/libreoffice/src
	http://download.documentfoundation.org/libreoffice/old/src
"
EXT_URI="http://ooo.itc.hu/oxygenoffice/download/libreoffice"
ADDONS_URI="http://dev-www.libreoffice.org/src/"

BRANDING="${PN}-branding-gentoo-0.3.tar.xz"
# PATCHSET="${P}-patchset-01.tar.xz"

[[ ${PV} == *9999* ]] && SCM_ECLASS="git-2"
inherit base autotools bash-completion-r1 check-reqs eutils java-pkg-opt-2 kde4-base pax-utils prefix python multilib toolchain-funcs flag-o-matic nsplugins versionator ${SCM_ECLASS}
unset SCM_ECLASS

DESCRIPTION="LibreOffice, a full office productivity suite."
HOMEPAGE="http://www.libreoffice.org"
SRC_URI=""
[[ -n ${PATCHSET} ]] && SRC_URI+=" http://dev.gentooexperimental.org/~scarabeus/${PATCHSET}"

# Bootstrap MUST be first!
MODULES="bootstrap artwork base calc components extensions extras filters help
impress libs-core libs-extern libs-extern-sys libs-gui postprocess sdk testing
ure writer"
# Only release has the tarballs
if [[ ${PV} != *9999* ]]; then
	for i in ${DEV_URI}; do
		for mod in ${MODULES}; do
			SRC_URI+=" ${i}/${PN}-${mod}-${PV}.tar.bz2"
		done
		unset mod
	done
	unset i
fi
unset DEV_URI

# addons
# FIXME: actually review which one of these are used
ADDONS_SRC+=" ${ADDONS_URI}/128cfc86ed5953e57fe0f5ae98b62c2e-libtextcat-2.2.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/17410483b5b5f267aa18b7e00b65e6e0-hsqldb_1_8_0.zip"
ADDONS_SRC+=" ${ADDONS_URI}/bd30e9cf5523cdfc019b94f5e1d7fd19-cppunit-1.12.1.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/1f24ab1d39f4a51faf22244c94a6203f-xmlsec1-1.2.14.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/fdb27bfe2dbe2e7b57ae194d9bf36bab-SampleICC-1.3.2.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/798b2ffdc8bcfe7bca2cf92b62caf685-rhino1_5R5.zip"
ADDONS_SRC+=" ${ADDONS_URI}/35c94d2df8893241173de1d16b6034c0-swingExSrc.zip"
ADDONS_SRC+=" http://download.go-oo.org/extern/b4cae0700aa1c2aef7eb7f345365e6f1-translate-toolkit-1.8.1.tar.bz2"
ADDONS_SRC+=" http://download.go-oo.org/extern/185d60944ea767075d27247c3162b3bc-unowinreg.dll"
SRC_URI+=" ${ADDONS_SRC}"

unset ADDONS_URI
unset EXT_URI
unset ADDONS_SRC

IUSE="binfilter +branding custom-cflags dbus debug eds gnome graphite
gstreamer gtk jemalloc kde mysql nsplugin odk opengl pdfimport python
test +vba webdav"
LICENSE="LGPL-3"
SLOT="0"
[[ ${PV} == *9999* ]] || KEYWORDS="~amd64 ~arm ~ppc ~x86 ~amd64-linux ~x86-linux"

COMMON_DEPEND="
	app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.3.2-r3
	app-text/mythes
	app-text/libwpd:0.9[tools]
	app-text/libwpg:0.2
	>=app-text/libwps-0.2.2
	dev-db/unixODBC
	dev-libs/expat
	>=dev-libs/glib-2.28
	>=dev-libs/hyphen-2.7.1
	>=dev-libs/icu-4.8.1-r1
	>=dev-lang/perl-5.0
	>=dev-libs/openssl-1.0.0d
	>=dev-libs/redland-1.0.14[ssl]
	media-libs/freetype:2
	>=media-libs/fontconfig-2.8.0
	>=media-libs/vigra-1.7
	>=media-libs/libpng-1.4
	net-print/cups
	sci-mathematics/lpsolve
	>=sys-libs/db-4.8
	virtual/jpeg
	>=x11-libs/cairo-1.10.0
	x11-libs/libXaw
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	dbus? ( >=dev-libs/dbus-glib-0.92 )
	eds? ( gnome-extra/evolution-data-server )
	gnome? (
		gnome-base/gconf:2
		gnome-base/orbit:2
	)
	gtk? ( >=x11-libs/gtk+-2.24:2 )
	graphite? ( media-gfx/graphite2 )
	gstreamer? (
		>=media-libs/gstreamer-0.10
		>=media-libs/gst-plugins-base-0.10
	)
	java? (
		>=dev-java/bsh-2.0_beta4
		dev-java/lucene:2.9
		dev-java/lucene-analyzers:2.3
		dev-java/saxon:0
	)
	jemalloc? ( dev-libs/jemalloc )
	mysql? ( >=dev-db/mysql-connector-c++-1.1.0 )
	nsplugin? (
		net-libs/xulrunner:1.9
		>=dev-libs/nspr-4.8.8
		>=dev-libs/nss-3.12.9
	)
	opengl? ( virtual/opengl )
	pdfimport? ( >=app-text/poppler-0.16[xpdf-headers,cxx] )
	webdav? ( net-libs/neon )
"

RDEPEND="${COMMON_DEPEND}
	!app-office/libreoffice-bin
	!app-office/openoffice-bin
	!app-office/openoffice
	java? ( >=virtual/jre-1.6 )
	x11-themes/sabayon-artwork-loo
"

DEPEND="${COMMON_DEPEND}
	>=dev-libs/boost-1.46
	>=dev-libs/libxml2-2.7.8
	dev-libs/libxslt
	dev-perl/Archive-Zip
	>=dev-util/gperf-3
	dev-util/intltool
	dev-util/mdds
	>=dev-util/pkgconfig-0.26
	>=net-misc/curl-7.21.4
	>=sys-apps/findutils-4.4.2
	sys-devel/bison
	sys-apps/coreutils
	sys-devel/flex
	>=sys-devel/make-3.82
	sys-libs/zlib
	x11-libs/libXtst
	x11-proto/randrproto
	x11-proto/xextproto
	x11-proto/xineramaproto
	x11-proto/xproto
	java? (
		=virtual/jdk-1.6*
		>=dev-java/ant-core-1.7
		test? ( dev-java/junit:4 )
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-3.3.1-neon_remove_SSPI_support.diff"
	"${FILESDIR}/${PN}-libdb5-fix-check.diff"
	"${FILESDIR}/sdext-presenter.diff"
	"${FILESDIR}/${PN}-svx.patch"
	"${FILESDIR}/${PN}-vbaobj-visibility-fix.patch"
	"${FILESDIR}/${PN}-solenv-build-crash.patch"
	"${FILESDIR}/${PN}-as-needed-gtk.patch"
	"${FILESDIR}/${PN}-translate-toolkit-parallel-solenv.patch"
	"${FILESDIR}/${PN}-gbuild-use-cxxflags.patch"
	"${FILESDIR}/${PN}-installed-files-permissions.patch"
	"${FILESDIR}/${PN}-check-for-avx.patch"
	"${FILESDIR}/${PN}-append-no-avx.patch"
	"${FILESDIR}/${PN}-32b-qt4-libdir.patch"
	"${FILESDIR}/${PN}-binfilter-as-needed.patch"
	"${FILESDIR}/${PN}-kill-cppunit.patch"
	"${FILESDIR}/${PN}-honor-strip.patch"
	"${FILESDIR}/${PN}-java.patch"
	"${FILESDIR}/${PN}-kde48.patch"
)

REQUIRED_USE="
	gnome? ( gtk )
	nsplugin? ( gtk )
	eds? ( gnome )
"

# Needs lots and lots of work and compiling
RESTRICT="test"

S="${WORKDIR}/${PN}-bootstrap-${PV}"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		CHECKREQS_MEMORY="1G"
		use debug && CHECKREQS_DISK_BUILD="15G" || CHECKREQS_DISK_BUILD="9G"
		check-reqs_pkg_pretend

		if [[ $(gcc-major-version) -lt 4 ]]; then
			eerror "Compilation with gcc older than 4.0 is not supported"
			die "Too old gcc found."
		fi
	fi
}

pkg_setup() {
	java-pkg-opt-2_pkg_setup
	kde4-base_pkg_setup

	python_set_active_version 2
	python_pkg_setup

	if use custom-cflags; then
		ewarn "You are using custom CFLAGS, which is NOT supported and can cause"
		ewarn "all sorts of build and runtime errors."
		ewarn
		ewarn "Before reporting a bug, please make sure you rebuild and try with"
		ewarn "basic CFLAGS, otherwise the bug will not be accepted."
		ewarn
	fi

	if ! use java; then
		ewarn "You are building with java-support disabled, this results in some"
		ewarn "of the LibreOffice functionality being disabled."
		ewarn "If something you need does not work for you, rebuild with"
		ewarn "java in your USE-flags."
		ewarn
		ewarn "Some java libraries will be provided internally by libreoffice"
		ewarn "during the build. You should really reconsider enabling java"
		ewarn "use flag."
		ewarn
	fi

	if ! use gtk; then
		ewarn "If you want the LibreOffice systray quickstarter to work"
		ewarn "activate the 'gtk' use flag."
		ewarn
	fi
}

src_unpack() {
	local mod dest tmplfile tmplname mypv

	if [[ ${PV} != *9999* ]]; then
		for mod in ${MODULES}; do
			unpack "${PN}-${mod}-${PV}.tar.bz2"
			if [[ ${mod} != bootstrap ]]; then
				mv -n "${WORKDIR}/${PN}-${mod}-${PV}"/* "${S}"
				rm -rf "${WORKDIR}/${PN}-${mod}-${PV}"
			fi
		done
	else
		for mod in ${MODULES}; do
			mypv=${PV/.9999}
			[[ ${mypv} != ${PV} ]] && EGIT_BRANCH="${PN}-${mypv/./-}"
			EGIT_PROJECT="${PN}/${mod}"
			EGIT_SOURCEDIR="${WORKDIR}/${PN}-${mod}-${PV}"
			EGIT_REPO_URI="git://anongit.freedesktop.org/${PN}/${mod}"
			EGIT_NOUNPACK="true"
			git-2_src_unpack
			if [[ ${mod} != bootstrap ]]; then
				mv -n "${WORKDIR}/${PN}-${mod}-${PV}"/* "${S}"
				rm -rf "${WORKDIR}/${PN}-${mod}-${PV}"
			fi
		done
		unset EGIT_PROJECT EGIT_SOURCEDIR EGIT_REPO_URI EGIT_BRANCH
	fi

	[[ -n ${PATCHSET} ]] && unpack ${PATCHSET}
}

src_prepare() {
	# optimization flags
	export ARCH_FLAGS="${CXXFLAGS}"
	use debug || export LINKFLAGSOPTIMIZE="${LDFLAGS}"

	# compiler flags
	use custom-cflags || strip-flags
	use debug || filter-flags "-g*"
	# silent miscompiles; LO/OOo adds -O2/1/0 where appropriate
	filter-flags "-O*"

	if [[ -n ${PATCHSET} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/${PATCHSET/.tar.xz/}" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi

	base_src_prepare
	eautoreconf
}

src_configure() {
	local java_opts
	local internal_libs
	local extensions
	local themes="crystal"
	local jbs=$(sed -ne 's/.*\(-j[[:space:]]*\|--jobs=\)\([[:digit:]]\+\).*/\2/;T;p' <<< "${MAKEOPTS}")

	# recheck that there is some value in jobs
	[[ -z ${jbs} ]] && jbs="1"

	# expand themes we are going to build based on DE useflags
	use gnome && themes+=" tango"
	use kde && themes+=" oxygen"

	# list the extensions we are going to build by default
	extensions="
		$(use_enable pdfimport ext-pdfimport)
		--enable-ext-presenter-console
		--enable-ext-presenter-minimizer
	"

	# hsqldb: requires just 1.8.0 not 1.8.1 which we don't ship at all
	# dmake: not worth of splitting out
	# cppunit: patched not to run anything, just main() { return 0; }
	# 	   workaround to upstream running the tests during build
	# sane: just sane.h header that is used for scan in writer, not
	#	linked or anything else, worthless to depend on
	internal_libs+="
		--without-system-hsqldb
		--without-system-cppunit
		--without-system-sane-header
	"

	# When building without java some things needs to be done
	# as internal libraries.
	if ! use java; then
		internal_libs+="
			--without-junit
		"
	else
		java_opts="
			--with-ant-home="${ANT_HOME}"
			--with-jdk-home=$(java-config --jdk-home 2>/dev/null)
			--with-java-target-version=$(java-pkg_get-target)
			--with-jvm-path="${EPREFIX}/usr/$(get_libdir)/"
			--with-beanshell-jar=$(java-pkg_getjar bsh bsh.jar)
			--with-lucene-core-jar=$(java-pkg_getjar lucene-2.9 lucene-core.jar)
			--with-lucene-analyzers-jar=$(java-pkg_getjar lucene-analyzers-2.3 lucene-analyzers.jar)
			--with-saxon-jar=$(java-pkg_getjar saxon saxon8.jar)
		"
		if use test; then
			java_opts+=" --with-junit=$(java-pkg_getjar junit-4 junit.jar)"
		else
			java_opts+=" --without-junit"
		fi
	fi

	# system headers/libs/...: enforce using system packages
	#   only expections are mozilla and odbc/sane/xrender-header(s).
	#   for jars the exception is db.jar controlled by --with-system-db
	# --enable-unix-qstart-libpng: use libpng splashscreen that is faster
	# --disable-broffice: do not use brazillian brand just be uniform
	# --enable-cairo: ensure that cairo is always required
	# --enable-*-link: link to the library rather than just dlopen on runtime
	# --disable-fetch-external: prevent dowloading during compile phase
	# --disable-gnome-vfs: old gnome virtual fs support
	# --disable-kdeab: kde3 adressbook
	# --disable-kde: kde3 support
	# --disable-pch: precompiled headers cause build crashes
	# --disable-rpath: relative runtime path is not desired
	# --disable-static-gtk: ensure that gtk is linked dynamically
	# --disable-zenity: disable build icon
	# --with-extension-integration: enable any extension integration support
	# --with-{max-jobs,num-cpus}: ensuring parallel building
	# --without-{afms,fonts,myspell-dicts,ppsd}: prevent install of sys pkgs
	# --without-stlport: disable deprecated extensions framework
	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}/" \
		--with-system-headers \
		--with-system-libs \
		--with-system-jars \
		--with-system-db \
		--with-system-dicts \
		--enable-cairo \
		--enable-cups \
		--enable-fontconfig \
		--enable-largefile \
		--enable-randr \
		--enable-randr-link \
		--enable-unix-qstart-libpng \
		--enable-Xaw \
		--enable-xrender-link \
		--disable-broffice \
		--disable-crashdump \
		--disable-dependency-tracking \
		--disable-epm \
		--disable-fetch-external \
		--disable-gnome-vfs \
		--disable-kdeab \
		--disable-kde \
		--disable-ldap \
		--disable-online-update \
		--disable-pch \
		--disable-rpath \
		--disable-static-gtk \
		--disable-strip-solver \
		--disable-zenity \
		--with-alloc=$(use jemalloc && echo "jemalloc" || echo "system") \
		--with-build-version="Sabayon official package" \
		--with-extension-integration \
		--with-external-dict-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-hyph-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-thes-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-tar="${DISTDIR}" \
		--with-lang="" \
		--with-max-jobs=${jbs} \
		--with-num-cpus=1 \
		--with-theme="${themes}" \
		--with-unix-wrapper=libreoffice \
		--with-vendor="Sabayon Linux" \
		--with-x \
		--without-afms \
		--without-fonts \
		--without-myspell-dicts \
		--without-ppds \
		--without-stlport \
		--without-helppack-integration \
		--without-sun-templates \
		$(use_enable binfilter) \
		$(use_enable dbus) \
		$(use_enable debug crashdump) \
		$(use_enable eds evolution2) \
		$(use_enable gnome gconf) \
		$(use_enable gnome gio) \
		$(use_enable gnome lockdown) \
		$(use_enable graphite) \
		$(use_enable gstreamer) \
		$(use_enable gtk) \
		$(use_enable gtk systray) \
		$(use_enable java ext-scripting-beanshell) \
		$(use_enable kde kde4) \
		$(use_enable mysql ext-mysql-connector) \
		$(use_enable nsplugin mozilla) \
		$(use_enable odk) \
		$(use_enable opengl) \
		$(use_enable python) \
		$(use_enable python ext-scripting-python) \
		$(use_enable vba) \
		$(use_enable vba activex-component) \
		$(use_enable webdav neon) \
		$(use_with java) \
		$(use_with mysql system-mysql-cppconn) \
		$(use_with nsplugin system-mozilla libxul) \
		${internal_libs} \
		${java_opts} \
		${extensions}
}

src_compile() {
	# this is not a proper make script and the jobs are passed during configure
	make || die
}

src_install() {
	# This is not Makefile so no buildserver
	make DESTDIR="${D}" distro-pack-install || die

	# Fix bash completion placement
	newbashcomp "${ED}"/etc/bash_completion.d/libreoffice.sh ${PN}
	rm -rf "${ED}"/etc/

	# symlink the plugin to system location
	if use nsplugin; then
		inst_plugin /usr/$(get_libdir)/libreoffice/program/libnpsoplugin.so
	fi

	# Remove files provided by x11-themes/sabayon-artwork-loo
	rm  "${ED}"/usr/$(get_libdir)/libreoffice/program/intro.png || die "intro.bmp rm failed"
	rm "${ED}"/usr/$(get_libdir)/libreoffice/program/about.png || die "about.png rm failed"
	rm "${ED}"/usr/$(get_libdir)/libreoffice/program/sofficerc || die "sofficerc rm failed"
}

pkg_preinst() {
	# Cache updates - all handled by kde eclass for all environments
	kde4-base_pkg_preinst
}

pkg_postinst() {
	kde4-base_pkg_postinst

	pax-mark -m "${EPREFIX}"/usr/$(get_libdir)/libreoffice/program/soffice.bin
}

pkg_postrm() {
	kde4-base_pkg_postrm
}
