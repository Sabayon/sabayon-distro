# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libgphoto2/libgphoto2-2.4.1-r1.ebuild,v 1.3 2008/05/27 06:12:19 jer Exp $

# TODO
# 1. Track upstream bug --disable-docs does not work.
#	http://sourceforge.net/tracker/index.php?func=detail&aid=1643870&group_id=8874&atid=108874
# 3. Track upstream bug regarding rpm usage.
#	http://sourceforge.net/tracker/index.php?func=detail&aid=1643813&group_id=8874&atid=358874

inherit eutils autotools

DESCRIPTION="Library that implements support for numerous digital cameras"
HOMEPAGE="http://www.gphoto.org/"
SRC_URI="mirror://sourceforge/gphoto/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE="nls doc exif hal kernel_linux"
RESTRICT="test"

# By default, drivers for all supported cameras will be compiled.
# If you want to only compile for specific camera(s), set CAMERAS
# environment to a space-separated list (no commas) of drivers that
# you want to build.
IUSE_CAMERAS="adc65 agfa_cl20 aox barbie canon casio_qv clicksmart310
digigr8 digita dimera3500 directory enigma13 fuji gsmart300 hp215 iclick
jamcam jd11 kodak_dc120 kodak_dc210 kodak_dc240 kodak_dc3200 kodak_ez200
konica konica_qm150 largan lg_gsm mars dimagev mustek panasonic_coolshot
panasonic_l859 panasonic_dc1000 panasonic_dc1580 pccam300 pccam600
polaroid_pdc320 polaroid_pdc640 polaroid_pdc700 ptp2 ricoh ricoh_g3 samsung
sierra sipix_blink sipix_blink2 sipix_web2 smal sonix sony_dscf1 sony_dscf55
soundvision spca50x sq905 stv0674 stv0680 sx330z template toshiba_pdrm11"

for camera in ${IUSE_CAMERAS}; do
	IUSE="${IUSE} cameras_${camera}"
done

RDEPEND=">=dev-libs/libusb-0.1.8
	exif? ( >=media-libs/libexif-0.5.9 )
	hal? ( >=sys-apps/hal-0.5 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/flex
	sys-devel/libtool
	doc? ( app-doc/doxygen )"

RDEPEND="${RDEPEND}
	!<sys-fs/udev-114"

pkg_setup() {
	if ! echo "${USE}" | grep "cameras_" > /dev/null 2>&1; then
		einfo "libgphoto2 supports: all ${IUSE_CAMERAS}"
		einfo "All camera drivers will be built since you did not specify"
		einfo "via the CAMERAS variable what camera you use."
		ewarn "NOTICE: Upstream will not support you if you do not compile all camera drivers first"
	fi

	if use cameras_template || use cameras_sipix_blink; then
		einfo "Upstream considers sipix_blink & template driver as obsolete"
	fi

	enewgroup plugdev || die "Error creating plugdev group"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-2.4.0-rpm.patch

	# Fix pkgconfig file when USE="-exif"
	use exif || sed -i "s/, @REQUIREMENTS_FOR_LIBEXIF@//" libgphoto2.pc.in || die " libgphoto2.pc sed failed"

	# Fix bug #212721, libtool-2 failure
	sed -i "s:lt_dlcaller_register:lt_dlinit:g" configure libgphoto2_port/configure || die "libtool sed failed"

	# Fix bug #216206, libusb detection
	sed -i "s:usb_busses:usb_find_busses:g" libgphoto2_port/configure || die "libusb sed failed"

	# Fix building on alpha, bug #221853 comment #6
	epatch "${FILESDIR}"/gphoto2-ixany.patch
}

src_compile() {
	local cameras
	local cam
	for cam in ${IUSE_CAMERAS} ; do
		use "cameras_${cam}" && cameras="${cameras},${cam}"
	done

	[ -z "${cameras}" ] \
		&& cameras="all" \
		|| cameras="${cameras:1}"

	einfo "Enabled camera drivers: ${cameras}"
	[ "${cameras}" != "all" ] && \
		ewarn "Upstream will not support you if you do not compile all camera drivers first"

	local myconf

	use exif \
		&& myconf="${myconf} --with-libexif=/usr" \
		|| myconf="${myconf} --with-libexif=no"

	econf \
		--with-drivers=${cameras} \
		--with-doc-dir=/usr/share/doc/${PF} \
		--with-html-dir=/usr/share/doc/${PF}/html \
		--with-hotplug-doc-dir=/usr/share/doc/${PF}/hotplug \
		$(use_enable nls) \
		--with-rpmbuild=/bin/true \
		--disable-docs \
		udevscriptdir=/lib/udev \
		GTKDOC=/bin/true \
		${myconf} || die "econf failed"
# FIXME:		$(use_enable doc docs) \

	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	# FIXME: fixup autoconf bug
	if ! use doc && [ -d "${D}/usr/share/doc/${PF}/apidocs.html" ]; then
		rm -fr "${D}/usr/share/doc/${PF}/apidocs.html"
	fi
	# end fixup

	dodoc ChangeLog NEWS* README AUTHORS TESTERS MAINTAINERS HACKING

	HAL_FDI="/usr/share/hal/fdi/information/20thirdparty/10-camera-libgphoto2.fdi"
	UDEV_RULES="/etc/udev/rules.d/70-libgphoto2.rules"
	CAM_LIST="/usr/$(get_libdir)/libgphoto2/print-camera-list"

	if [ -x "${D}"${CAM_LIST} ]; then
		# Let print-camera-list find libgphoto2.so
		export LD_LIBRARY_PATH="${D}/usr/$(get_libdir)"
		# Let libgphoto2 find its camera-modules
		export CAMLIBS="${D}/usr/$(get_libdir)/libgphoto2/${PV}"

		if use hal && [ -n "$("${D}"${CAM_LIST} idlist)" ]; then
				einfo "Generating HAL FDI files ..."
				mkdir -p "${D}"/${HAL_FDI%/*}
				"${D}"${CAM_LIST} hal-fdi >> "${D}"/${HAL_FDI} \
					|| die "failed to create hal-fdi"
		else
			ewarn "No HAL FDI file generated because no real camera driver enabled"
		fi

		einfo "Generating UDEV-rules ..."
		mkdir -p "${D}"/${UDEV_RULES%/*}
		echo -e "# do not edit this file, it will be overwritten on update\n#" \
			> "${D}"/${UDEV_RULES}
		"${D}"${CAM_LIST} udev-rules version 0.98 group plugdev >> "${D}"/${UDEV_RULES} \
			|| die "failed to create udev-rules"

		# Fix group ownership "race" condition with cups
		sed -i 's/^GROUP="plugdev"$//' "${D}"/${UDEV_RULES}

	else
		eerror "Unable to find print-camera-list"
		eerror "and therefore unable to generate hotplug usermap or HAL FDI files."
		eerror "You will have to manually generate it by running:"
		eerror " ${CAM_LIST} udev-rules version 0.98 group plugdev > ${UDEV_RULES}"
		eerror " ${CAM_LIST} hal-fdi > ${HAL_FDI}"
	fi

}

pkg_postinst() {
	elog "Don't forget to add yourself to the plugdev group "
	elog "if you want to be able to access your camera."
	local OLD_UDEV_RULES="${ROOT}"etc/udev/rules.d/99-libgphoto2.rules
	if [[ -f ${OLD_UDEV_RULES} ]]; then
		rm -f "${OLD_UDEV_RULES}"
	fi
}
