# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils rpm multilib

MY_PV="${PV/_p/-r}"

DESCRIPTION="LaCie LightScribe Labeler 4L (binary only GUI)"
HOMEPAGE="http://www.lacie.com/products/product.htm?pid=10803"
SRC_URI="http://www.lacie.com/download/drivers/4L-${MY_PV}.i586.rpm
	http://eventi.vnunet.it/images/lacie.png"

# The official license of the rpm tag states "Commercial"
# such a license don't exist in gentoo so as-is was chosen
# also on Lacie's website aren't more information then
# Free To Use But Restricted
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="multilib linguas_ja linguas_it linguas_fr linguas_es linguas_de"
RESTRICT=""

RDEPEND=">=sys-devel/gcc-3.4
	dev-libs/liblightscribe
	x86? ( >=media-libs/fontconfig-2.3.2
		>=media-libs/freetype-2.1.10
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender )
	amd64? ( app-emulation/emul-linux-x86-xlibs )
	!app-cdr/lacie-lightscribe-labeler"

QA_PRESTRIPPED="
	opt/lightscribe/4L/4L-gui
	opt/lightscribe/4L/4L-cli"

S="${WORKDIR}"

src_unpack() {
	rpm_src_unpack
}

src_install() {
	has_multilib_profile && ABI="x86"

	exeinto /opt/lightscribe/4L
	doexe usr/4L/4L-* || die "4L-* install failed"
	doexe usr/4L/lacie* || die "lacie* install failed"
	insinto /opt/lightscribe/4L/translations
	for x in ja it fr es de
	do
		if use linguas_${x}
		then
			doins usr/4L/translations/4L-gui_${x}.qm || die "translation install failed"
		fi
	done
	dodoc usr/4L/doc/* || die "doc install failed"
	insinto /opt/lightscribe/template/Lacie
	doins usr/4L/templates/* || die "template install failed"
	into /opt
	# Buggy binary software
	# first run from the install dir otherwise it would not find the translations
	# second change the binaries suexec bit (big security hole)
	# yes they are written to only run with root rights
	# http://www.lightscribe.com/discussionBoards/index.aspx?g=posts&t=4056
	make_wrapper 4L-gui "./4L-gui" /opt/lightscribe/4L /usr/$(get_libdir)/libstdc++-v3
	make_wrapper 4L-cli "./4L-cli" /opt/lightscribe/4L /usr/$(get_libdir)/libstdc++-v3
	fperms u+s /opt/lightscribe/4L/4L-gui
	fperms u+s /opt/lightscribe/4L/4L-cli

	newicon "${DISTDIR}"/lacie.png ${PN}.png || die "icon install failed"
	make_desktop_entry 4L-gui "Lacie LightScribe Labeler" ${PN}.png "Application;AudioVideo;DiscBurning;Recorder;"
}
