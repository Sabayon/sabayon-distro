# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Ebuild from http://forums.gentoo.org/viewtopic-t-472065.html

inherit eutils mozilla-launcher multilib mozextension

# *CHANGE* *THIS* for your hardware - http://getswiftfox.com/releases.htm

MY_PN="swiftfox"
MY_PV=${PV/_pre1/pre-1}

DESCRIPTION="Optimized binary build of the Mozilla Firefox web browser"
HOMEPAGE="http://getswiftfox.com/"
IUSE_CPU="cpu_athlon64 cpu_athlon-xp cpu_pentium4 cpu_pentium-m cpu_pentium3 cpu_prescott cpu_celeron4 cpu_celeron-m cpu_celeron3"
IUSE="restrict-javascript ${IUSE_CPU}"
SRC_URI="cpu_athlon64? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-athlon64.tar.bz2 )
    cpu_athlon-xp? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-athlon-xp.tar.bz2 )
    cpu_pentium4? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-pentium4.tar.bz2 )
    cpu_pentium-m? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-pentium-m.tar.bz2 )
    cpu_pentium3? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-pentium3.tar.bz2 )
    cpu_prescott? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-prescott.tar.bz2 )
    cpu_celeron4? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-pentium4.tar.bz2 )
    cpu_celeron-m? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-pentium-m.tar.bz2 )
    cpu_celeron3? ( http://getswiftfox.com/builds/releases/${MY_PV}/${MY_PN}-${MY_PV}-pentium3.tar.bz2 )"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="MPL-1.1 NPL-1.1"
RESTRICT="mirror strip"

DEPEND="app-arch/unzip"
RDEPEND="x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXmu
	x86? (
		>=x11-libs/gtk+-2.2
	)
	amd64? (
		>=app-emulation/emul-linux-x86-baselibs-1.0
		>=app-emulation/emul-linux-x86-gtklibs-1.0
		app-emulation/emul-linux-x86-compat
	)"

PDEPEND="restrict-javascript? ( x11-plugins/noscript )"

S=${WORKDIR}/${MY_PN}

pkg_setup() {
	# This is a binary x86 package => ABI=x86
	# Please keep this in future versions
	has_multilib_profile && ABI="x86"


	# Make sure the user has selected a CPU
	SELECTED=false
	for i in ${IUSE_CPU[@]}; do
		if use ${i}; then
			SELECTED=true
			break
		fi
	done

	if ! ${SELECTED}; then
		eerror "You should select at least one cpu"
		exit 1
	fi
}

src_install() {
	declare MOZILLA_FIVE_HOME=/opt/swiftfox
	insinto "${MOZILLA_FIVE_HOME}"
	exeinto "${MOZILLA_FIVE_HOME}"

	doins -r * || die "doins -r failed"

	rm -f "${D}/${MOZILLA_FIVE_HOME}"/{${MY_PN}{,-bin},updater,run-mozilla.sh} || die
	doexe {${MY_PN}{,-bin},updater,run-mozilla.sh} || die

	local i
	for i in "" "-bin" ; do
		if [[ -e "firefox${i}" ]] ; then
			if $(diff -q {swiftfox,firefox}${i}) ; then
				# Files are identical, so symlink them.
				einfo "Symlinking firefox${i} to swiftfox${i}"
				# Link is necessary because setting Swiftfox as the default
				# browser using Swiftfox's preferences, sets the command
				# in Gnome's "Preferred Applications" to:
				# /opt/swiftfox/firefox "%s"
				dosym ${MOZILLA_FIVE_HOME}/{${MY_PN},firefox}${i} || die
			else
				rm -f "${D}/${MOZILLA_FIVE_HOME}/firefox${i}" || die
				doexe "firefox${i}" || die
			fi
		fi
	done

	dodir /opt/bin
	dosym ${MOZILLA_FIVE_HOME}/firefox /opt/bin/${MY_PN} || die

	newicon icons/icon48.png ${MY_PN}.xpm || die "newicon failed"
	make_desktop_entry ${MY_PN} "Swiftfox" ${MY_PN}.xpm "Application;Network"

	rm -rf "${D}"${MOZILLA_FIVE_HOME}/plugins
	dosym /usr/"$(get_libdir)"/nsbrowser/plugins ${MOZILLA_FIVE_HOME}/plugins
}

pkg_preinst() {
	declare MOZILLA_FIVE_HOME=/opt/swiftfox

	# Remove entire installed instance to prevent all kinds of
	# problems...
	rm -rf "${ROOT}"${MOZILLA_FIVE_HOME}
}

pkg_postinst() {
	if use x86; then
		if ! has_version 'gnome-base/gconf' || ! has_version 'gnome-base/orbit' \
			|| ! has_version 'net-misc/curl'; then
			einfo
			einfo "For using the crashreporter, you need gnome-base/gconf,"
			einfo "gnome-base/orbit and net-misc/curl emerged."
			einfo
		fi
		if has_version 'net-misc/curl' && built_with_use --missing \
			true 'net-misc/curl' nss; then
			einfo
			einfo "Crashreporter won't be able to send reports"
			einfo "if you have curl emerged with the nss USE-flag"
			einfo
		fi
	else
		einfo
		einfo "NB: You just installed a 32-bit firefox"
		einfo
		einfo "Crashreporter won't work on amd64"
		einfo
	fi
	update_mozilla_launcher_symlinks
}

pkg_postrm() {
	update_mozilla_launcher_symlinks
}
