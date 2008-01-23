# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Ebuild from http://forums.gentoo.org/viewtopic-t-472065.html

inherit eutils

# *CHANGE* *THIS* for your hardware - http://getswiftfox.com/releases.htm

MY_PN="swiftfox"
MY_PV=${PV/_/}

DESCRIPTION="Optimized binary build of the Mozilla Firefox web browser"
HOMEPAGE="http://getswiftfox.com/"
IUSE_SWIFTFOX_CPU="swiftfox_cpu_athlon64
		swiftfox_cpu_athlon-xp"
IUSE="cpu_athlon64 cpu_athlon-xp cpu_pentium4 cpu_pentium-m cpu_pentium3 cpu_prescott cpu_celeron4 cpu_celeron-m cpu_celeron3"
SRC_URI="cpu_athlon64? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-athlon64.tar.bz2 )
    cpu_athlon-xp? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-athlon-xp.tar.bz2 )
    cpu_pentium4? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-pentium4.tar.bz2 )
    cpu_pentium-m? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-pentium-m.tar.bz2 )
    cpu_pentium3? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-pentium3.tar.bz2 )
    cpu_prescott? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-prescott.tar.bz2 )
    cpu_celeron4? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-pentium4.tar.bz2 )
    cpu_celeron-m? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-pentium-m.tar.bz2 )
    cpu_celeron3? ( http://getswiftfox.com/builds/releases/${PV}/${MY_PN}-${MY_PV}-pentium3.tar.bz2 )"

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
                =virtual/libstdc++-3.3
        )
        amd64? (
                >=app-emulation/emul-linux-x86-baselibs-1.0
                >=app-emulation/emul-linux-x86-gtklibs-1.0
                app-emulation/emul-linux-x86-compat
        )
        >=www-client/mozilla-launcher-1.41"

S=${WORKDIR}/${MY_PN}
dir=/opt/${MY_PN}

src_install() {
   insinto "${dir}"
   exeinto "${dir}"

   doins -r * || die "doins -r failed"

   rm -f "${D}/${dir}"/{${MY_PN}{,-bin},updater,run-mozilla.sh} || die
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
            dosym /opt/${MY_PN}/{${MY_PN},firefox}${i} || die
         else
            rm -f "${D}/${dir}/firefox${i}" || die
            doexe "firefox${i}" || die
         fi
      fi
   done

   dodir /opt/bin
   dosym /opt/${MY_PN}/firefox /opt/bin/${MY_PN} || die

   newicon icons/icon48.png ${MY_PN}.xpm || die "newicon failed"
   make_desktop_entry ${MY_PN} "Swiftfox" ${MY_PN}.xpm "Application;Network"
}

pkg_postinst() {
   elog "Test Java at:"
   elog "   http://www.java.com/en/download/help/testvm.xml"
   elog "If it does not work after following the Gentoo Java upgrade guide:"
   elog "   http://www.gentoo.org/proj/en/java/java-upgrade.xml"
   elog "Then run as your normal user e.g.:"
   elog "   mkdir -p ~/.mozilla/plugins"
   elog "   ln -sfn /usr/lib/nsbrowser/plugins/javaplugin.so ~/.mozilla/plugins/"
   echo
}