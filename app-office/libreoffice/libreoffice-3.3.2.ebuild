# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/libreoffice/libreoffice-3.3.2.ebuild,v 1.1 2011/03/22 21:01:09 suka Exp $

EAPI="3"

WANT_AUTOMAKE="1.9"

KDE_REQUIRED="optional"
CMAKE_REQUIRED="never"

PYTHON_DEPEND="2"
PYTHON_USE_WITH="threads"

inherit autotools bash-completion check-reqs db-use eutils fdo-mime flag-o-matic gnome2-utils java-pkg-opt-2 kde4-base multilib pax-utils python toolchain-funcs

IUSE="binfilter cups -custom-cflags dbus debug eds gnome gstreamer gtk kde ldap nsplugin odk opengl templates"

MY_PV=3.3.2.2
MY_P="${PN}-build-${MY_PV}"
PATCHLEVEL=OOO320
SRC=OOo_${PV}_src
S="${WORKDIR}/${MY_P}"
DEVPATH="http://download.documentfoundation.org/libreoffice/src"
CONFFILE=${S}/distro-configs/Gentoo.conf.in
BASIS=basis3.3

DESCRIPTION="LibreOffice, a full office productivity suite."
HOMEPAGE="http://www.libreoffice.org"
SRC_URI="${DEVPATH}/${PN}-build-${MY_PV}.tar.gz
	templates? (
		http://extensions.services.openoffice.org/files/273/0/Sun_ODF_Template_Pack_en-US.oxt
		http://extensions.services.openoffice.org/files/295/1/Sun_ODF_Template_Pack_de.oxt
		http://extensions.services.openoffice.org/files/299/0/Sun_ODF_Template_Pack_it.oxt
		http://extensions.services.openoffice.org/files/297/0/Sun_ODF_Template_Pack_fr.oxt
		http://extensions.services.openoffice.org/files/301/1/Sun_ODF_Template_Pack_es.oxt
		ftp://ftp.devall.hu/kami/go-oo//Sun_ODF_Template_Pack_hu.oxt
		)
	odk? ( java? ( http://tools.openoffice.org/unowinreg_prebuild/680/unowinreg.dll ) )
	http://download.go-oo.org/SRC680/extras-3.1.tar.bz2
	http://download.go-oo.org/SRC680/biblio.tar.bz2"

# Shiny split sources with so many packages...
MODULES="artwork base bootstrap calc components extensions extras filters help
impress libs-core libs-extern libs-extern-sys libs-gui postprocess sdk testing
ure writer l10n"

for mod in ${MODULES}; do
	SRC_URI+=" ${DEVPATH}/${PN}-${mod}-${MY_PV}.tar.bz2"
done

# addons
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/128cfc86ed5953e57fe0f5ae98b62c2e-libtextcat-2.2.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/17410483b5b5f267aa18b7e00b65e6e0-hsqldb_1_8_0.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/1756c4fa6c616ae15973c104cd8cb256-Adobe-Core35_AFMs-314.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/18f577b374d60b3c760a3a3350407632-STLport-4.5.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/1f24ab1d39f4a51faf22244c94a6203f-xmlsec1-1.2.14.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/24be19595acad0a2cae931af77a0148a-LICENSE_source-9.0.0.7-bj.html"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/26b3e95ddf3d9c077c480ea45874b3b8-lp_solve_5.5.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/284e768eeda0e2898b0d5bf7e26a016e-raptor-1.4.18.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/2a177023f9ea8ec8bd00837605c5df1b-jakarta-tomcat-5.0.30-src.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/ca4870d899fd7e943ffc310a5421ad4d-liberation-fonts-ttf-1.06.0.20100721.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/35c94d2df8893241173de1d16b6034c0-swingExSrc.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/35efabc239af896dfb79be7ebdd6e6b9-gentiumbasic-fonts-1.10.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/377a60170e5185eb63d3ed2fae98e621-README_silgraphite-2.3.1.txt"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/39bb3fcea1514f1369fcfc87542390fd-sacjava-1.3.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/3ade8cfe7e59ca8e65052644fed9fca4-epm-3.7.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/48470d662650c3c074e1c3fabbc67bbd-README_source-9.0.0.7-bj.txt"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/4a660ce8466c9df01f19036435425c3a-glibc-2.1.3-stub.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/599dc4cc65a07ee868cf92a667a913d2-xpdf-3.02.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/5aba06ede2daa9f2c11892fbd7bc3057-libserializer.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/7376930b0d3f3d77a685d94c4a3acda8-STLport-4.5-0119.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/79600e696a98ff95c2eba976f7a8dfbb-liblayout.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/798b2ffdc8bcfe7bca2cf92b62caf685-rhino1_5R5.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/8294d6c42e3553229af9934c5c0ed997-stax-api-1.0-2-sources.jar"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/8ea307d71d11140574bfb9fcc2487e33-libbase.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/a06a496d7a43cbdc35e69dbe678efadb-libloader.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/a4d9b30810a434a3ed39fc0003bbd637-LICENSE_stax-api-1.0-2-sources.html"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/a7983f859eafb2677d7ff386a023bc40-xsltml_2.1.2.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/ada24d37d8d638b3d8a9985e80bc2978-source-9.0.0.7-bj.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/bc702168a2af16869201dbe91e46ae48-LICENSE_Python-2.6.1"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/c441926f3a552ed3e5b274b62e86af16-STLport-4.0.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/d0b5af6e408b8d2958f3d83b5244f5e8-hyphen-2.4.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/d1a3205871c3c52e8a50c9f18510ae12-libformula.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/d4c4d91ab3a8e52a2e69d48d34ef4df4-core.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/dbb3757275dc5cc80820c0b4dd24ed95-librepository.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/e0707ff896045731ff99e99799606441-README_db-4.7.25.NC-custom.txt"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/f3e2febd267c8e4b13df00dac211dd6d-flute.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/f7925ba8491fe570e5164d2c72791358-libfonts.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/fb7ba5c2182be4e73748859967455455-README_stax-api-1.0-2-sources.txt"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/fdb27bfe2dbe2e7b57ae194d9bf36bab-SampleICC-1.3.2.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/37282537d0ed1a087b1c8f050dc812d9-dejavu-fonts-ttf-2.32.zip"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/067201ea8b126597670b5eff72e1f66c-mythes-1.2.0.tar.gz"
ADDONS_SRC+=" http://hg.services.openoffice.org/binaries/cf8a6967f7de535ae257fa411c98eb88-mdds_0.3.0.tar.bz2"
ADDONS_SRC+=" http://download.go-oo.org/src/47e1edaa44269bc537ae8cabebb0f638-JLanguageTool-1.0.0.tar.bz2"
ADDONS_SRC+=" http://download.go-oo.org/src/90401bca927835b6fbae4a707ed187c8-nlpsolver-0.9.tar.bz2"
ADDONS_SRC+=" http://download.go-oo.org/src/0f63ee487fda8f21fafa767b3c447ac9-ixion-0.2.0.tar.gz"
ADDONS_SRC+=" http://download.go-oo.org/extern/185d60944ea767075d27247c3162b3bc-unowinreg.dll"
ADDONS_SRC+=" http://download.go-oo.org/src/5ff846847dab351604ad859e2fd4ed3c-libwpd-0.9.1.tar.bz2"
ADDONS_SRC+=" http://download.go-oo.org/src/5ba6a61a2f66dfd5fee8cdd4cd262a37-libwpg-0.2.0.tar.bz2"
ADDONS_SRC+=" http://download.go-oo.org/src/9e436bff44c60dc8b97cba0c7fc11a5c-libwps-0.2.0.tar.bz2"
ADDONS_SRC+=" http://www.numbertext.org/linux/881af2b7dca9b8259abbca00bbbc004d-LinLibertineG-20110101.zip"
SRC_URI+=" ${ADDONS_SRC}"

LANGS="en en_US"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"

COMMON_DEPEND="!app-office/libreoffice-bin
	!app-office/openoffice-bin
	!app-office/openoffice
	cups? ( net-print/cups )
	dbus? ( >=dev-libs/dbus-glib-0.71 )
	eds? ( >=gnome-extra/evolution-data-server-1.2 )
	gnome? ( >=x11-libs/gtk+-2.10:2
		gnome-base/gconf:2 )
	gtk? ( >=x11-libs/gtk+-2.10:2 )
	gstreamer? ( >=media-libs/gstreamer-0.10
			>=media-libs/gst-plugins-base-0.10 )
	java? ( >=dev-java/bsh-2.0_beta4
		dev-java/lucene:2.3
		dev-java/lucene-analyzers:2.3 )
	ldap? ( net-nds/openldap )
	nsplugin? ( net-libs/xulrunner:1.9
		>=dev-libs/nspr-4.6.6
		>=dev-libs/nss-3.11-r1 )
	opengl? ( virtual/opengl )
	app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.1.4-r1
	>=app-text/poppler-0.12.3-r3[xpdf-headers]
	dev-libs/expat
	>=dev-libs/glib-2.18
	>=dev-libs/icu-4.0
	>=dev-lang/perl-5.0
	>=net-libs/neon-0.24.7
	>=dev-libs/openssl-0.9.8g
	dev-libs/redland[ssl]
	>=media-libs/freetype-2.1.10-r2
	>=media-libs/fontconfig-2.3.0
	>=media-libs/vigra-1.4
	media-libs/libpng
	>=sys-libs/db-4.3
	virtual/jpeg
	>=x11-libs/cairo-1.0.2
	x11-libs/libXaw
	x11-libs/libXinerama
	x11-libs/libXrandr"

RDEPEND="java? ( >=virtual/jre-1.5 )
	${SPELL_DIRS_DEPEND}
	${COMMON_DEPEND}
	x11-themes/sabayon-artwork-loo"

DEPEND="${COMMON_DEPEND}
	java? ( || ( =virtual/jdk-1.6* =virtual/jdk-1.5* )
		>=dev-java/ant-core-1.7 )
	>=dev-libs/boost-1.36
	>=dev-libs/libxml2-2.0
	dev-perl/Archive-Zip
	dev-libs/libxslt
	dev-util/cppunit
	>=dev-util/gperf-3
	dev-util/intltool
	dev-util/pkgconfig
	>=net-misc/curl-7.12
	>=sys-apps/findutils-4.1.20-r1
	sys-devel/bison
	sys-apps/coreutils
	sys-devel/flex
	sys-libs/zlib
	x11-libs/libXrender
	x11-libs/libXtst
	x11-proto/printproto
	x11-proto/xextproto
	x11-proto/xineramaproto
	x11-proto/xproto"

pkg_setup() {

	java-pkg-opt-2_pkg_setup

	# sys-libs/db version used
	local db_ver=$(db_findver '>=sys-libs/db-4.3')

	kde4-base_pkg_setup

	python_set_active_version 2
	python_pkg_setup

}

src_unpack() {

	unpack ${MY_P}.tar.gz

}

src_prepare() {

	if use custom-cflags; then
		ewarn " You are using custom CFLAGS, which is NOT supported and can cause "
		ewarn " all sorts of build and runtime errors. "
		ewarn
		ewarn " Before reporting a bug, please make sure you rebuild and try with "
		ewarn " basic CFLAGS, otherwise the bug will not be accepted. "
		ewarn
	fi

	ewarn
	ewarn " If you experience a build break, please make sure to retry "
	ewarn " with MAKEOPTS="-j1" before filing a bug. "
	ewarn

	# Check if we have enough RAM and free diskspace to build this beast
	CHECKREQS_MEMORY="512"
	use debug && CHECKREQS_DISK_BUILD="12288" || CHECKREQS_DISK_BUILD="7144"
	check_reqs

	strip-linguas ${LANGS}

	export LINGUAS_OOO=""

	if use !java; then
		ewarn " You are building with java-support disabled, this results in some "
		ewarn " of the LibreOffice functionality being disabled. "
		ewarn " If something you need does not work for you, rebuild with "
		ewarn " java in your USE-flags. "
		ewarn
	fi

	if use !gtk && use !gnome; then
		ewarn " If you want the LibreOffice systray quickstarter to work "
		ewarn " activate either the 'gtk' or 'gnome' use flags. "
		ewarn
	fi

	# Some fixes for our patchset
	epatch "${FILESDIR}/gentoo-${PV}.diff"
	epatch "${FILESDIR}/gentoo-pythonpath.diff"
	epatch "${FILESDIR}/env_log.diff"
	epatch "${FILESDIR}/fix-ooo-collision.diff"
	epatch "${FILESDIR}/scrap-pixmap-links.diff"
	epatch "${FILESDIR}/enable-startup-notification.diff"
	use java && cp -f "${FILESDIR}/sdext-presenter.diff" "${S}/patches/hotfixes"
	cp -f "${FILESDIR}/${PN}-3.3.0_libxmlsec_fix_extern_c.diff" "${S}/patches/hotfixes"
	cp -f "${FILESDIR}/${PN}-3.3-libpng-1.5.diff" "${S}/patches/hotfixes"
	cp -f "${FILESDIR}/${PN}-3.3.1-neon_remove_SSPI_support.diff" "${S}/patches/hotfixes"
	cp -f "${FILESDIR}/${PN}-libdb5-fix-check.diff" "${S}/patches/hotfixes"

	#Use flag checks
	if use java ; then
		echo "--with-ant-home=${ANT_HOME}" >> ${CONFFILE}
		echo "--with-jdk-home=$(java-config --jdk-home 2>/dev/null)" >> ${CONFFILE}
		echo "--with-java-target-version=$(java-pkg_get-target)" >> ${CONFFILE}
		echo "--with-jvm-path=/usr/$(get_libdir)/" >> ${CONFFILE}
		echo "--with-system-beanshell" >> ${CONFFILE}
		echo "--with-system-lucene" >> ${CONFFILE}
		echo "--with-beanshell-jar=$(java-pkg_getjar bsh bsh.jar)" >> ${CONFFILE}
		echo "--with-lucene-core-jar=$(java-pkg_getjar lucene-2.3 lucene-core.jar)" >> ${CONFFILE}
		echo "--with-lucene-analyzers-jar=$(java-pkg_getjar lucene-analyzers-2.3 lucene-analyzers.jar)" >> ${CONFFILE}
	fi

	echo $(use_enable nsplugin mozilla) >> ${CONFFILE}
	echo $(use_with nsplugin system-mozilla libxul) >> ${CONFFILE}

	echo $(use_enable binfilter) >> ${CONFFILE}
	echo $(use_enable cups) >> ${CONFFILE}
	echo $(use_enable dbus) >> ${CONFFILE}
	echo $(use_enable eds evolution2) >> ${CONFFILE}
	echo $(use_enable gnome gconf) >> ${CONFFILE}
	echo $(use_enable gnome gio) >> ${CONFFILE}
	echo "--disable-gnome-vfs" >> ${CONFFILE}
	echo $(use_enable gnome lockdown) >> ${CONFFILE}
	echo $(use_enable gstreamer) >> ${CONFFILE}
	echo $(use_enable gtk systray) >> ${CONFFILE}
	echo $(use_enable ldap) >> ${CONFFILE}
	echo $(use_enable opengl) >> ${CONFFILE}
	echo $(use_with ldap openldap) >> ${CONFFILE}
	echo $(use_enable debug crashdump) >> ${CONFFILE}
	echo $(use_enable debug strip-solver) >> ${CONFFILE}

	# Extension stuff, disabled when building without java for bug #352812
	if use java; then
		echo "--with-extension-integration" >> ${CONFFILE}
		echo "--enable-pdfimport" >> ${CONFFILE}
		echo "--enable-minimizer" >> ${CONFFILE}
		echo "--enable-presenter-console" >> ${CONFFILE}
		echo "--enable-presenter-extra-ui" >> ${CONFFILE}
		#still necessary
		echo "--enable-presenter-screen" >> ${CONFFILE}
	fi

	# Misc stuff
	echo "--disable-graphite" >> ${CONFFILE}
	echo "--with-system-cppunit" >> ${CONFFILE}
	echo "--with-system-openssl" >> ${CONFFILE}
	echo "--with-system-redland" >> ${CONFFILE}
	echo "--without-junit" >> ${CONFFILE}

	#fix desktop files bug #352955
	sed -i 's/Exec=oo/Exec=lo/g' "${S}"/desktop/*.desktop.in.in || die "Could not fix desktop files"
	# Swap vendor to Sabayon
	sed -i '/--with-vendor=/ s/Gentoo Foundation/Sabayon Linux/' "${CONFFILE}"

	# needed for sun-templates patch
	eautoreconf

}

src_configure() {

	use kde && export KDE4DIR="${KDEDIR}"
	use kde && export QT4LIB="/usr/$(get_libdir)/qt4"

	# Use multiprocessing by default now, it gets tested by upstream
	export JOBS=$(echo "${MAKEOPTS}" | sed -e "s/.*-j\([0-9]\+\).*/\1/")

	# compiler flags
	use custom-cflags || strip-flags
	use debug || filter-flags "-g*"
	# silent miscompiles; LO/OOo adds -O2/1/0 where appropriate
	filter-flags "-O*"

	if [[ $(gcc-major-version) -lt 4 ]]; then
		filter-flags "-fstack-protector"
		filter-flags "-fstack-protector-all"
		replace-flags "-fomit-frame-pointer" "-momit-leaf-frame-pointer"
	fi

	# Now for our optimization flags ...
	export ARCH_FLAGS="${CXXFLAGS}"
	use debug || export LINKFLAGSOPTIMIZE="${LDFLAGS}"

	# Make sure gnome-users get gtk-support
	local GTKFLAG="--disable-gtk"
	{ use gtk || use gnome; } && GTKFLAG="--enable-gtk"

	cd "${S}"
	./configure --with-distro="Gentoo" \
		--prefix="${EPREFIX}"/usr \
		--sysconfdir="${EPREFIX}"/etc \
		--with-arch="${ARCH}" \
		--with-srcdir="${DISTDIR}" \
		--with-lang="${LINGUAS_OOO}" \
		--with-num-cpus="${JOBS}" \
		--without-binsuffix \
		--with-installed-ooo-dirname="libreoffice" \
		--with-drink="True Blood" \
		--without-git \
		--with-split \
		${GTKFLAG} \
		--enable-cairo \
		--with-system-cairo \
		--disable-mono \
		--disable-kde \
		$(use_enable kde kde4) \
		$(use_enable !debug strip) \
		$(use_enable odk) \
		$(use_with java) \
		$(use_with templates sun-templates) \
		--disable-access \
		--disable-post-install-scripts \
		$(use_enable java extensions) \
		--without-system-libwpd \
		--without-system-libwpg \
		--mandir="${EPREFIX}"/usr/share/man \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		|| die "Configuration failed!"

}

src_compile() {

	make || die "Build failed"

}

src_install() {

	export PYTHONPATH=""

	einfo "Preparing Installation"
	make DESTDIR="${D}" install || die "Installation failed!"

	# Fix the permissions for security reasons
	chown -RP root:0 "${ED}"

	# record java libraries
	if use java; then
			java-pkg_regjar "${ED}"/usr/$(get_libdir)/${PN}/${BASIS}/program/classes/*.jar
			java-pkg_regjar "${ED}"/usr/$(get_libdir)/${PN}/ure/share/java/*.jar
	fi

	# Upstream places the bash-completion module in /etc. Gentoo places them in
	# /usr/share/bash-completion. bug 226061
	dobashcompletion "${ED}"/etc/bash_completion.d/libreoffice.sh libreoffice
	rm -rf "${ED}"/etc/bash_completion.d/ || die "rm failed"

	# Remove files provided by x11-themes/sabayon-artwork-loo
	rm  "${ED}"/usr/$(get_libdir)/libreoffice/program/intro.png || die "intro.bmp rm failed"
	rm "${ED}"/usr/$(get_libdir)/libreoffice/program/about.png || die "about.png rm failed"
	rm "${ED}"/usr/$(get_libdir)/libreoffice/program/sofficerc || die "sofficerc rm failed"
}

pkg_preinst() {

	{ use gtk || use gnome; } && gnome2_icon_savelist

}

pkg_postinst() {

	# Cache updates
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	{ use gtk || use gnome; } && gnome2_icon_cache_update

	BASHCOMPLETION_NAME=libreoffice && bash-completion_pkg_postinst

	pax-mark -m "${EPREFIX}"/usr/$(get_libdir)/libreoffice/program/soffice.bin

	# Add available & useful jars to LibreOffice classpath
	use java && "${EPREFIX}"/usr/$(get_libdir)/${PN}/${BASIS}/program/java-set-classpath $(java-config --classpath=jdbc-mysql 2>/dev/null) >/dev/null

	kde4-base_pkg_postinst

}

pkg_postrm() {

	fdo-mime_desktop_database_update
	{ use gtk || use gnome; } && gnome2_icon_cache_update

}
