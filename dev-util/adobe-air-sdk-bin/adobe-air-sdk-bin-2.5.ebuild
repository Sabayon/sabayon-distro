# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils fdo-mime multilib

DESCRIPTION="Adobe AIR SDK"
HOMEPAGE="http://www.adobe.com/products/air/tools/sdk/"
SRC_URI="http://airdownload.adobe.com/air/lin/download/${PV}/AdobeAIRSDK.tbz2 -> AdobeAIRSDK-${PV}.tbz2"

LICENSE="AdobeAirSDK"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="app-arch/unzip
	x86? ( dev-libs/libxml2
		dev-libs/nspr
		dev-libs/nss
		media-libs/libpng
		net-misc/curl
		www-plugins/adobe-flash
		x11-libs/cairo
		x11-libs/gtk+ )
	amd64? ( app-emulation/emul-linux-x86-baselibs
		app-emulation/emul-linux-x86-gtklibs )"

QA_PRESTRIPPED=".*\.so
	/opt/Adobe/AirSDK/bin/adl"
QA_EXECSTACK="*/libCore.so"

src_install() {
	local sdkdir=opt/Adobe/AirSDK
	local rtdir='runtimes/air/linux/Adobe AIR/Versions/1.0'

	# remove the broken symlinks
	rm -r "${rtdir}"/Resources/nss3/{0d,1d} || die "removing cruft failed"
	if use x86; then
		rm "${rtdir}"/Resources/lib{curl,flashplayer}.so || die "removing cruft failed"
	fi

	insinto /${sdkdir}
	doins -r * || die "doins failed"

	cd "${D}"
	fperms 0755 ${sdkdir}/bin/* ${sdkdir}/"${rtdir}"/{libCore.so,Resources/lib*.so*} \
		|| die "chmod failed"

	use x86 && make_wrapper adl /${sdkdir}/bin/adl . /usr/lib/nss:/usr/lib/nspr:/opt/netscape/plugins /opt/bin
	use amd64 && make_wrapper adl /${sdkdir}/bin/adl . /usr/lib32:/usr/lib32/nss:/usr/lib32/nspr /opt/bin

	exeinto /opt/bin
	doexe "${FILESDIR}"/airstart || die "doexe failed"

	# install the file association
	# (we can't use make_desktop_entry because we like to have NoDisplay)
	domenu "${FILESDIR}"/airstart.desktop || die "domenu failed"

	insinto /usr/share/mime/packages
	doins "${FILESDIR}"/${PN}.xml || die "doins failed"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
