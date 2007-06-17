# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/kdebluetooth/kdebluetooth-1.0_beta2-r1.ebuild,v 1.4 2007/02/02 17:48:14 gustavoz Exp $

inherit kde autotools

MY_PV=${PV/_/-}
MY_P=${PN}-${MY_PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="KDE Bluetooth Framework"
HOMEPAGE="http://bluetooth.kmobiletools.org/"
SRC_URI="mirror://sourceforge/kde-bluetooth/${MY_P}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~hppa ~ppc sparc ~x86"
IUSE="irmc"

DEPEND=">=dev-libs/openobex-1.1
	>=net-wireless/bluez-libs-2.15
	>=media-libs/libvorbis-1.0
	app-mobilephone/obexftp
	irmc? ( || ( >=kde-base/kitchensync-3.4_beta1 >=kde-base/kdepim-3.4_beta1 ) )"

RDEPEND="${DEPEND}
	|| ( ( kde-base/kdialog kde-base/konqueror )  kde-base/kdebase )
	net-wireless/bluez-utils"

LANGS="bg br ca cs cy da de el en_GB es et fi fr ga gl hu is it ja ka lt
mt nb nl nn pa pl pt pt_BR ro ru rw sk sr sr@Latn sv ta tr uk zh_CN"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

need-kde 3

src_unpack() {
	kde_src_unpack

	cd "${WORKDIR}/${P}/po"
	for X in ${LANGS} ; do
		use linguas_${X} || rm -rf "${X}"
	done
	rm -f "${S}/configure"
	#eaclocal && eautoconf || die "autotools failed"
}

src_compile() {
	# Change defaults to match our bluez-utils setup
	local myconf="--without-xmms $(use_enable irmc irmcsynckonnector)"
	kde_src_compile
}

pkg_postinst() {
	einfo 'This version of kde-bluetooth provides a replacement for the'
	einfo 'standard bluepin program "kbluepin". If you want to use this version,'
	einfo 'you have to edit "/etc/bluetooth/hcid.conf" and change the line'
	einfo '"pin_helper oldbluepin;" to "pin_helper /usr/lib/kdebluetooth/kbluepin;".'
	einfo 'Then restart hcid to make the change take effect.'
}
