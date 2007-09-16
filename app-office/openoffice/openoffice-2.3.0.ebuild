# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

WANT_AUTOCONF="2.5"
WANT_AUTOMAKE="1.9"

inherit autotools check-reqs db-use eutils fdo-mime flag-o-matic java-pkg-opt-2 kde-functions mono multilib toolchain-funcs

IUSE="binfilter branding cairo cups dbus debug eds firefox gnome gstreamer gtk kde ldap mono sound odk pam seamonkey webdav"

MY_PV="2.3.0.1.2"
PATCHLEVEL="OOG680"
SRC="OOo_${PV}_src"
S="${WORKDIR}/ooo"
S_OLD="${WORKDIR}/ooo-build-${MY_PV}"
CONFFILE="${S}/distro-configs/Gentoo.conf.in"
DESCRIPTION="OpenOffice.org, a full office productivity suite."

SRC_URI="
	binfilter? ( mirror://openoffice/stable/${PV}/${SRC}_binfilter.tar.bz2 )
	http://go-oo.org/packages/OOG680/ooo-build-${MY_PV}.tar.gz
	odk? ( mirror://openoffice/stable/${PV}/${SRC}_sdk.tar.bz2
		java? ( http://tools.openoffice.org/unowinreg_prebuild/680/unowinreg.dll ) )
	http://go-oo.org/packages/${PATCHLEVEL}/cli_types.dll
	http://go-oo.org/packages/${PATCHLEVEL}/cli_types_bridgetest.dll
	http://go-oo.org/packages/SRC680/extras-2.tar.bz2
	http://go-oo.org/packages/SRC680/biblio.tar.bz2
	http://go-oo.org/packages/SRC680/hunspell_UNO_1.1.tar.gz
	http://go-oo.org/packages/xt/xt-20051206-src-only.zip
	http://go-oo.org/packages/SRC680/lp_solve_5.5.tar.gz
	http://go-oo.org/packages/SRC680/libwps-0.1.0~svn20070129.tar.gz
	http://go-oo.org/packages/SRC680/libwpg-0.1.0~cvs20070608.tar.gz
	http://go-oo.org/packages/${PATCHLEVEL}/oog680-m5-core.tar.bz2"

LANGS1="af ar as_IN be_BY bg bn br bs ca cs cy da de dz el en_GB en_ZA eo es et fa fi fr ga gl gu_IN he hi_IN hr hu it ja km ko ku lt lv mk ml_IN mr_IN nb ne nl nn nr ns or_IN pa_IN pl pt pt_BR ru rw sh_YU sk sl sr_CS ss st sv sw_TZ ta_IN te_IN tg th ti_ER tn tr ts uk ur_IN ve vi xh zh_CN zh_TW zu"
LANGS="${LANGS1} en en_US"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

for Y in ${LANGS1} ; do
	SRC_URI="${SRC_URI} linguas_${Y}? ( mirror://openoffice/stable/${PV}/${SRC}_l10n.tar.bz2 )"
done

HOMEPAGE="http://go-oo.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ppc -sparc x86"

COMMON_DEPEND="!app-office/openoffice-bin
	x11-libs/libXaw
	x11-libs/libXinerama
	>=dev-lang/perl-5.0
	dbus? ( >=dev-libs/dbus-glib-0.71 )
	gnome? ( >=x11-libs/gtk+-2.10
		>=gnome-base/gnome-vfs-2.6
		>=gnome-base/gconf-2.0 )
	gtk? ( >=x11-libs/gtk+-2.10 )
	cairo? ( >=x11-libs/cairo-1.0.2
		>=x11-libs/gtk+-2.10 )
	eds? ( >=gnome-extra/evolution-data-server-1.2 )
	gstreamer? ( >=media-libs/gstreamer-0.10
			>=media-libs/gst-plugins-base-0.10 )
	kde? ( >=kde-base/kdelibs-3.2 )
	java? ( >=dev-java/bsh-2.0_beta4
		>=dev-java/xalan-2.7
		>=dev-java/xerces-2.7
		=dev-java/xml-commons-external-1.3* )
	mono? ( >=dev-lang/mono-1.2.3.1 )
	firefox? ( >=www-client/mozilla-firefox-1.5-r9
		>=dev-libs/nspr-4.6.2
		>=dev-libs/nss-3.11-r1 )
	!firefox? ( seamonkey? ( www-client/seamonkey
		>=dev-libs/nspr-4.6.2
		>=dev-libs/nss-3.11-r1 ) )
	sound? ( >=media-libs/portaudio-18.1-r5
			>=media-libs/libsndfile-1.0.9 )
	webdav? ( >=net-misc/neon-0.24.7 )
	>=x11-libs/startup-notification-0.5
	>=media-libs/freetype-2.1.10-r2
	>=media-libs/fontconfig-2.2.0
	cups? ( net-print/cups )
	media-libs/jpeg
	media-libs/libpng
	sys-devel/flex
	sys-devel/bison
	app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.1.4-r1
	>=app-admin/eselect-oodict-20060706
	dev-libs/expat
	>=dev-libs/icu-3.4
	>=sys-libs/db-4.3
	>=dev-libs/STLport-5.1.2
	>=dev-libs/glib-2.12
	>=app-text/libwpd-0.8.8
	linguas_ja? ( >=media-fonts/kochi-substitute-20030809-r3 )
	linguas_zh_CN? ( >=media-fonts/arphicfonts-0.1-r2 )
	linguas_zh_TW? ( >=media-fonts/arphicfonts-0.1-r2 )"

RDEPEND="java? ( >=virtual/jre-1.4 )
	${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	x11-libs/libXrender
	x11-proto/printproto
	x11-proto/xextproto
	x11-proto/xproto
	x11-proto/xineramaproto
	>=sys-apps/findutils-4.1.20-r1
	dev-perl/Archive-Zip
	dev-perl/Compress-Zlib
	>=dev-perl/Compress-Raw-Zlib-2.002
	dev-util/pkgconfig
	dev-util/intltool
	>=dev-libs/boost-1.33.1
	>=net-misc/curl-7.9.8
	sys-libs/zlib
	sys-apps/coreutils
	pam? ( sys-libs/pam )
	!dev-util/dmake
	>=dev-lang/python-2.3.4
	java? ( || ( !amd64? ( =virtual/jdk-1.5* ) =virtual/jdk-1.4* )
		dev-java/ant-core )
	dev-libs/libxslt
	ldap? ( net-nds/openldap )
	>=dev-libs/libxml2-2.0"

PROVIDE="virtual/ooo"

if use amd64; then
	# All available Java 1.5 JDKs are broken, in one way or another, on amd64.
	# Thus we force the use of a Java 1.4 JDK on amd64 (and amd64 only).
	export JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4*"
fi

pkg_setup() {

	ewarn
	ewarn " It is important to note that OpenOffice.org is a very fragile  "
	ewarn " build when it comes to CFLAGS.  A number of flags have already "
	ewarn " been filtered out.  If you experience difficulty merging this  "
	ewarn " package and use agressive CFLAGS, lower the CFLAGS and try to  "
	ewarn " merge again. Also note that building OOo takes a lot of time and "
	ewarn " hardware ressources: 4-6 GB free diskspace and 256 MB RAM are "
	ewarn " the minimum requirements. If you have less, use openoffice-bin "
	ewarn " instead. "
	ewarn

	# Check if we have enough RAM and free diskspace to build this beast
	CHECKREQS_MEMORY="256"
	use debug && CHECKREQS_DISK_BUILD="8192" || CHECKREQS_DISK_BUILD="5120"
	check_reqs

	strip-linguas ${LANGS}

	if [[ -z "${LINGUAS}" ]]; then
		export LINGUAS_OOO="en-US"
		ewarn
		ewarn " To get a localized build, set the according LINGUAS variable(s). "
		ewarn
	else
		export LINGUAS_OOO=`echo ${LINGUAS} | \
			sed -e 's/\ben\b/en_US/g' -e 's/_/-/g'`
	fi

	if use !java; then
		ewarn " You are building with java-support disabled, this results in some "
		ewarn " of the OpenOffice.org functionality (i.e. help) being disabled. "
		ewarn " If something you need does not work for you, rebuild with "
		ewarn " java in your USE-flags. "
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
	local db_ver="$(db_findver '>=sys-libs/db-4.3')"

}

src_unpack() {

	unpack ooo-build-${MY_PV}.tar.gz

	# Hackish workaround for overlong path problem, see bug #130837
	mv ${S_OLD} ${S} || die

	#Some fixes for our patchset
	cd ${S}
	cp -f ${FILESDIR}/${PV}/swregion-gcc42.diff ${S}/patches/src680 || die
	epatch ${FILESDIR}/${PV}/gentoo-${PV}.diff
	epatch ${FILESDIR}/${PV}/ooo-env_log.diff

	if use ppc ; then
		cp -f ${FILESDIR}/${PV}/disable-regcomp-java.diff ${S}/patches/src680 || die
		cp -f ${FILESDIR}/${PV}/disable-regcomp-python.diff ${S}/patches/src680 || die
		epatch ${FILESDIR}/${PV}/regcompapply.diff
	fi

	#Use flag checks
	if use java ; then
		echo "--with-ant-home=${ANT_HOME}" >> ${CONFFILE}
		echo "--with-jdk-home=$(java-config --jdk-home 2>/dev/null)" >> ${CONFFILE}
		echo "--with-java-target-version=$(java-pkg_get-target)" >> ${CONFFILE}
		echo "--with-system-beanshell" >> ${CONFFILE}
		echo "--with-system-xalan" >> ${CONFFILE}
		echo "--with-system-xerces" >> ${CONFFILE}
		echo "--with-system-xml-apis" >> ${CONFFILE}
		echo "--with-beanshell-jar=$(java-pkg_getjar bsh bsh.jar)" >> ${CONFFILE}
		echo "--with-serializer-jar=$(java-pkg_getjar xalan serializer.jar)" >> ${CONFFILE}
		echo "--with-xalan-jar=$(java-pkg_getjar xalan xalan.jar)" >> ${CONFFILE}
		echo "--with-xerces-jar=$(java-pkg_getjar xerces-2 xercesImpl.jar)" >> ${CONFFILE}
		echo "--with-xml-apis-jar=$(java-pkg_getjar xml-commons-external-1.3 xml-apis.jar)" >> ${CONFFILE}
	fi

	use branding && echo "--with-intro-bitmaps=\\\"${S}/src/openintro_gentoo.bmp\\\"" >> ${CONFFILE}

	echo "`use_enable binfilter`" >> ${CONFFILE}

	if use firefox || use seamonkey ; then
		echo "--enable-mozilla" >> ${CONFFILE}
		echo "--with-system-mozilla" >> ${CONFFILE}
		echo "`use_with firefox`" >> ${CONFFILE}
		echo "`use_with seamonkey`" >> ${CONFFILE}
	else
		echo "--disable-mozilla" >> ${CONFFILE}
		echo "--without-system-mozilla" >> ${CONFFILE}
	fi

	echo "`use_enable cups`" >> ${CONFFILE}
	echo "`use_enable ldap`" >> ${CONFFILE}
	echo "`use_with ldap openldap`" >> ${CONFFILE}
	echo "`use_enable eds evolution2`" >> ${CONFFILE}
	echo "`use_enable gnome gnome-vfs`" >> ${CONFFILE}
	echo "`use_enable gnome lockdown`" >> ${CONFFILE}
	echo "`use_enable gnome atkbridge`" >> ${CONFFILE}
	echo "`use_enable gstreamer`" >> ${CONFFILE}
	echo "`use_enable dbus`" >> ${CONFFILE}
	echo "`use_enable webdav neon`" >> ${CONFFILE}
	echo "`use_with webdav system-neon`" >> ${CONFFILE}

	echo "`use_enable sound pasf`" >> ${CONFFILE}
	echo "`use_with sound system-portaudio`" >> ${CONFFILE}
	echo "`use_with sound system-sndfile`" >> ${CONFFILE}

	echo "`use_enable debug crashdump`" >> ${CONFFILE}

	eautoreconf

}

src_compile() {

	unset LIBC
	addpredict "/bin"
	addpredict "/root/.gconfd"
	addpredict "/root/.gnome"

	# Should the build use multiprocessing? Not enabled by default, as it tends to break
	export JOBS="1"
	if [[ "${WANT_MP}" == "true" ]]; then
		export JOBS=`echo "${MAKEOPTS}" | sed -e "s/.*-j\([0-9]\+\).*/\1/"`
	fi

	# Compile problems with these ...
	filter-flags "-funroll-loops"
	filter-flags "-fprefetch-loop-arrays"
	filter-flags "-fno-default-inline"
	filter-flags "-fstack-protector"
	filter-flags "-fstack-protector-all"
	filter-flags "-ftracer"
	filter-flags "-fforce-addr"
	replace-flags "-O?" "-O2"

	use ppc && append-flags "-D_STLP_STRICT_ANSI"

	# Now for our optimization flags ...
	export ARCH_FLAGS="${CXXFLAGS}"
	use debug || export LINKFLAGSOPTIMIZE="${LDFLAGS}"

	# Make sure gnome-users get gtk-support
	export GTKFLAG="`use_enable gtk`" && use gnome && GTKFLAG="--enable-gtk"

	cd ${S}
	./configure ${MYCONF} \
		--with-distro="Gentoo" \
		--with-arch="${ARCH}" \
		--with-srcdir="${DISTDIR}" \
		--with-lang="${LINGUAS_OOO}" \
		--with-num-cpus="${JOBS}" \
		--without-binsuffix \
		--with-installed-ooo-dirname="openoffice" \
		--with-tag="oog680-m5" \
		"${GTKFLAG}" \
		`use_enable kde` \
		`use_enable cairo` \
		`use_with cairo system-cairo` \
		`use_enable gnome quickstart` \
		`use_enable mono` \
		`use_enable pam` \
		`use_enable !debug strip` \
		`use_enable odk` \
		`use_with java` \
		--disable-access \
		--disable-post-install-scripts \
		--enable-hunspell \
		--with-system-hunspell \
		--with-system-libwpd \
		--mandir=/usr/share/man \
		--libdir=/usr/$(get_libdir) \
		|| die "Configuration failed!"

	einfo "Building OpenOffice.org..."
	use kde && set-kdedir 3
	make || die "Build failed"

}

src_install() {

	export PYTHONPATH=""

	einfo "Preparing Installation"
	make DESTDIR=${D} install || die "Installation failed!"

	# Fix the permissions for security reasons
	chown -R root:root ${D}

	# record java libraries
	use java && java-pkg_regjar ${D}/usr/$(get_libdir)/openoffice/program/classes/*.jar

}

pkg_postinst() {

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	eselect oodict update --libdir $(get_libdir)

	[[ -x /sbin/chpax ]] && [[ -e /usr/$(get_libdir)/openoffice/program/soffice.bin ]] && chpax -zm /usr/$(get_libdir)/openoffice/program/soffice.bin

	# Add available & useful jars to openoffice classpath
	use java && /usr/$(get_libdir)/openoffice/program/java-set-classpath $(java-config --classpath=jdbc-mysql 2>/dev/null) >/dev/null

	elog " To start OpenOffice.org, run:"
	elog
	elog " $ ooffice"
	elog
	elog " Also, for individual components, you can use any of:"
	elog
	elog " oobase, oocalc, oodraw, oofromtemplate, ooimpress, oomath,"
	elog " ooweb or oowriter"
	elog
	elog " Spell checking is now provided through our own myspell-ebuilds, "
	elog " if you want to use it, please install the correct myspell package "
	elog " according to your language needs. "

}
