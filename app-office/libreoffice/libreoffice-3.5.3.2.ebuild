# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

KDE_REQUIRED="optional"
QT_MINIMAL="4.7.4"
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

BRANDING="${PN}-branding-gentoo-0.4.tar.xz"
# PATCHSET="${P}-patchset-01.tar.xz"

[[ ${PV} == *9999* ]] && SCM_ECLASS="git-2"
inherit base autotools bash-completion-r1 check-reqs eutils java-pkg-opt-2 kde4-base pax-utils prefix python multilib toolchain-funcs flag-o-matic nsplugins ${SCM_ECLASS}
unset SCM_ECLASS

DESCRIPTION="LibreOffice, a full office productivity suite."
HOMEPAGE="http://www.libreoffice.org"
SRC_URI="branding? ( http://dev.gentooexperimental.org/~scarabeus/${BRANDING} )"
[[ -n ${PATCHSET} ]] && SRC_URI+=" http://dev.gentooexperimental.org/~scarabeus/${PATCHSET}"

# Split modules following git/tarballs
# Core MUST be first!
MODULES="core binfilter"
# Only release has the tarballs
if [[ ${PV} != *9999* ]]; then
	for i in ${DEV_URI}; do
		for mod in ${MODULES}; do
			if [[ ${mod} == binfilter ]]; then
				SRC_URI+=" binfilter? ( ${i}/${PN}-${mod}-${PV}.tar.xz )"
			else
				SRC_URI+=" ${i}/${PN}-${mod}-${PV}.tar.xz"
			fi
		done
		unset mod
	done
	unset i
fi
unset DEV_URI

# Really required addons
# These are bundles that can't be removed for now due to huge patchsets.
# If you want them gone, patches are welcome.
ADDONS_SRC+=" ${ADDONS_URI}/ea91f2fb4212a21d708aced277e6e85a-vigra1.4.0.tar.gz"
ADDONS_SRC+=" xmlsec? ( ${ADDONS_URI}/1f24ab1d39f4a51faf22244c94a6203f-xmlsec1-1.2.14.tar.gz )"
ADDONS_SRC+=" java? ( ${ADDONS_URI}/17410483b5b5f267aa18b7e00b65e6e0-hsqldb_1_8_0.zip )"
ADDONS_SRC+=" java? ( ${ADDONS_URI}/798b2ffdc8bcfe7bca2cf92b62caf685-rhino1_5R5.zip )"
ADDONS_SRC+=" java? ( ${ADDONS_URI}/35c94d2df8893241173de1d16b6034c0-swingExSrc.zip )"
ADDONS_SRC+=" java? ( ${ADDONS_URI}/ada24d37d8d638b3d8a9985e80bc2978-source-9.0.0.7-bj.zip )"
ADDONS_SRC+=" odk? ( http://download.go-oo.org/extern/185d60944ea767075d27247c3162b3bc-unowinreg.dll )"
SRC_URI+=" ${ADDONS_SRC}"

unset ADDONS_URI
unset EXT_URI
unset ADDONS_SRC

IUSE="binfilter +branding +cups dbus eds gnome +graphite gstreamer +gtk
jemalloc kde mysql nlpsolver +nsplugin odk opengl pdfimport postgres svg test
+vba +webdav +xmlsec"
LICENSE="LGPL-3"
SLOT="0"
[[ ${PV} == *9999* ]] || KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux"

NSS_DEPEND="
	>=dev-libs/nspr-4.8.8
	>=dev-libs/nss-3.12.9
"

COMMON_DEPEND="
	app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.3.2-r3
	app-text/mythes
	>=app-text/libexttextcat-3.2
	app-text/libwpd:0.9[tools]
	app-text/libwpg:0.2
	>=app-text/libwps-0.2.2
	dev-cpp/libcmis
	dev-db/unixODBC
	dev-libs/expat
	>=dev-libs/glib-2.28
	>=dev-libs/hyphen-2.7.1
	>=dev-libs/icu-4.8.1.1
	>=dev-lang/perl-5.0
	>=dev-libs/openssl-1.0.0d
	>=dev-libs/redland-1.0.14[ssl]
	>=media-libs/fontconfig-2.8.0
	media-libs/freetype:2
	>=media-libs/libpng-1.4
	media-libs/libvisio
	>=net-misc/curl-7.21.4
	sci-mathematics/lpsolve
	>=sys-libs/db-4.8
	virtual/jpeg
	>=x11-libs/cairo-1.10.0[X]
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	dbus? ( >=dev-libs/dbus-glib-0.92 )
	eds? ( gnome-extra/evolution-data-server )
	gnome? (
		gnome-base/gconf:2
		gnome-base/orbit
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
	)
	jemalloc? ( dev-libs/jemalloc )
	mysql? ( >=dev-db/mysql-connector-c++-1.1.0 )
	opengl? ( virtual/opengl )
	pdfimport? ( >=app-text/poppler-0.16[xpdf-headers,cxx] )
	postgres? ( >=dev-db/postgresql-base-8.4.0 )
	svg? ( gnome-base/librsvg )
	webdav? ( net-libs/neon )
	xmlsec? ( ${NSS_DEPEND} )
"

RDEPEND="${COMMON_DEPEND}
	!app-office/libreoffice-bin
	!app-office/libreoffice-bin-debug
	!app-office/openoffice-bin
	!app-office/openoffice
	media-fonts/libertine-ttf
	media-fonts/liberation-fonts
	media-fonts/urw-fonts
	cups? ( net-print/cups )
	java? ( >=virtual/jre-1.6 )
	x11-themes/sabayon-artwork-loo
"

# FIXME: cppunit should be moved to test conditional
#        after everything upstream is under gbuild
#        as dmake execute tests right away
DEPEND="${COMMON_DEPEND}
	>=dev-libs/boost-1.46
	>=dev-libs/libxml2-2.7.8
	dev-libs/libxslt
	dev-perl/Archive-Zip
	dev-util/cppunit
	>=dev-util/gperf-3
	dev-util/intltool
	dev-util/mdds
	>=dev-util/pkgconfig-0.26
	media-libs/sampleicc
	net-misc/npapi-sdk
	net-print/cups
	>=sys-apps/findutils-4.4.2
	sys-devel/bison
	sys-apps/coreutils
	sys-devel/flex
	sys-devel/gettext
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
# Force libreoffice-l10n-en_US installation
# This will install LibreOffice templates
L10N_VER="3.5.2"
PDEPEND="~app-office/libreoffice-l10n-en_US-${L10N_VER}"

PATCHES=(
	# this can't be upstreamed :(
	"${FILESDIR}/${PN}-system-pyuno.patch"
	"${FILESDIR}/${PN}-3.5-propagate-gb_FULLDEPS.patch"
	"${FILESDIR}/${PN}-3.5-doublebuild.patch"
)

REQUIRED_USE="
	nsplugin? ( gtk )
	gnome? ( gtk )
	eds? ( gnome )
	nlpsolver? ( java )
"

S="${WORKDIR}/${PN}-core-${PV}"

RESTRICT="test"

pkg_pretend() {
	local pgslot

	if [[ ${MERGE_TYPE} != binary ]]; then
		CHECKREQS_MEMORY="512M"
		CHECKREQS_DISK_BUILD="6G"
		check-reqs_pkg_pretend

		if [[ $(gcc-major-version) -lt 4 ]]; then
			eerror "Compilation with gcc older than 4.0 is not supported"
			die "Too old gcc found."
		fi
	fi

	# ensure pg version
	if use postgres; then
		 pgslot=$(postgresql-config show)
		 if [[ ${pgslot//.} < 90 ]] ; then
		 	eerror "PostgreSQL slot must be set to 9.0 or higher."
			eerror "    postgresql-config set 9.0"
			die "PostgreSQL slot is not set to 9.0 or higher."
		 fi
	fi
}

pkg_setup() {
	java-pkg-opt-2_pkg_setup
	kde4-base_pkg_setup

	python_set_active_version 2
	python_pkg_setup

	if [[ ${MERGE_TYPE} != binary ]]; then
		CHECKREQS_MEMORY="512M"
		CHECKREQS_DISK_BUILD="6G"
		check-reqs_pkg_pretend
	fi
}

src_unpack() {
	local mod dest tmplfile tmplname mypv

	[[ -n ${PATCHSET} ]] && unpack ${PATCHSET}
	if use branding; then
		unpack "${BRANDING}"
	fi

	if [[ ${PV} != *9999* ]]; then
		for mod in ${MODULES}; do
			if [[ ${mod} == binfilter ]] && ! use binfilter; then
				continue
			fi
			unpack "${PN}-${mod}-${PV}.tar.xz"
			if [[ ${mod} != core ]]; then
				mv -n "${WORKDIR}/${PN}-${mod}-${PV}"/* "${S}"
				rm -rf "${WORKDIR}/${PN}-${mod}-${PV}"
			fi
		done
	else
		for mod in ${MODULES}; do
			if [[ ${mod} == binfilter ]] && ! use binfilter; then
				continue
			fi
			mypv=${PV/.9999}
			[[ ${mypv} != ${PV} ]] && EGIT_BRANCH="${PN}-${mypv/./-}"
			EGIT_PROJECT="${PN}/${mod}"
			EGIT_SOURCEDIR="${WORKDIR}/${PN}-${mod}-${PV}"
			EGIT_REPO_URI="git://anongit.freedesktop.org/${PN}/${mod}"
			EGIT_NOUNPACK="true"
			git-2_src_unpack
			if [[ ${mod} != core ]]; then
				mv -n "${WORKDIR}/${PN}-${mod}-${PV}"/* "${S}"
				rm -rf "${WORKDIR}/${PN}-${mod}-${PV}"
			fi
		done
		unset EGIT_PROJECT EGIT_SOURCEDIR EGIT_REPO_URI EGIT_BRANCH
	fi
}

src_prepare() {
	# optimization flags
	export ARCH_FLAGS="${CXXFLAGS}"
	export LINKFLAGSOPTIMIZE="${LDFLAGS}"

	# patchset
	if [[ -n ${PATCHSET} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/${PATCHSET/.tar.xz/}" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi

	base_src_prepare
	eautoreconf
	# hack in the autogen.sh
	touch autogen.lastrun
	# system pyuno mess
	sed \
		-e "s:%eprefix%:${EPREFIX}:g" \
		-e "s:%libdir%:$(get_libdir):g" \
		-i pyuno/source/module/uno.py \
		-i scripting/source/pyprov/officehelper.py || die

}

src_configure() {
	local java_opts
	local internal_libs
	local jbs=$(sed -ne 's/.*\(-j[[:space:]]*\|--jobs=\)\([[:digit:]]\+\).*/\2/;T;p' <<< "${MAKEOPTS}")

	# recheck that there is some value in jobs
	[[ -z ${jbs} ]] && jbs="1"

	# sane: just sane.h header that is used for scan in writer, not
	#       linked or anything else, worthless to depend on
	# vigra: just uses templates from there
	#        it is serious pain in the ass for packaging
	#        should be replaced by boost::gil if someone interested
	internal_libs+="
		--without-system-sane
		--without-system-vigra
	"

	if use java; then
		# hsqldb: system one is too new
		# saxon: system one does not work properly
		java_opts="
			--without-system-hsqldb
			--without-system-saxon
			--with-ant-home="${ANT_HOME}"
			--with-jdk-home=$(java-config --jdk-home 2>/dev/null)
			--with-java-target-version=$(java-pkg_get-target)
			--with-jvm-path="${EPREFIX}/usr/$(get_libdir)/"
			--with-beanshell-jar=$(java-pkg_getjar bsh bsh.jar)
			--with-lucene-core-jar=$(java-pkg_getjar lucene-2.9 lucene-core.jar)
			--with-lucene-analyzers-jar=$(java-pkg_getjar lucene-analyzers-2.3 lucene-analyzers.jar)
		"
		if use test; then
			java_opts+=" --with-junit=$(java-pkg_getjar junit-4 junit.jar)"
		else
			java_opts+=" --without-junit"
		fi
	fi

	if use branding; then
		internal_libs+="
			--with-about-bitmap="${WORKDIR}/branding-about.png"
			--with-intro-bitmap="${WORKDIR}/branding-intro.png"
		"
	fi

	# system headers/libs/...: enforce using system packages
	# --enable-unix-qstart-libpng: use libpng splashscreen that is faster
	# --enable-cairo: ensure that cairo is always required
	# --enable-*-link: link to the library rather than just dlopen on runtime
	# --enable-release-build: build the libreoffice as release
	# --disable-fetch-external: prevent dowloading during compile phase
	# --disable-gnome-vfs: old gnome virtual fs support
	# --disable-kdeab: kde3 adressbook
	# --disable-kde: kde3 support
	# --disable-ldap: ldap requires internal mozilla stuff, same like mozab
	# --disable-mozilla: disable mozilla build that is used for adresbook, not
	#   affecting the nsplugin that is always ON
	# --disable-pch: precompiled headers cause build crashes
	# --disable-rpath: relative runtime path is not desired
	# --disable-static-gtk: ensure that gtk is linked dynamically
	# --disable-ugly: disable ugly pieces of code
	# --disable-zenity: disable build icon
	# --enable-extension-integration: enable any extension integration support
	# --with-{max-jobs,num-cpus}: ensuring parallel building
	# --without-{afms,fonts,myspell-dicts,ppsd}: prevent install of sys pkgs
	# --without-stlport: disable deprecated extensions framework
	# --disable-ext-report-builder: too much java packages pulled in
	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}/" \
		--with-system-headers \
		--with-system-libs \
		--with-system-jars \
		--with-system-dicts \
		--enable-cairo-canvas \
		--enable-largefile \
		--enable-python=system \
		--enable-randr \
		--enable-randr-link \
		--enable-release-build \
		--enable-unix-qstart-libpng \
		--enable-mergelibs \
		--disable-ccache \
		--disable-crashdump \
		--disable-dependency-tracking \
		--disable-epm \
		--disable-fetch-external \
		--disable-gnome-vfs \
		--disable-ext-report-builder \
		--disable-kdeab \
		--disable-kde \
		--disable-ldap \
		--disable-mozilla \
		--disable-online-update \
		--disable-pch \
		--disable-rpath \
		--disable-systray \
		--disable-static-gtk \
		--disable-strip-solver \
		--disable-ugly \
		--disable-zenity \
		--with-alloc=$(use jemalloc && echo "jemalloc" || echo "system") \
		--with-build-version="Sabayon official package" \
		--enable-extension-integration \
		--with-external-dict-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-hyph-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-thes-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-tar="${DISTDIR}" \
		--with-lang="" \
		--with-max-jobs=${jbs} \
		--with-num-cpus=2 \
		--with-unix-wrapper=libreoffice \
		--with-vendor="Sabayon Foundation" \
		--with-x \
		--without-afms \
		--without-fonts \
		--without-myspell-dicts \
		--without-stlport \
		--without-system-mozilla \
		--without-help \
		--with-helppack-integration \
		--without-sun-templates \
		$(use_enable binfilter) \
		$(use_enable dbus) \
		$(use_enable eds evolution2) \
		$(use_enable gnome gconf) \
		$(use_enable gnome gio) \
		$(use_enable gnome lockdown) \
		$(use_enable graphite) \
		$(use_enable gstreamer) \
		$(use_enable gtk) \
		--disable-gtk3 \
		$(use_enable java ext-scripting-beanshell) \
		$(use_enable kde kde4) \
		$(use_enable mysql ext-mysql-connector) \
		$(use_enable nlpsolver ext-nlpsolver) \
		$(use_enable nsplugin) \
		$(use_enable odk) \
		$(use_enable opengl) \
		$(use_enable pdfimport ext-pdfimport) \
		$(use_enable postgres postgresql-sdbc) \
		$(use_enable svg librsvg system) \
		$(use_enable test linkoo) \
		$(use_enable vba) \
		$(use_enable vba activex-component) \
		$(use_enable webdav neon) \
		$(use_enable xmlsec) \
		$(use_with java) \
		$(use_with mysql system-mysql-cppconn) \
		${internal_libs} \
		${java_opts}
}

src_compile() {
	# this is not a proper make script and the jobs are passed during configure
	make build || die
}

src_test() {
	make check || die
}

src_install() {
	# This is not Makefile so no buildserver
	make DESTDIR="${D}" distro-pack-install -o build -o check || die

	# Fix bash completion placement
	newbashcomp "${ED}"/etc/bash_completion.d/libreoffice.sh ${PN}
	rm -rf "${ED}"/etc/

	# symlink the nsplugin to system location
	if use nsplugin; then
		inst_plugin /usr/$(get_libdir)/libreoffice/program/libnpsoplugin.so
	fi

	if use branding; then
		insinto /usr/$(get_libdir)/${PN}/program
		newins "${WORKDIR}/branding-sofficerc" sofficerc
	fi

	# Hack for offlinehelp, this needs fixing upstream at some point.
	# It is broken because we send --without-help
	# https://bugs.freedesktop.org/show_bug.cgi?id=46506
	insinto /usr/$(get_libdir)/libreoffice/help
	doins xmlhelp/util/main_transform.xsl

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
	pax-mark -m "${EPREFIX}"/usr/$(get_libdir)/libreoffice/program/unopkg.bin

	use cups || \
		ewarn 'You will need net-print/cups to be able to print and export to PDF with libreoffice.'
}

pkg_postrm() {
	kde4-base_pkg_postrm
}
