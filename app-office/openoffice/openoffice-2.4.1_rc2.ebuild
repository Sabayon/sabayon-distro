# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

WANT_AUTOCONF="2.5"
WANT_AUTOMAKE="1.9"

inherit autotools check-reqs db-use eutils fdo-mime flag-o-matic java-pkg-opt-2 kde-functions mono multilib

IUSE="binfilter cups dbus debug eds firefox gnome gstreamer gtk kde ldap mono odk opengl pam seamonkey xulrunner"

MY_PV="2.4.1.3"
MY_PV2="2.4.1rc2"
PATCHLEVEL="OOH680"
SRC="OOo_${MY_PV2}_src"
MST="OOH680_m17"
S="${WORKDIR}/ooo"
S_OLD="${WORKDIR}/ooo-build-${MY_PV}"
CONFFILE="${S}/distro-configs/Gentoo.conf.in"
DESCRIPTION="OpenOffice.org, a full office productivity suite."

SRC_URI="mirror://openoffice/contrib/rc/${MY_PV2}/${SRC}_core.tar.bz2
	binfilter? ( mirror://openoffice/contrib/rc/${MY_PV2}/${SRC}_binfilter.tar.bz2 )
	http://download.go-oo.org/${PATCHLEVEL}/ooo-build-${MY_PV}.tar.gz
	odk? ( mirror://openoffice/contrib/rc/${MY_PV2}/${SRC}_sdk.tar.bz2
		java? ( http://tools.openoffice.org/unowinreg_prebuild/680/unowinreg.dll ) )
	http://download.go-oo.org/SRC680/extras-2.tar.bz2
	http://download.go-oo.org/SRC680/biblio.tar.bz2
	http://download.go-oo.org/SRC680/lp_solve_5.5.0.10_source.tar.gz
	http://download.go-oo.org/SRC680/libwps-0.1.2.tar.gz
	http://download.go-oo.org/SRC680/libwpg-0.1.2.tar.gz
	http://download.go-oo.org/SRC680/oox.2008-02-29.tar.bz2
	http://download.go-oo.org/SRC680/writerfilter.2008-02-29.tar.bz2"

HOMEPAGE="http://go-oo.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc -sparc ~x86"

COMMON_DEPEND="!app-office/openoffice-bin
	x11-libs/libXaw
	x11-libs/libXinerama
	>=dev-lang/perl-5.0
	dbus? ( >=dev-libs/dbus-glib-0.71 )
	gnome? ( >=x11-libs/gtk+-2.10
		>=gnome-base/gnome-vfs-2.6
		>=gnome-base/gconf-2.0
		>=x11-libs/cairo-1.0.2 )
	gtk? ( >=x11-libs/gtk+-2.10
		>=x11-libs/cairo-1.0.2 )
	eds? ( >=gnome-extra/evolution-data-server-1.2 )
	gstreamer? ( >=media-libs/gstreamer-0.10
			>=media-libs/gst-plugins-base-0.10 )
	kde? ( =kde-base/kdelibs-3* )
	java? ( >=dev-java/bsh-2.0_beta4
		>=dev-java/xalan-2.7
		>=dev-java/xalan-serializer-2.7
		>=dev-java/xerces-2.7
		=dev-java/xml-commons-external-1.3*
		>=dev-db/hsqldb-1.8.0.9
		=dev-java/rhino-1.5* )
	mono? ( >=dev-lang/mono-1.2.3.1 )
	opengl? ( virtual/opengl
		virtual/glu )
	xulrunner? ( >=net-libs/xulrunner-1.8
		>=dev-libs/nspr-4.6.6
		>=dev-libs/nss-3.11-r1 )
	!xulrunner? ( firefox? ( >=dev-libs/nspr-4.6.6
		>=dev-libs/nss-3.11-r1 ) )
	!xulrunner? ( !firefox? ( seamonkey? ( =www-client/seamonkey-1*
		>=dev-libs/nspr-4.6.6
		>=dev-libs/nss-3.11-r1 ) ) )
	>=net-misc/neon-0.24.7
	>=dev-libs/openssl-0.9.8g
	>=x11-libs/startup-notification-0.5
	>=media-libs/freetype-2.1.10-r2
	>=media-libs/fontconfig-2.3.0
	cups? ( net-print/cups )
	media-libs/jpeg
	media-libs/libpng
	app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.1.4-r1
	>=app-admin/eselect-oodict-20060706
	dev-libs/expat
	>=dev-libs/icu-3.8
	>=sys-libs/db-4.3
	>=app-text/libwpd-0.8.8
	>=media-libs/libsvg-0.1.4
	>=media-libs/vigra-1.4"

RDEPEND="java? ( >=virtual/jre-1.4 )
	!xulrunner? ( firefox? ( || ( =www-client/mozilla-firefox-2*
		=www-client/mozilla-firefox-bin-2* ) ) )
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
	dev-perl/IO-Compress-Base
	dev-util/pkgconfig
	dev-util/intltool
	>=dev-libs/boost-1.33.1
	sys-devel/flex
	sys-devel/bison
	dev-libs/libxslt
	>=dev-libs/libxml2-2.0
	!xulrunner? ( firefox? ( =www-client/mozilla-firefox-2* ) )
	>=dev-util/gperf-3
	>=net-misc/curl-7.12
	sys-libs/zlib
	sys-apps/coreutils
	media-gfx/imagemagick
	pam? ( sys-libs/pam )
	!dev-util/dmake
	>=dev-lang/python-2.3.4
	java? ( || ( =virtual/jdk-1.6* =virtual/jdk-1.5* =virtual/jdk-1.4* )
		dev-java/ant-core )
	ldap? ( net-nds/openldap )"

PROVIDE="virtual/ooo"

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
	CHECKREQS_MEMORY="512"
	use debug && CHECKREQS_DISK_BUILD="8192" || CHECKREQS_DISK_BUILD="5120"
	check_reqs

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

	if use pam; then
		if ! built_with_use sys-apps/shadow pam; then
			eerror " shadow needs to be built with pam-support. "
			eerror " rebuild it accordingly or remove the pam use-flag "
			die
		fi
	fi

	if use xulrunner; then
		if pkg-config --exists xulrunner-xpcom; then
			XULR="xulrunner"
		elif pkg-config --exists libxul; then
			XULR="libxul"
		else
			die "USE flag [xulrunner] set but not found!"
		fi
	fi

	java-pkg-opt-2_pkg_setup

	# sys-libs/db version used
	local db_ver="$(db_findver '>=sys-libs/db-4.3')"

}

src_unpack() {

	unpack ooo-build-${MY_PV}.tar.gz

	# Hackish workaround for overlong path problem, see bug #130837
	mv "${S_OLD}" "${S}" || die

	#Some fixes for our patchset
	cd "${S}"
	epatch "${FILESDIR}/gentoo-${PV}.diff"
	epatch "${FILESDIR}/ooo-env_log.diff"

	#Use flag checks
	if use java ; then
		echo "--with-ant-home=${ANT_HOME}" >> ${CONFFILE}
		echo "--with-jdk-home=$(java-config --jdk-home 2>/dev/null)" >> ${CONFFILE}
		echo "--with-java-target-version=$(java-pkg_get-target)" >> ${CONFFILE}
		echo "--with-system-beanshell" >> ${CONFFILE}
		echo "--with-system-xalan" >> ${CONFFILE}
		echo "--with-system-xerces" >> ${CONFFILE}
		echo "--with-system-xml-apis" >> ${CONFFILE}
		echo "--with-system-hsqldb" >> ${CONFFILE}
		echo "--with-system-rhino" >> ${CONFFILE}
		echo "--with-beanshell-jar=$(java-pkg_getjar bsh bsh.jar)" >> ${CONFFILE}
		echo "--with-serializer-jar=$(java-pkg_getjar xalan-serializer serializer.jar)" >> ${CONFFILE}
		echo "--with-xalan-jar=$(java-pkg_getjar xalan xalan.jar)" >> ${CONFFILE}
		echo "--with-xerces-jar=$(java-pkg_getjar xerces-2 xercesImpl.jar)" >> ${CONFFILE}
		echo "--with-xml-apis-jar=$(java-pkg_getjar xml-commons-external-1.3 xml-apis.jar)" >> ${CONFFILE}
		echo "--with-hsqldb-jar=$(java-pkg_getjar hsqldb hsqldb.jar)" >> ${CONFFILE}
		echo "--with-rhino-jar=$(java-pkg_getjar rhino-1.5 js.jar)" >> ${CONFFILE}
	fi

	if use firefox || use seamonkey || use xulrunner ; then
		echo "--enable-mozilla" >> ${CONFFILE}
		local browser
		use seamonkey && browser="seamonkey"
		use firefox && browser="firefox"
		use xulrunner && browser="${XULR}"

		echo "--with-system-mozilla=${browser}" >> ${CONFFILE}
	else
		echo "--disable-mozilla" >> ${CONFFILE}
		echo "--without-system-mozilla" >> ${CONFFILE}
	fi

	echo "`use_enable binfilter`" >> ${CONFFILE}
	echo "`use_enable cups`" >> ${CONFFILE}
	echo "`use_enable dbus`" >> ${CONFFILE}
	echo "`use_enable eds evolution2`" >> ${CONFFILE}
	echo "`use_enable gnome gnome-vfs`" >> ${CONFFILE}
	echo "`use_enable gnome lockdown`" >> ${CONFFILE}
	echo "`use_enable gnome atkbridge`" >> ${CONFFILE}
	echo "`use_enable gstreamer`" >> ${CONFFILE}
	echo "`use_enable ldap`" >> ${CONFFILE}
	echo "`use_enable opengl`" >> ${CONFFILE}
	echo "`use_with ldap openldap`" >> ${CONFFILE}
	echo "--enable-neon" >> ${CONFFILE}
	echo "--with-system-neon" >> ${CONFFILE}
	echo "--with-system-openssl" >> ${CONFFILE}

	echo "`use_enable debug crashdump`" >> ${CONFFILE}

	# Original branding results in black splash screens for some, so forcing ours
	echo "--with-intro-bitmaps=\\\"${FILESDIR}/openoffice-2.4.bmp\\\"" >> ${CONFFILE}

	eautoreconf

}

src_compile() {

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
	filter-flags "-O[s2-9]"

	# Build with NVidia cards breaks otherwise
	use opengl && append-flags "-DGL_GLEXT_PROTOTYPES"

	# Now for our optimization flags ...
	export ARCH_FLAGS="${CXXFLAGS}"
	use debug || export LINKFLAGSOPTIMIZE="${LDFLAGS}"

	# Make sure gnome-users get gtk-support
	local GTKFLAG="--disable-gtk --disable-cairo --without-system-cairo"
	( use gtk || use gnome ) && GTKFLAG="--enable-gtk --enable-cairo --with-system-cairo"

	cd "${S}"
	./configure \
		--with-distro="Gentoo" \
		--with-arch="${ARCH}" \
		--host="${CHOST}" \
		--with-srcdir="${DISTDIR}" \
		--with-lang="en-US" \
		--with-num-cpus="${JOBS}" \
		--without-binsuffix \
		--with-installed-ooo-dirname="openoffice" \
		--with-tag="${MST}" \
		${GTKFLAG} \
		`use_enable mono` \
		`use_enable kde` \
		`use_enable pam` \
		`use_enable !debug strip` \
		`use_enable odk` \
		`use_with java` \
		--disable-access \
		--disable-post-install-scripts \
		--enable-hunspell \
		--enable-openxml \
		--with-system-hunspell \
		--with-system-libwpd \
		--with-system-libsvg \
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
	make DESTDIR="${D}" install || die "Installation failed!"

	# Fix the permissions for security reasons
	chown -R root:0 "${D}"

	# record java libraries
	use java && java-pkg_regjar "${D}"/usr/$(get_libdir)/openoffice/program/classes/*.jar

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
