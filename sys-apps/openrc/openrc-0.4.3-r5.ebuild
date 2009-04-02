# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/openrc/openrc-0.4.3-r1.ebuild,v 1.1 2009/02/13 09:07:16 zzam Exp $

inherit eutils flag-o-matic multilib toolchain-funcs

if [[ ${PV} == "9999" ]] ; then
	ESVN_REPO_URI="svn://roy.marples.name/openrc/trunk"
	inherit subversion
else
	SRC_URI="http://roy.marples.name/downloads/${PN}/${P}.tar.bz2
		mirror://gentoo/${P}.tar.bz2
		http://dev.gentoo.org/~cardoe/files/${P}.tar.bz2
		http://dev.gentoo.org/~vapier/dist/${P}.tar.bz2"
fi

DESCRIPTION="OpenRC manages the services, startup and shutdown of a host"
HOMEPAGE="http://roy.marples.name/openrc"
HOSTNAME_CONF="/etc/conf.d/hostname"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="debug elibc_glibc ncurses pam unicode kernel_linux kernel_FreeBSD"

RDEPEND="virtual/init
	kernel_FreeBSD? ( sys-process/fuser-bsd )
	elibc_glibc? ( >=sys-libs/glibc-2.5 )
	ncurses? ( sys-libs/ncurses )
	pam? ( virtual/pam )
	>=sys-apps/baselayout-2.0.0
	kernel_linux? ( !<sys-apps/module-init-tools-3.2.2-r2 )
	!<sys-fs/udev-133
	!<sys-apps/sysvinit-2.86-r11"
DEPEND="${RDEPEND}
	virtual/os-headers"

pkg_setup() {
	LIBDIR="lib"
	[ "${SYMLINK_LIB}" = "yes" ] && LIBDIR=$(get_abi_LIBDIR "${DEFAULT_ABI}")

	MAKE_ARGS="${MAKE_ARGS} LIBNAME=${LIBDIR}"

	local brand="Unknown"
	if use kernel_linux ; then
		MAKE_ARGS="${MAKE_ARGS} OS=Linux"
		brand="Linux"
	elif use kernel_FreeBSD ; then
		MAKE_ARGS="${MAKE_ARGS} OS=FreeBSD"
		brand="FreeBSD"
	fi
	export BRANDING="Sabayon ${brand}"

	export DEBUG=$(usev debug)
	export MKPAM=$(usev pam)
	export MKTERMCAP=$(usev ncurses)
}

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		subversion_src_unpack
	else
		unpack ${A}
	fi
	cd "${S}"
	epatch "${FILESDIR}"/0.4.2/0001-msg-style.patch
	epatch "${FILESDIR}"/0.4.2/0002-useful-functions.patch
	epatch "${FILESDIR}"/0.4.2/0003-KV.patch
	epatch "${FILESDIR}"/openrc-0.4.3-fix-is_older_than.patch

	# Sabayon patches
	epatch "${FILESDIR}"/${P}-disable_warnings_until_migrated.patch
	epatch "${FILESDIR}"/${P}-enable_rc_logger.patch
	epatch "${FILESDIR}"/${P}-tweak_hwclock_options.patch
}

src_compile() {
	# catch people running `ebuild` w/out setup
	if [[ -z ${MAKE_ARGS} ]] ; then
		die "Your MAKE_ARGS is empty ... are you running 'ebuild' but forgot to execute 'setup' ?"
	fi

	if [[ ${PV} == "9999" ]] ; then
		local ver="-svn-$(cd "${ESVN_STORE_DIR}/${ESVN_PROJECT}/${ESVN_REPO_URI##*/}"; LC_ALL=C svnversion)"
		sed -i "/^SVNVER[[:space:]]*=/s:=.*:=${ver}:" src/rc/Makefile
	fi

	tc-export CC AR RANLIB
	echo emake ${MAKE_ARGS}
	emake ${MAKE_ARGS} || die "emake ${MAKE_ARGS} failed"
}

src_install() {
	emake ${MAKE_ARGS} DESTDIR="${D}" install || die "make install failed"
	gen_usr_ldscript libeinfo.so
	gen_usr_ldscript librc.so

	keepdir /"${LIBDIR}"/rc/init.d
	keepdir /"${LIBDIR}"/rc/tmp

	# Backup our default runlevels
	dodir /usr/share/"${PN}"
	mv "${D}/etc/runlevels" "${D}/usr/share/${PN}"

	# Setup unicode defaults for silly unicode users
	use unicode && sed -i -e '/^unicode=/s:NO:YES:' "${D}"/etc/rc.conf

	# Cater to the norm
	(use x86 || use amd64) && sed -i -e '/^windowkeys=/s:NO:YES:' "${D}"/etc/conf.d/keymaps

	# Sabayon hack, remove conf.d/hostname since it's always created by the installer
	mv ${D}/etc/conf.d/hostname ${D}/etc/conf.d/hostname.example || die "cannot move hostname config"

}

add_boot_init() {
	local initd=$1
	# if the initscript is not going to be installed and  is not
	# currently installed, return
	[[ -e ${D}/etc/init.d/${initd} || -e ${ROOT}/etc/init.d/${initd} ]] \
		|| return
	[[ -e ${ROOT}/etc/runlevels/boot/${initd} ]] && return
	elog "Auto-adding '${initd}' service to your boot runlevel"
	ln -snf /etc/init.d/${initd} "${ROOT}"/etc/runlevels/boot/${initd}
}
add_boot_init_mit_config() {
	local config=$1 initd=$2
	if [[ -e ${ROOT}${config} ]] ; then
		if [[ -n $(sed -e 's:#.*::' -e '/^[[:space:]]*$/d' "${ROOT}"/${config}) ]] ; then
			add_boot_init ${initd}
		fi
	fi
}

pkg_preinst() {

	# backup user hostname setting
        if [ -f "${HOSTNAME_CONF}" ]; then
                cp -p "${HOSTNAME_CONF}" "${HOSTNAME_CONF}.sabayon_backup"
        fi


	local f

	# default net script is just comments, so no point in biting people
	# in the ass by accident
	mv "${D}"/etc/conf.d/net "${T}"/
	[[ -e ${ROOT}/etc/conf.d/net ]] && cp "${ROOT}"/etc/conf.d/net "${T}"/

	# upgrade timezone file ... do it before moving clock
	if [[ -e ${ROOT}/etc/conf.d/clock && ! -e ${ROOT}/etc/timezone ]] ; then
		(
		source "${ROOT}"/etc/conf.d/clock
		[[ -n ${TIMEZONE} ]] && echo "${TIMEZONE}" > "${ROOT}"/etc/timezone
		)
	fi

	# /etc/conf.d/clock moved to /etc/conf.d/hwclock
	local clock
	use kernel_FreeBSD && clock="adjkerntz" || clock="hwclock"
	if [[ -e ${ROOT}/etc/conf.d/clock ]] ; then
		mv "${ROOT}"/etc/conf.d/clock "${ROOT}"/etc/conf.d/${clock}
	fi
	if [[ -e ${ROOT}/etc/init.d/clock ]] ; then
		rm -f "${ROOT}"/etc/init.d/clock
	fi
	if [[ -L ${ROOT}/etc/runlevels/boot/clock ]] ; then
		rm -f "${ROOT}"/etc/runlevels/boot/clock
		ln -snf /etc/init.d/${clock} "${ROOT}"/etc/runlevels/boot/${clock}
	fi
	if [[ -L ${ROOT}${LIBDIR}/rc/init.d/started/clock ]] ; then
		rm -f "${ROOT}${LIBDIR}"/rc/init.d/started/clock
		ln -snf /etc/init.d/${clock} "${ROOT}${LIBDIR}"/rc/init.d/started/${clock}
	fi

	# /etc/conf.d/rc is no longer used for configuration
	if [[ -e ${ROOT}/etc/conf.d/rc ]] ; then
		elog "/etc/conf.d/rc is no longer used for configuration."
		elog "Please migrate your settings to /etc/rc.conf as applicable"
		elog "and delete /etc/conf.d/rc"
	fi

	# force net init.d scripts into symlinks
	for f in "${ROOT}"/etc/init.d/net.* ; do
		[[ -e ${f} ]] || continue # catch net.* not matching anything
		[[ ${f} == */net.lo ]] && continue # real file now
		[[ ${f} == *.openrc.bak ]] && continue
		if [[ ! -L ${f} ]] ; then
			elog "Moved net service '${f##*/}' to '${f##*/}.openrc.bak' to force a symlink."
			elog "You should delete '${f##*/}.openrc.bak' if you don't need it."
			mv "${f}" "${f}.openrc.bak"
			ln -snf net.lo "${f}"
		fi
	done

	# termencoding was added in 0.2.1 and needed in boot
	has_version ">=sys-apps/openrc-0.2.1" || add_boot_init termencoding

	# openrc-0.4.0 no longer loads the udev addon
	enable_udev=0
	if [[ ! -e "${ROOT}"/etc/runlevels/sysinit/udev ]] && \
		[[ -e "${ROOT}"/etc/init.d/udev ]] && \
		! has_version ">=sys-apps/openrc-0.4.0"
	then
		# make sure udev is in sysinit if it was enabled before
		local rc_devices=$(
			[[ -f /etc/rc.conf ]] && source /etc/rc.conf
			[[ -f /etc/conf.d/rc ]] && source /etc/conf.d/rc
			echo "${rc_devices:-${RC_DEVICES:-auto}}"
		)
		case ${rc_devices} in
			udev|auto)
				enable_udev=1
				;;
		esac
	fi

	# skip remaining migration if we already have openrc installed
	has_version sys-apps/openrc && return 0

	# baselayout boot init scripts have been split out
	for f in $(cd "${D}"/usr/share/${PN}/runlevels/boot || exit; echo *) ; do
		add_boot_init ${f}
	done

	# Try to auto-add some addons when possible
	add_boot_init_mit_config /etc/conf.d/cryptfs dmcrypt
	add_boot_init_mit_config /etc/conf.d/dmcrypt dmcrypt
	add_boot_init_mit_config /etc/mdadm.conf mdraid
	add_boot_init_mit_config /etc/evms.conf evms
	[[ -e ${ROOT}/sbin/dmsetup ]] && add_boot_init device-mapper
	[[ -e ${ROOT}/sbin/vgscan ]] && add_boot_init lvm
	elog "Add on services (such as RAID/dmcrypt/LVM/etc...) are now stand alone"
	elog "init.d scripts.  If you use such a thing, make sure you have the"
	elog "required init.d scripts added to your boot runlevel."

	# Upgrade out state for baselayout-1 users
	if [[ ! -e ${ROOT}${LIBDIR}/rc/init.d/started ]] ; then
		(
		[[ -e ${ROOT}/etc/conf.d/rc ]] && source "${ROOT}"/etc/conf.d/rc
		svcdir=${svcdir:-/var/lib/init.d}
		if [[ ! -d ${ROOT}${svcdir}/started ]] ; then
			ewarn "No state found, and no state exists"
			elog "You should reboot this host"
		else
			mkdir -p "${ROOT}${LIBDIR}/rc/init.d"
			einfo "Moving state from ${ROOT}${svcdir} to ${ROOT}${LIBDIR}/rc/init.d"
			mv "${ROOT}${svcdir}"/* "${ROOT}${LIBDIR}"/rc/init.d
			rm -rf "${ROOT}${LIBDIR}"/rc/init.d/daemons \
				"${ROOT}${LIBDIR}"/rc/init.d/console
			umount "${ROOT}${svcdir}" 2>/dev/null
			rm -rf "${ROOT}${svcdir}"
		fi
		)
	fi

	# Handle the /etc/modules.autoload.d -> /etc/conf.d/modules transition
	if [[ -d ${ROOT}/etc/modules.autoload.d ]] ; then
		elog "Converting your /etc/modules.autoload.d/ files to /etc/conf.d/modules"
		rm -f "${ROOT}"/etc/modules.autoload.d/.keep*
		rmdir "${ROOT}"/etc/modules.autoload.d 2>/dev/null
		if [[ -d ${ROOT}/etc/modules.autoload.d ]] ; then
			local f v
			for f in "${ROOT}"/etc/modules.autoload.d/* ; do
				v=${f##*/}
				v=${v#kernel-}
				v=${v//[^[:alnum:]]/_}
				gawk -v v="${v}" -v f="${f##*/}" '
				BEGIN { print "\n### START: Auto-converted from " f "\n" }
				{
					if ($0 ~ /^[^#]/) {
						print "modules_" v "=\"${modules_" v "} " $1 "\""
						gsub(/[^[:alnum:]]/, "_", $1)
						printf "module_" $1 "_args_" v "=\""
						for (i = 2; i <= NF; ++i) {
							if (i > 2)
								printf " "
							printf $i
						}
						print "\"\n"
					} else
						print
				}
				END { print "\n### END: Auto-converted from " f "\n" }
				' "${f}" >> "${D}"/etc/conf.d/modules
			done
				rm -f "${f}"
			rmdir "${ROOT}"/etc/modules.autoload.d 2>/dev/null
		fi
	fi
}

pkg_postinst() {

        # copy hostname file over
        if [ -f "${HOSTNAME_CONF}.backup" ]; then
                cp ${HOSTNAME_CONF}.sabayon_backup ${HOSTNAME_CONF} -p
	elif [ -f "${HOSTNAME_CONF}.example" ]; then
		cp ${HOSTNAME_CONF}.example ${HOSTNAME_CONF} -p
        fi


	# Remove old baselayout links
	rm -f "${ROOT}"/etc/runlevels/boot/{check{fs,root},rmnologin}

	[[ -e ${T}/net && ! -e ${ROOT}/etc/conf.d/net ]] && mv "${T}"/net "${ROOT}"/etc/conf.d/net

	# Make our runlevels if they don't exist
	if [[ ! -e ${ROOT}/etc/runlevels ]] ; then
		einfo "Copying across default runlevels"
		cp -RPp "${ROOT}"/usr/share/${PN}/runlevels "${ROOT}"/etc
	else
		if [[ ! -e ${ROOT}/etc/runlevels/sysinit/devfs ]] ; then
			mkdir -p "${ROOT}"/etc/runlevels/sysinit
			cp -RPp "${ROOT}"/usr/share/${PN}/runlevels/sysinit/* \
				"${ROOT}"/etc/runlevels/sysinit
		fi
		if [[ ! -e ${ROOT}/etc/runlevels/shutdown/mount-ro ]] ; then
			mkdir -p "${ROOT}"/etc/runlevels/shutdown
			cp -RPp "${ROOT}"/usr/share/${PN}/runlevels/shutdown/* \
				"${ROOT}"/etc/runlevels/shutdown
		fi
	fi

	if [[ "$enable_udev" = 1 ]]; then
		elog "Auto adding udev init script to the sysinit runlevel"
		ln -sf /etc/init.d/udev "${ROOT}"/etc/runlevels/sysinit/udev
	fi

	# update the dependency tree bug #224171
	[[ "${ROOT}" = "/" ]] && "${ROOT}/${LIBDIR}"/rc/bin/rc-depend -u

	if [[ -d ${ROOT}/etc/modules.autoload.d ]] ; then
		ewarn "/etc/modules.autoload.d is no longer used.  Please convert"
		ewarn "your files to /etc/conf.d/modules and delete the directory."
	fi

	elog "You should now update all files in /etc, using etc-update"
	elog "or equivalent before restarting any services or this host."
	elog
	elog "Please read the migration guide available at:"
	elog "http://www.gentoo.org/doc/en/openrc-migration.xml"
}
