# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/openoffice/openoffice-3.2.1.ebuild,v 1.2 2010/06/22 20:00:18 arfrever Exp $

WANT_AUTOMAKE="1.9"
EAPI="3"
KDE_REQUIRED="optional"
CMAKE_REQUIRED="never"
PYTHON_DEPEND="2"
PYTHON_USE_WITH="threads"

inherit autotools bash-completion check-reqs db-use eutils fdo-mime flag-o-matic java-pkg-opt-2 kde4-base multilib python toolchain-funcs

IUSE="binfilter cups dbus debug eds gnome +gstreamer gtk kde ldap nsplugin odk opengl pam templates"

MY_PV=3.2.1.5
PATCHLEVEL=OOO320
SRC=OOo_${PV}_src
MST=OOO320_m19
DEVPATH=http://download.services.openoffice.org/files/stable/${PV}/${SRC}
S=${WORKDIR}/ooo
S_OLD=${WORKDIR}/ooo-build-${MY_PV}
CONFFILE=${S}/distro-configs/Gentoo.conf.in
BASIS=basis3.2
DESCRIPTION="OpenOffice.org, a full office productivity suite."

SRC_URI="${DEVPATH}_core.tar.bz2
	${DEVPATH}_extensions.tar.bz2
	${DEVPATH}_system.tar.bz2
	${DEVPATH}_l10n.tar.bz2
	binfilter? ( ${DEVPATH}_binfilter.tar.bz2 )
	templates? ( http://extensions.services.openoffice.org/files/273/0/Sun_ODF_Template_Pack_en-US.oxt
		http://extensions.services.openoffice.org/files/295/1/Sun_ODF_Template_Pack_de.oxt
		http://extensions.services.openoffice.org/files/299/0/Sun_ODF_Template_Pack_it.oxt
		http://extensions.services.openoffice.org/files/297/0/Sun_ODF_Template_Pack_fr.oxt
		http://extensions.services.openoffice.org/files/301/1/Sun_ODF_Template_Pack_es.oxt
		ftp://ftp.devall.hu/kami/go-oo//Sun_ODF_Template_Pack_hu.oxt )
	http://download.go-oo.org/${PATCHLEVEL}/ooo-build-${MY_PV}.tar.gz
	odk? ( java? ( http://tools.openoffice.org/unowinreg_prebuild/680/unowinreg.dll ) )
	http://download.go-oo.org/SRC680/extras-3.tar.bz2
	http://download.go-oo.org/SRC680/biblio.tar.bz2
	http://download.go-oo.org/SRC680/lp_solve_5.5.0.12_source.tar.gz
	http://download.go-oo.org/DEV300/scsolver.2008-10-30.tar.bz2
	http://download.go-oo.org/DEV300/ooo_oxygen_images-2009-06-17.tar.gz
	http://download.go-oo.org/SRC680/libwps-0.1.2.tar.gz
	http://multidimalgorithm.googlecode.com/files/mdds_0.3.0.tar.bz2"

LANGS="en en_US"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

HOMEPAGE="http://go-oo.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"

COMMON_DEPEND="!app-office/openoffice-bin
	x11-libs/libXaw
	x11-libs/libXinerama
	x11-libs/libXrandr
	>=dev-lang/perl-5.0
	>=dev-libs/glib-2.18
	dbus? ( >=dev-libs/dbus-glib-0.71 )
	gnome? ( >=x11-libs/gtk+-2.10
		>=gnome-base/gconf-2.0
		>=gnome-base/gnome-vfs-2.6
		>=x11-libs/cairo-1.0.2 )
	gtk? ( >=x11-libs/gtk+-2.10
		>=x11-libs/cairo-1.0.2 )
	eds? ( >=gnome-extra/evolution-data-server-1.2 )
	gstreamer? ( >=media-libs/gstreamer-0.10
			>=media-libs/gst-plugins-base-0.10 )
	java? ( >=dev-java/bsh-2.0_beta4
		>=dev-db/hsqldb-1.8.0.9
		dev-java/lucene:2.3
		dev-java/lucene-analyzers:2.3
		dev-java/rhino:1.5 )
	nsplugin? ( net-libs/xulrunner:1.9
		>=dev-libs/nspr-4.6.6
		>=dev-libs/nss-3.11-r1 )
	opengl? ( virtual/opengl
		virtual/glu )
	>=net-libs/neon-0.24.7
	>=dev-libs/openssl-0.9.8g
	>=media-libs/freetype-2.1.10-r2
	>=media-libs/fontconfig-2.3.0
	cups? ( net-print/cups )
	media-libs/jpeg
	media-libs/libpng
	app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.1.4-r1
	dev-libs/expat
	>=dev-libs/icu-4.0
	>=sys-libs/db-4.3
	>=app-text/libwpd-0.8.8
	>=media-libs/vigra-1.4
	>=app-text/poppler-0.12.3-r3[xpdf-headers]
	>=media-libs/libwpg-0.1.3"

RDEPEND="java? ( >=virtual/jre-1.5 )
	${SPELL_DIRS_DEPEND}
	${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	x11-libs/libXrender
	x11-libs/libXtst
	x11-proto/printproto
	x11-proto/xextproto
	x11-proto/xproto
	x11-proto/xineramaproto
	>=sys-apps/findutils-4.1.20-r1
	dev-perl/Archive-Zip
	dev-util/pkgconfig
	dev-util/intltool
	>=dev-libs/boost-1.36
	sys-devel/flex
	sys-devel/bison
	dev-libs/libxslt
	>=dev-libs/libxml2-2.0
	>=dev-util/gperf-3
	>=net-misc/curl-7.12
	sys-libs/zlib
	sys-apps/coreutils
	pam? ( sys-libs/pam
		sys-apps/shadow[pam] )
	java? ( || ( =virtual/jdk-1.6* =virtual/jdk-1.5* )
		>=dev-java/ant-core-1.7 )
	ldap? ( net-nds/openldap )"

PROVIDE="virtual/ooo"

PDEPEND="x11-themes/sabayon-artwork-ooo"

pkg_setup() {

	ewarn
	ewarn " It is important to note that OpenOffice.org is a very fragile  "
	ewarn " build when it comes to CFLAGS.  A number of flags have already "
	ewarn " been filtered out.  If you experience difficulty merging this  "
	ewarn " package and use aggressive CFLAGS, lower the CFLAGS and try to  "
	ewarn " merge again. "
	ewarn
	ewarn " Also if you experience a build break, please make sure to retry "
	ewarn " with MAKEOPTS="-j1" before filing a bug. "
	ewarn

	# Check if we have enough RAM and free diskspace to build this beast
	CHECKREQS_MEMORY="512"
	use debug && CHECKREQS_DISK_BUILD="12288" || CHECKREQS_DISK_BUILD="6144"
	check_reqs

	strip-linguas ${LANGS}

	# en_US is built by default, upstream needs us to use --with-lang="" in this case though, so strip it out
	export LINGUAS_OOO=""

	if use !java; then
		ewarn " You are building with java-support disabled, this results in some "
		ewarn " of the OpenOffice.org functionality being disabled. "
		ewarn " If something you need does not work for you, rebuild with "
		ewarn " java in your USE-flags. "
		ewarn
	fi

	if use !gtk && use !gnome; then
		ewarn " If you want the OpenOffice.org systray quickstarter to work "
		ewarn " activate either the 'gtk' or 'gnome' use flags. "
		ewarn
	fi

	if is-flagq -ffast-math ; then
		eerror " You are using -ffast-math, which is known to cause problems. "
		eerror " Please remove it from your CFLAGS, using this globally causes "
		eerror " all sorts of problems. "
		eerror " After that you will also have to - at least - rebuild python otherwise "
		eerror " the openoffice build will break. "
		die
	fi

	java-pkg-opt-2_pkg_setup

	# sys-libs/db version used
	local db_ver=$(db_findver '>=sys-libs/db-4.3')

	kde4-base_pkg_setup

	python_set_active_version 2
	python_pkg_setup

}

src_unpack() {

	unpack ooo-build-${MY_PV}.tar.gz

}

src_prepare() {

	# Hackish workaround for overlong path problem, see bug #130837
	mv "${S_OLD}" "${S}" || die

	#Some fixes for our patchset
	cd "${S}"
	epatch "${FILESDIR}/gentoo-${PV}.diff"
	epatch "${FILESDIR}/gentoo-pythonpath.diff"
	epatch "${FILESDIR}/ooo-env_log.diff"
	cp -f "${FILESDIR}/qt-use-native-backend.diff" "${S}/patches/hotfixes" || die
	cp -f "${FILESDIR}/neon-remove-SSPI-support.diff" "${S}/patches/hotfixes" || die

	#Use flag checks
	if use java ; then
		echo "--with-ant-home=${ANT_HOME}" >> ${CONFFILE}
		echo "--with-jdk-home=$(java-config --jdk-home 2>/dev/null)" >> ${CONFFILE}
		echo "--with-java-target-version=$(java-pkg_get-target)" >> ${CONFFILE}
		echo "--with-jvm-path=/usr/$(get_libdir)/" >> ${CONFFILE}
		echo "--with-system-beanshell" >> ${CONFFILE}
		echo "--with-system-hsqldb" >> ${CONFFILE}
		echo "--with-system-lucene" >> ${CONFFILE}
		echo "--with-system-rhino" >> ${CONFFILE}
		echo "--with-beanshell-jar=$(java-pkg_getjar bsh bsh.jar)" >> ${CONFFILE}
		echo "--with-hsqldb-jar=$(java-pkg_getjar hsqldb hsqldb.jar)" >> ${CONFFILE}
		echo "--with-lucene-core-jar=$(java-pkg_getjar lucene-2.3 lucene-core.jar)" >> ${CONFFILE}
		echo "--with-lucene-analyzers-jar=$(java-pkg_getjar lucene-analyzers-2.3 lucene-analyzers.jar)" >> ${CONFFILE}
		echo "--with-rhino-jar=$(java-pkg_getjar rhino-1.5 js.jar)" >> ${CONFFILE}
	fi

	echo $(use_enable nsplugin mozilla) >> ${CONFFILE}
	echo $(use_with nsplugin system-mozilla libxul) >> ${CONFFILE}

	echo $(use_enable binfilter) >> ${CONFFILE}
	echo $(use_enable cups) >> ${CONFFILE}
	echo $(use_enable dbus) >> ${CONFFILE}
	echo $(use_enable eds evolution2) >> ${CONFFILE}
	echo $(use_enable gnome gconf) >> ${CONFFILE}
	echo $(use_enable gnome gnome-vfs) >> ${CONFFILE}
	#gio support still gives crashes, see i#108993
	echo "--disable-gio" >> ${CONFFILE}
	echo $(use_enable gnome lockdown) >> ${CONFFILE}
	echo $(use_enable gstreamer) >> ${CONFFILE}
	echo $(use_enable gtk systray) >> ${CONFFILE}
	echo $(use_enable ldap) >> ${CONFFILE}
	echo $(use_enable opengl) >> ${CONFFILE}
	echo $(use_with ldap openldap) >> ${CONFFILE}
	echo $(use_enable debug crashdump) >> ${CONFFILE}
	echo $(use_enable debug strip-solver) >> ${CONFFILE}

	# Extension stuff
	echo "--with-extension-integration" >> ${CONFFILE}
	echo "--enable-minimizer" >> ${CONFFILE}
	echo "--enable-pdfimport" >> ${CONFFILE}
	echo "--enable-presenter-console" >> ${CONFFILE}

	echo "--without-writer2latex" >> ${CONFFILE}

	# Use splash screen without Sun logo
	echo "--with-intro-bitmaps=\\\"${S}/build/${MST}/ooo_custom_images/nologo/introabout/intro.png\\\"" >> ${CONFFILE}

	# Upstream this, disabled for now #i108911
	#echo "--with-system-redland" >> ${CONFFILE}

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

	# Compile problems with these ...
	filter-flags "-funroll-loops"
	filter-flags "-fprefetch-loop-arrays"
	filter-flags "-fno-default-inline"
	filter-flags "-ftracer"
	filter-flags "-fforce-addr"

	filter-flags "-O[s2-9]"

	if [[ $(gcc-major-version) -lt 4 ]]; then
		filter-flags "-fstack-protector"
		filter-flags "-fstack-protector-all"
		replace-flags "-fomit-frame-pointer" "-momit-leaf-frame-pointer"
	fi

	# Build with NVidia cards breaks otherwise
	use opengl && append-flags "-DGL_GLEXT_PROTOTYPES"

	# Now for our optimization flags ...
	export ARCH_FLAGS="${CXXFLAGS}"
	use debug || export LINKFLAGSOPTIMIZE="${LDFLAGS}"

	# Make sure gnome-users get gtk-support
	local GTKFLAG="--disable-gtk --disable-cairo --without-system-cairo"
	{ use gtk || use gnome; } && GTKFLAG="--enable-gtk --enable-cairo --with-system-cairo"

	cd "${S}"
	./configure --with-distro="Gentoo" \
		--with-arch="${ARCH}" \
		--with-srcdir="${DISTDIR}" \
		--with-lang="${LINGUAS_OOO}" \
		--with-num-cpus="${JOBS}" \
		--without-binsuffix \
		--with-installed-ooo-dirname="openoffice" \
		--with-tag="${MST}" \
		--with-drink="True Blood" \
		--without-git \
		--without-split \
		${GTKFLAG} \
		--disable-mono \
		--disable-kde \
		$(use_enable kde kde4) \
		$(use_enable !debug strip) \
		$(use_enable odk) \
		$(use_enable pam) \
		$(use_with java) \
		$(use_with templates sun-templates) \
		--disable-access \
		--disable-post-install-scripts \
		--enable-extensions \
		--with-system-libwpd \
		--with-system-libwpg \
		--mandir=/usr/share/man \
		--libdir=/usr/$(get_libdir) \
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
	chown -RP root:0 "${D}"

	# record java libraries
	if use java; then
			java-pkg_regjar "${D}"/usr/$(get_libdir)/openoffice/${BASIS}/program/classes/*.jar
			java-pkg_regjar "${D}"/usr/$(get_libdir)/openoffice/ure/share/java/*.jar
	fi

	# Upstream places the bash-completion module in /etc. Gentoo places them in
	# /usr/share/bash-completion. bug 226061
	dobashcompletion "${D}"/etc/bash_completion.d/ooffice.sh ooffice
	rm -rf "${D}"/etc/bash_completion.d/ || die "rm failed"

	# Remove files provided by x11-themes/sabayon-artwork-ooo
	rm -rf "${D}"/usr/$(get_libdir)/openoffice/program/intro*.bmp || die "intro.bmp rm failed"
	rm -rf "${D}"/usr/$(get_libdir)/openoffice/program/about*.bmp || die "about.bmp rm failed"
	rm -rf "${D}"/usr/$(get_libdir)/openoffice/program/intro*.png || die "intro.png rm failed"
	rm -rf "${D}"/usr/$(get_libdir)/openoffice/program/about*.png || die "about.png rm failed"
	rm -rf "${D}"/usr/$(get_libdir)/openoffice/program/sofficerc || die "sofficerc rm failed"

	# Fix NFS file locking issue, hacky fix while waiting for upstream
	sed -i 's/export SAL_ENABLE_FILE_LOCKING//' "${D}"/usr/bin/soffice || die "cannot fix NFS file locking"

}

pkg_postinst() {

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	BASHCOMPLETION_NAME=ooffice && bash-completion_pkg_postinst

	( [[ -x /sbin/chpax ]] || [[ -x /sbin/paxctl ]] ) && [[ -e /usr/$(get_libdir)/openoffice/program/soffice.bin ]] && scanelf -Xzm /usr/$(get_libdir)/openoffice/program/soffice.bin

	# Add available & useful jars to openoffice classpath
	use java && /usr/$(get_libdir)/openoffice/${BASIS}/program/java-set-classpath $(java-config --classpath=jdbc-mysql 2>/dev/null) >/dev/null

	elog " Some aditional functionality can be installed via Extension Manager: "
	elog " *) PDF Import "
	elog " *) Presentation Console "
	elog " *) Presentation Minimizer "
	elog
	elog " Please use the packages provided in "
	elog " /usr/$(get_libdir)/openoffice/share/extension/install/ "
	elog " instead of those from the SUN extension site. "
	elog

	kde4-base_pkg_postinst

}
