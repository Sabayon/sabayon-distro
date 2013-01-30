# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit multilib git-2

DESCRIPTION="Faster OpenGL offloading for Bumblebee"
HOMEPAGE="https://github.com/amonakov/primus"
SRC_URI=""
EGIT_REPO_URI="git://github.com/amonakov/primus.git https://github.com/amonakov/primus.git"

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE="multilib"

RDEPEND="x11-misc/bumblebee[video_cards_nvidia]
	multilib? ( app-emulation/emul-linux-x86-xlibs app-emulation/emul-linux-x86-baselibs )"
DEPEND="virtual/opengl"


src_compile() {
	export PRIMUS_libGLa='/usr/$$LIB/opengl/nvidia/lib/libGL.so.1'
	emake LIBDIR=$(get_libdir)
	if use multilib; then
		local ABI=x86
		local CXXFLAGS="${CXXFLAGS} -m32"
		emake LIBDIR=$(get_libdir)
	fi
}

src_install() {
	sed -i -e "s#^PRIMUS_libGL=.*#PRIMUS_libGL='/usr/\$LIB/primus'#" primusrun
	sed -i -e "s/^# PRIMUS_libGL=/PRIMUS_libGL=/" primusrun
	dobin primusrun
	insinto /usr/$(get_libdir)/primus
	doins ${S}/$(get_libdir)/libGL.so.1
	if use multilib; then
		local ABI=x86
		insinto /usr/$(get_libdir)/primus
		doins ${S}/$(get_libdir)/libGL.so.1
	fi
}
