# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/iscan/iscan-2.11.0.ebuild,v 1.4 2008/06/30 17:52:50 sbriesen Exp $

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils toolchain-funcs flag-o-matic autotools rpm

SRC_REV="4"  # revision used by upstream

# HINTS:
# -> non-free modules are x86 only
# -> isane frontend needs non-free modules
# -> sane-epkowa should be usable on every arch
# -> ${P}-${SRC_REV}.tar.gz    (for gcc 3.2/3.3)
# -> ${P}-${SRC_REV}.c2.tar.gz (for gcc 3.4 or later)

# PLUGINS:
# -> iscan-plugin-gt-7200 == Perfection 1250 PHOTO
# -> iscan-plugin-gt-7300 == Perfection 1260 PHOTO
# -> iscan-plugin-gt-9400 == Perfection 3170 PHOTO      (esfw32.bin)
# -> iscan-plugin-gt-f500 == Perfection 2480/2580 PHOTO (esfw41.bin)
# -> iscan-plugin-gt-f520 == Perfection 3490/3590 PHOTO (esfw52.bin)
# -> iscan-plugin-gt-f600 == Perfection 4180 PHOTO      (esfw43.bin)
# -> iscan-plugin-gt-x750 == Perfection 4490 PHOTO      (esfw54.bin)
# -> iscan-plugin-gt-s600 == Perfection V10/V100 PHOTO  (esfw66.bin)
# -> iscan-plugin-gt-f700 == Perfection V350 PHOTO      (esfw68.bin)
# -> iscan-plugin-gt-f670 == Perfection V200 PHOTO      (esfw7A.bin)
# -> iscan-plugin-gt-x770 == Perfection V500 PHOTO      (esfw7C.bin)
# -> iscan-plugin-cx4400  == Stylus CX4300/CX4400/CX4450/CX5500/CX5600/DX4400/DX4450

# FIXME:
# Make jpeg/png optional. The problem is, that the
# configure script ignores --disable-*, if the
# corresponding lib is found on the system.
# Furthermore, isane doesn't compile w/o libusb,
# this should be fixed somehow.

# available x86 plugins (will be assembled below)
PLUGINS="
	v1180/gt-7200-1.0.0-1
	v1180/gt-7300-1.0.0-1
	v1180/gt-9400-1.0.0-1
	v1180/gt-f500-1.0.0-1
	v1180/gt-f520-1.0.0-1
	v1180/gt-f600-1.0.0-1
	v1180/gt-x750-1.0.0-1
	2.3.0/gt-f700-2.0.0-0
	2.3.0/gt-s600-2.0.0-1
	2.8.0/gt-f670-2.0.0-1
	2.10.0/cx4400-2.0.0-0
	2.11.0/gt-x770-2.1.0-0"

# Firmware files within plugin RPMs
FIRMWARE=(	"esfw41.bin Perfection 2480/2580 PHOTO"
			"esfw32.bin Perfection 3170 PHOTO"
			"esfw52.bin Perfection 3490/3590 PHOTO"
			"esfw43.bin Perfection 4180 PHOTO"
			"esfw54.bin Perfection 4490 PHOTO"
			"esfw66.bin Perfection V10/V100 PHOTO"
			"esfw68.bin Perfection V350 PHOTO"
			"esfw7A.bin Perfection V200 PHOTO"
			"esfw7C.bin Perfection V500 PHOTO" )

SRC_GCC34="mirror://sabayon/${CATEGORY}/${PN}/${PN}_${PV}-${SRC_REV}.tar.gz"
BIN_GCC34=""

for X in ${PLUGINS}; do
	BIN_GCC34="${BIN_GCC34} http://lx1.avasys.jp/iscan/${X%%/*}/iscan-plugin-${X##*/}.c2.i386.rpm"
done

# feel free to add your arch, every non-x86
# arch doesn't install any x86-only stuff.
KEYWORDS="~x86"

DESCRIPTION="EPSON Image Scan! for Linux (including sane-epkowa backend and firmware)"
HOMEPAGE="http://www.avasys.jp/english/linux_e/dl_scan.html"
SRC_URI="${SRC_GCC34} ${BIN_GCC34}"
LICENSE="GPL-2 EAPL EPSON"
SLOT="0"

IUSE="X gimp unicode"
IUSE_LINGUAS="de es fr it ja ko nl pt zh_CN zh_TW"

for X in ${IUSE_LINGUAS}; do IUSE="${IUSE} linguas_${X}"; done

QA_TEXTRELS="
	usr/lib/iscan/libesint41.so.2.0.0
	usr/lib/iscan/libesint52.so.2.0.0"

DEPEND="media-gfx/sane-backends
	media-libs/libpng
	media-libs/jpeg
	>=sys-fs/udev-103
	>=dev-libs/libusb-0.1.12
	x86? (
		X? (
			sys-devel/gettext
			>=x11-libs/gtk+-2.0
			gimp? ( media-gfx/gimp )
		)
	)"

snapscan_firmware() {
	local i
	echo "#-------------- EPSON Image Scan! for Linux Scanner-Firmware --------------"
	for i in "${FIRMWARE[@]}"; do
		echo
		echo "# ${i#* } (${i%% *})"
		echo "#firmware /usr/share/iscan/${i%% *}"
	done
	echo
	cat 2>/dev/null "${1}"
}

usermap_to_udev() {
	echo '# udev rules file for iscan devices (udev >= 0.98)'
	echo '#'
	echo 'ACTION!="add", GOTO="iscan_rules_end"'
	echo 'SUBSYSTEM!="usb*", GOTO="iscan_rules_end"'
	echo 'KERNEL=="lp[0-9]*", GOTO="iscan_rules_end"'
	echo
	
	sed -n -e '
		/^:model[[:space:]]*"[^"]/ {
			# Create model name string
			s|^:model[[:space:]]*"\([^"]\+\).*|# \1|
	
			# Copy to hold buffer
			h
		}
		/^:usbid[[:space:]]*"0x[[:xdigit:]]\+"[[:space:]]*"0x[[:xdigit:]]\+"/ {
			# Append next line
			N

			# Check status
			/\n:status[[:space:]]*:\(complete\|good\|untested\)/ {
				# Exchange with hold buffer
				x

				# Print (model name string)
				p

				# Exchange with hold buffer
				x

	    			# Create udev command string
				s|^:usbid[[:space:]]*"0x\([[:xdigit:]]\+\)"[[:space:]]*"0x\([[:xdigit:]]\+\)".*|ATTRS{idVendor}=="\1", ATTRS{idProduct}=="\2", MODE="0660", GROUP="scanner"|

				# Print (udev command string)
				p
			}
		}
	' "${1}"

	echo
	echo 'LABEL="iscan_rules_end"'
}

pkg_setup() {
	local i
	if ! use x86 && ( use X || use gimp ); then
		ewarn
		ewarn "The iscan application needs CSS x86-only libs and"
		ewarn "thus can't be built currently. You can still use"
		ewarn "'xscanimage', 'xsane' or 'kooka' with sane-epkowa"
		ewarn "backend. But some low-end scanners are also not"
		ewarn "supported, because they need these x86 libs, too."
		ewarn
	fi

	# Select correct tarball for installed GCC. This is not a perfect
	# solution and should be expanded to other working GCC versions.
	einfo "GCC version: $(gcc-fullversion)"
	case "$(gcc-version)" in
		3.4|4.[01234])  # 4.x seems to work (tested with Perfection 3490 PHOTO)
			MY_A="${SRC_GCC34##*/}"
			for i in ${BIN_GCC34}; do MY_A="${MY_A} ${i##*/}"; done
			;;
		*)
			if use x86; then
				die "Your GCC version is not supported. You need either 3.4 or 4.x!"
			else
				MY_A="${SRC_GCC34##*/}"  # fallback to GCC 3.4, should not harm.
				for i in ${BIN_GCC34}; do MY_A="${MY_A} ${i##*/}"; done
			fi
			;;
	esac
}

src_unpack() {
	local i

	cd "${WORKDIR}"
	for i in ${MY_A}; do
		case "${i}" in
			*.rpm)
				echo ">>> Unpacking ${i}"
				rpm_unpack "${DISTDIR}/${i}" || die "failure unpacking ${i}"
				;;
			*)
				unpack "${i}"
				;;
		esac
	done

	cd "${S}"

	# convert japanese docs to UTF-8
	if use unicode && use linguas_ja; then
		for i in {NEWS,README}.ja non-free/*.ja.txt; do
			if [ -f "${i}" ]; then
				echo ">>> Converting ${i} to UTF-8"
				iconv -f eucjp -t utf8 -o "${i}~" "${i}" && mv -f "${i}~" "${i}" || rm -f "${i}~"
			fi
		done
	fi

	# disable iscan frontend + none-free modules
	if ! ( use x86 && use X ); then
		sed -i -e "s:PKG_CHECK_MODULES(GTK,.*):AC_DEFINE([HAVE_GTK_2], 0):g" \
			-e "s:\(PKG_CHECK_MODULES(GDK_IMLIB,.*)\):#\1:g" configure.ac
		sed -i -e 's:^\([[:space:]]*\)frontend[[:space:]]*\\:\1\\:g' \
			-e 's:^\([[:space:]]*\)non-free[[:space:]]*\\:\1\\:g' \
			-e 's:^\([[:space:]]*\)po[[:space:]]*\\:\1\\:g' Makefile*
		sed -i -e 's:iscan.1::g' doc/Makefile*
	fi

	# autotool stuff
	#rm m4/libtool.m4
	#eautoreconf
}

src_compile() {
	append-flags -D_GNU_SOURCE  # needed for 'strndup'
	# hint: dirty hack, look into 'configure.ac' for 'PACKAGE_CXX_ABI'
	CXX="g++" econf --enable-jpeg --enable-png --with-pic || die "econf failed"
	emake CXX="$(tc-getCXX)" || die "emake failed"
}

src_install() {
	local MY_LIB="/usr/$(get_libdir)"
	make DESTDIR="${D}" install || die "make install failed"

	# --disable-static doesn't work, so we just remove obsolete static lib
	sed -i -e "s:^\(old_library=\):# \1:g" "${D}${MY_LIB}/sane/libsane-epkowa.la"
	rm -f "${D}${MY_LIB}/sane/libsane-epkowa.a"

	# install scanner plugins (x86-only)
	if use x86; then
		dodir ${MY_LIB}/iscan
		cp -df "${WORKDIR}"/usr/lib/iscan/* "${D}${MY_LIB}"/iscan/.
	fi

	# install scanner firmware (could be used by sane-backends)
	insinto /usr/share/iscan
	doins "${WORKDIR}"/usr/share/iscan/*

	# install docs
	dodoc AUTHORS NEWS README doc/epkowa.desc
	use linguas_ja && dodoc NEWS.ja README.ja

	# remove 'make-udev-rules', we use our own stuff below
	rm -f "${D}usr/lib/iscan/make-udev-rules"

	# install USB hotplug stuff
	local USERMAP_FILE="doc/epkowa.desc"
	if [ -f ${USERMAP_FILE} ]; then
		dodir /etc/udev/rules.d
		usermap_to_udev ${USERMAP_FILE} \
			> "${D}etc/udev/rules.d/99-iscan.rules"
	else
		die "Can not find USB devices description file: ${USERMAP_FILE}"
	fi

	# install sane config
	insinto /etc/sane.d
	doins backend/epkowa.conf

	# link iscan so it is seen as a plugin in gimp
	if use x86 && use X && use gimp; then
		local plugindir
		if [ -x /usr/bin/gimptool ]; then
			plugindir="$(gimptool --gimpplugindir)/plug-ins"
		elif [ -x /usr/bin/gimptool-2.0 ]; then
			plugindir="$(gimptool-2.0 --gimpplugindir)/plug-ins"
		else
			die "Can't find GIMP plugin directory."
		fi
		dodir "${plugindir}"
		dosym /usr/bin/iscan "${plugindir}"
	fi

	# install desktop entry
	if use x86 && use X; then
		make_desktop_entry iscan "Image Scan! for Linux ${PV}" scanner.png
	fi
}

pkg_postinst() {
	local i
	local DLL_CONF="/etc/sane.d/dll.conf"
	local EPKOWA_CONF="/etc/sane.d/epkowa.conf"
	local SNAPSCAN_CONF="/etc/sane.d/snapscan.conf"
	elog
	if grep -q "^[ \t]*\<epkowa\>" ${DLL_CONF}; then
		elog "Please edit ${EPKOWA_CONF} to suit your needs."
	elif grep -q "\<epkowa\>" ${DLL_CONF}; then
		elog "Hint: to enable the backend, add 'epkowa' to ${DLL_CONF}"
		elog "Then edit ${EPKOWA_CONF} to suit your needs."
	else
		echo "epkowa" >> ${DLL_CONF}
		elog "A new entry 'epkowa' was added to ${DLL_CONF}"
		elog "Please edit ${EPKOWA_CONF} to suit your needs."
	fi
	elog
	elog "You can also use the 'snapscan' backend if you have a recent"
	elog "sane-backend installation. Firmware files for some newer"
	elog "EPSON scanners were installed into /usr/share/iscan:"
	elog
	for i in "${FIRMWARE[@]}"; do
		elog " ${i%% *}: ${i#* }"
	done
	elog
	if ! grep 2>/dev/null -q "/usr/share/iscan/.*\.bin" "${SNAPSCAN_CONF}"; then
		snapscan_firmware "${SNAPSCAN_CONF}" > "${SNAPSCAN_CONF}~~~" \
		&& mv -f "${SNAPSCAN_CONF}~~~" "${SNAPSCAN_CONF}" \
		|| rm -f "${SNAPSCAN_CONF}~~~"
		elog "The firmware entries were added to ${SNAPSCAN_CONF}"
	else
		elog "Please edit ${SNAPSCAN_CONF} to suit your needs."
	fi
	elog "Hint: not all models are supported by 'snapscan' yet!"
	elog
	elog "You can check which backend fits best for your scanner:"
	elog "http://www.sane-project.org/cgi-bin/driver.pl?manu=Epson&bus=any"
	elog
}

