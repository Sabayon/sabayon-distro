# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils toolchain-funcs multilib flag-o-matic

DESCRIPTION="NVIDIA Linux X11 Settings Utility"
HOMEPAGE="http://www.nvidia.com/"
SRC_URI="ftp://download.nvidia.com/XFree86/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86 ~x86-fbsd"
IUSE=""

# xorg-server is used in the depends as nvidia-settings builds against some
# headers in /usr/include/xorg/.
# This also allows us to optimize out a lot of the other dependancies, as
# between gtk and xorg-server, almost all libraries and headers are accounted
# for.
DEPEND=">=x11-libs/gtk+-2:2
	dev-util/pkgconfig
	x11-base/xorg-server
	x11-libs/libXt
	x11-libs/libXv
	x11-proto/xf86driproto
	x11-proto/xf86vidmodeproto"

RDEPEND=">=x11-libs/gtk+-2:2
	x11-base/xorg-server
	x11-libs/libXt
	x11-libs/pango[X]"

src_compile() {
	einfo "Building libXNVCtrl..."
	emake -C src/libXNVCtrl/ clean # NVidia ships pre-built archives :(
	emake -C src/libXNVCtrl/ \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		libXNVCtrl.a

	einfo "Building nvidia-settings..."
	emake -C src/ \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		STRIP_CMD="$(type -P true)" \
		NV_VERBOSE=1 \
		USE_EXTERNAL_JANSSON=1
}

src_install() {
	emake -C src/ DESTDIR="${D}" PREFIX=/usr USE_EXTERNAL_JANSSON=1 install

	insinto /usr/$(get_libdir)
	doins src/libXNVCtrl/libXNVCtrl.a

	insinto /usr/include/NVCtrl
	doins src/libXNVCtrl/*.h

	doicon doc/${PN}.png
	make_desktop_entry ${PN} "NVIDIA X Server Settings" ${PN} Settings

	dodoc doc/*.txt

	# Install icon and .desktop entry
	doicon "${S}/doc/${PN}.png"
	sed -i "s:__UTILS_PATH__:/usr/bin:" "${S}/doc/${PN}.desktop"
	sed -i "s:__PIXMAP_PATH__:/usr/share/pixmaps:" "${S}/doc/${PN}.desktop"
	sed -i "s:__NVIDIA_SETTINGS_DESKTOP_CATEGORIES__:Utility:" "${S}/doc/${PN}.desktop"
	domenu "${S}/doc/${PN}.desktop"
	exeinto /etc/X11/xinit/xinitrc.d
	doexe "${FILESDIR}"/95-nvidia-settings
}
