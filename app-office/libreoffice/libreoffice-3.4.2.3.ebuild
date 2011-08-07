# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/libreoffice/libreoffice-3.4.2.3.ebuild,v 1.21 2011/08/06 16:48:01 mattst88 Exp $

EAPI=3

KDE_REQUIRED="optional"
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

[[ ${PV} == *9999* ]] && SCM_ECLASS="git-2"
inherit base autotools check-reqs eutils java-pkg-opt-2 kde4-base pax-utils prefix python multilib toolchain-funcs flag-o-matic nsplugins ${SCM_ECLASS}
unset SCM_ECLASS

DESCRIPTION="LibreOffice, a full office productivity suite."
HOMEPAGE="http://www.libreoffice.org"
SRC_URI=""

# Shiny split sources with so many packages...
# Bootstrap MUST be first!
MODULES="bootstrap artwork base calc components extensions extras filters help
impress libs-core libs-extern libs-extern-sys libs-gui postprocess sdk testing
ure writer translations"
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
ADDONS_SRC+=" ${ADDONS_URI}/1756c4fa6c616ae15973c104cd8cb256-Adobe-Core35_AFMs-314.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/1f24ab1d39f4a51faf22244c94a6203f-xmlsec1-1.2.14.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/24be19595acad0a2cae931af77a0148a-LICENSE_source-9.0.0.7-bj.html"
ADDONS_SRC+=" ${ADDONS_URI}/2a177023f9ea8ec8bd00837605c5df1b-jakarta-tomcat-5.0.30-src.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/35c94d2df8893241173de1d16b6034c0-swingExSrc.zip"
ADDONS_SRC+=" ${ADDONS_URI}/35efabc239af896dfb79be7ebdd6e6b9-gentiumbasic-fonts-1.10.zip"
ADDONS_SRC+=" ${ADDONS_URI}/39bb3fcea1514f1369fcfc87542390fd-sacjava-1.3.zip"
ADDONS_SRC+=" ${ADDONS_URI}/48470d662650c3c074e1c3fabbc67bbd-README_source-9.0.0.7-bj.txt"
ADDONS_SRC+=" ${ADDONS_URI}/4a660ce8466c9df01f19036435425c3a-glibc-2.1.3-stub.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/599dc4cc65a07ee868cf92a667a913d2-xpdf-3.02.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/798b2ffdc8bcfe7bca2cf92b62caf685-rhino1_5R5.zip"
ADDONS_SRC+=" ${ADDONS_URI}/8294d6c42e3553229af9934c5c0ed997-stax-api-1.0-2-sources.jar"
ADDONS_SRC+=" ${ADDONS_URI}/a7983f859eafb2677d7ff386a023bc40-xsltml_2.1.2.zip"
ADDONS_SRC+=" ${ADDONS_URI}/ada24d37d8d638b3d8a9985e80bc2978-source-9.0.0.7-bj.zip"
ADDONS_SRC+=" ${ADDONS_URI}/d4c4d91ab3a8e52a2e69d48d34ef4df4-core.zip"
ADDONS_SRC+=" ${ADDONS_URI}/fdb27bfe2dbe2e7b57ae194d9bf36bab-SampleICC-1.3.2.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/3404ab6b1792ae5f16bbd603bd1e1d03-libformula-1.1.7.zip"
ADDONS_SRC+=" ${ADDONS_URI}/3bdf40c0d199af31923e900d082ca2dd-libfonts-1.1.6.zip"
ADDONS_SRC+=" ${ADDONS_URI}/8ce2fcd72becf06c41f7201d15373ed9-librepository-1.1.6.zip"
ADDONS_SRC+=" ${ADDONS_URI}/97b2d4dba862397f446b217e2b623e71-libloader-1.1.6.zip"
ADDONS_SRC+=" ${ADDONS_URI}/d8bd5eed178db6e2b18eeed243f85aa8-flute-1.1.6.zip"
ADDONS_SRC+=" ${ADDONS_URI}/db60e4fde8dd6d6807523deb71ee34dc-liblayout-0.2.10.zip"
ADDONS_SRC+=" ${ADDONS_URI}/eeb2c7ddf0d302fba4bfc6e97eac9624-libbase-1.1.6.zip"
ADDONS_SRC+=" ${ADDONS_URI}/f94d9870737518e3b597f9265f4e9803-libserializer-1.1.6.zip"
ADDONS_SRC+=" ${ADDONS_URI}/ba2930200c9f019c2d93a8c88c651a0f-flow-engine-0.9.4.zip"
ADDONS_SRC+=" ${ADDONS_URI}/451ccf439a36a568653b024534669971-ConvertTextToNumber-1.3.2.oxt"
ADDONS_SRC+=" ${ADDONS_URI}/47e1edaa44269bc537ae8cabebb0f638-JLanguageTool-1.0.0.tar.bz2"
ADDONS_SRC+=" ${ADDONS_URI}/90401bca927835b6fbae4a707ed187c8-nlpsolver-0.9.tar.bz2"
ADDONS_SRC+=" ${ADDONS_URI}/0f63ee487fda8f21fafa767b3c447ac9-ixion-0.2.0.tar.gz"
ADDONS_SRC+=" ${ADDONS_URI}/71474203939fafbe271e1263e61d083e-nss-3.12.8-with-nspr-4.8.6.tar.gz"
ADDONS_SRC+=" http://download.go-oo.org/extern/185d60944ea767075d27247c3162b3bc-unowinreg.dll"
ADDONS_SRC+=" http://download.go-oo.org/extern/b4cae0700aa1c2aef7eb7f345365e6f1-translate-toolkit-1.8.1.tar.bz2"
ADDONS_SRC+=" http://www.numbertext.org/linux/881af2b7dca9b8259abbca00bbbc004d-LinLibertineG-20110101.zip"
SRC_URI+=" ${ADDONS_SRC}"

TDEPEND="${EXT_URI}/472ffb92d82cf502be039203c606643d-Sun-ODF-Template-Pack-en-US_1.0.0.oxt"
SRC_URI+=" templates? ( ${TDEPEND} )"

unset ADDONS_URI
unset EXT_URI
unset ADDONS_SRC

IUSE="binfilter cups custom-cflags dbus debug eds gnome graphite
gstreamer gtk kde ldap mysql nsplugin odk offlinehelp opengl python templates
test +vba webdav"
LICENSE="LGPL-3"
SLOT="0"
[[ ${PV} == *9999* ]] || KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux"

# translations
LANGUAGES="en en-US"

COMMON_DEPEND="
	app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.1.4-r1
	app-text/mythes
	app-text/libwpd:0.9[tools]
	>=app-text/libwps-0.2.2
	>=app-text/poppler-0.12.3-r3[xpdf-headers]
	dev-db/unixODBC
	dev-libs/expat
	>=dev-libs/glib-2.18
	>=dev-libs/hyphen-2.7.1
	>=dev-libs/icu-4.0
	>=dev-lang/perl-5.0
	>=dev-libs/openssl-0.9.8g
	dev-libs/redland[ssl]
	media-libs/freetype:2
	>=media-libs/fontconfig-2.3.0
	>=media-libs/vigra-1.4
	media-libs/libpng
	app-text/libwpg:0.2
	sci-mathematics/lpsolve
	>=sys-libs/db-4.8
	virtual/jpeg
	>=x11-libs/cairo-1.0.2
	x11-libs/libXaw
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	cups? ( net-print/cups )
	dbus? ( >=dev-libs/dbus-glib-0.71 )
	eds? ( >=gnome-extra/evolution-data-server-1.2 )
	gnome? (
		>=x11-libs/gtk+-2.10:2
		gnome-base/gconf:2
	)
	gtk? ( >=x11-libs/gtk+-2.10:2 )
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
	ldap? ( net-nds/openldap )
	mysql? ( dev-db/mysql-connector-c++ )
	nsplugin? (
		net-libs/xulrunner:1.9
		>=dev-libs/nspr-4.6.6
		>=dev-libs/nss-3.11-r1
	)
	opengl? ( virtual/opengl )
	webdav? ( net-libs/neon )
"

RDEPEND="${COMMON_DEPEND}
	!app-office/libreoffice-bin
	!app-office/openoffice-bin
	!app-office/openoffice
	java? ( >=virtual/jre-1.5 )
	${SPELL_DIRS_DEPEND}
	x11-themes/sabayon-artwork-loo
"

DEPEND="${COMMON_DEPEND}
	>=dev-libs/boost-1.36
	>=dev-libs/libxml2-2.0
	dev-libs/libxslt
	dev-perl/Archive-Zip
	dev-util/cppunit
	>=dev-util/gperf-3
	dev-util/intltool
	dev-util/mdds
	dev-util/pkgconfig
	media-gfx/sane-backends
	>=net-misc/curl-7.12
	>=sys-apps/findutils-4.1.20-r1
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
	"${FILESDIR}/${PN}-3.4.1-salfix.diff"
	"${FILESDIR}/sdext-presenter.diff"
	"${FILESDIR}/${PN}-svx.patch"
	"${FILESDIR}/${PN}-vbaobj-visibility-fix.patch"
	"${FILESDIR}/${PN}-solenv-build-crash.patch"
	"${FILESDIR}/${PN}-as-needed-gtk.patch"
	"${FILESDIR}/${PN}-fix-sandbox-install.patch"
	"${FILESDIR}/${PN}-translate-toolkit-parallel-solenv.patch"
	"${FILESDIR}/${PN}-gbuild-use-cxxflags.patch"
	"${FILESDIR}/${PN}-installed-files-permissions.patch"
	"${FILESDIR}/${PN}-check-for-avx.patch"
	"${FILESDIR}/${PN}-append-no-avx.patch"
	"${FILESDIR}/${PN}-32b-qt4-libdir.patch"
	"${FILESDIR}/${PN}-binfilter-as-needed.patch"
)

# Uncoment me when updating to eapi4
# REQUIRED_USE="
#	|| ( gtk gnome kde )
#	gnome? ( gtk )
#	nsplugin? ( gtk )
#"

S="${WORKDIR}/${PN}-bootstrap-${PV}"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
	kde4-base_pkg_setup

	python_set_active_version 2
	python_pkg_setup

	if [[ $(gcc-major-version) -lt 4 ]]; then
		eerror "Compilation with gcc older than 4.0 is not supported"
		die "Too old gcc found."
	fi

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

	ewarn "Libreoffice compilation often fails on parallel issues"
	ewarn "but the slowdown by enforcing MAKEOPTS=-j1 is too huge."
	ewarn "If you encounter errors try yourself to disable parallel build."

	# Check if we have enough RAM and free diskspace to build this beast
	CHECKREQS_MEMORY="1024"
	use debug && CHECKREQS_DISK_BUILD="15360" || CHECKREQS_DISK_BUILD="9216"
	check_reqs
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

	# copy extension templates; o what fun ...
	if use templates; then
		dest="${S}/extras/source/extensions"
		mkdir -p "${dest}"

		for template in ${TDEPEND}; do
			if [[ ${template} == *.oxt ]]; then
				tmplfile="${DISTDIR}/$(basename ${template})"
				tmplname="$(echo "${template}" | \
					cut -f 2- -s -d - | cut -f 1 -d _)"
				echo ">>> Unpacking ${tmplfile/\*/} to ${dest}"
				if [[ -f ${tmplfile} && ! -f "${dest}/${tmplname}.oxt" ]]; then
					cp -v "${tmplfile}" "${dest}/${tmplname}.oxt" || die
				fi
			fi
		done
	fi
}

src_prepare() {
	strip-linguas ${LANGUAGES}

	LO_LANGUAGES="en-US"

	# Now for our optimization flags ...
	export ARCH_FLAGS="${CXXFLAGS}"
	use debug || export LINKFLAGSOPTIMIZE="${LDFLAGS}"

	# compiler flags
	use custom-cflags || strip-flags
	use debug || filter-flags "-g*"
	# silent miscompiles; LO/OOo adds -O2/1/0 where appropriate
	filter-flags "-O*"

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
		--enable-ext-pdfimport
		--enable-ext-presenter-console
		--enable-ext-presenter-minimizer
	"

	# hsqldb: requires just 1.8.0 not 1.8.1 which we don't ship at all
	# dmake: not worth of splitting out
	internal_libs+="
		--without-system-hsqldb
	"

	# When building without java some things needs to be done
	# as internal libraries.
	if ! use java; then
		internal_libs+="
			--without-system-beanshell
			--without-system-lucene
			--without-system-saxon
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
		--with-system-headers \
		--with-system-libs \
		--with-system-jars \
		--with-system-db \
		--with-system-dicts \
		--enable-cairo \
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
		--disable-online-update \
		--disable-pch \
		--disable-rpath \
		--disable-static-gtk \
		--disable-strip-solver \
		--disable-zenity \
		--with-alloc=system \
		--with-build-version="Sabayon official package" \
		--with-extension-integration \
		--with-external-dict-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-hyph-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-thes-dir="${EPREFIX}/usr/share/myspell" \
		--with-external-tar="${DISTDIR}" \
		--with-lang="${LO_LANGUAGES}" \
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
		$(use_enable binfilter) \
		$(use_enable cups) \
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
		$(use_enable ldap) \
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
		$(use_with ldap openldap) \
		$(use_with mysql system-mysql-cppconn) \
		$(use_with nsplugin system-mozilla libxul) \
		$(use_with offlinehelp helppack-integration) \
		$(use_with templates sun-templates) \
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
