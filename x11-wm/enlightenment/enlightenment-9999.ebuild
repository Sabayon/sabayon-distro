# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

ESVN_URI_APPEND="e"
inherit enlightenment

DESCRIPTION="Enlightenment DR17 window manager"

SLOT="0.17"

# The @ is just an anchor to expand from
__EVRY_MODS="+@apps +@calc +@files +@settings +@windows"
__CONF_MODS="
	+@applications +@borders +@clientlist +@colors +@desk +@desklock +@desks
	+@dialogs +@display +@dpms +@edgebindings +@engine +@fonts +@icon-theme
	+@imc +@interaction +@intl +@keybindings +@menus +@mime +@mouse
	+@mousebindings +@mouse-cursor +@paths +@performance +@profiles +@scale
	+@screensaver +@shelves +@startup +@theme +@transitions +@wallpaper
	+@wallpaper2 +@window-display +@window-focus +@window-manipulation
	+@window-remembers +@winlist"
__NORM_MODS="
	+@battery +@clock +@comp +@connman +@cpufreq +@dropshadow +@fileman
	+@fileman_opinfo +@gadman +@ibar +@ibox @illume +@illume2 +@mixer
	+@msgbus @ofono +@pager +@start +@syscon +@systray +@temperature
	+@winlist +@wizard"
IUSE_E_MODULES="+e_modules_everything ${__EVRY_MODS//@/e_modules_everything-}
	${__CONF_MODS//@/e_modules_conf-}
	${__NORM_MODS//@/e_modules_}"

KEYWORDS="~amd64 ~x86"
IUSE="acpi bluetooth exchange hal pam spell static-libs +udev ${IUSE_E_MODULES}"

RDEPEND="exchange? ( >=app-misc/exchange-9999 )
	pam? ( sys-libs/pam )
	>=dev-libs/efreet-9999
	>=dev-libs/eina-9999[mempool-chained]
	>=dev-libs/ecore-9999[X,evas,inotify]
	>=media-libs/edje-9999
	>=dev-libs/e_dbus-9999[hal?,libnotify,udev?]
	!hal? ( >=dev-libs/e_dbus-9999[udev] )
	e_modules_connman? ( >=dev-libs/e_dbus-9999[connman] )
	e_modules_ofono? ( >=dev-libs/e_dbus-9999[ofono] )
	e_modules_illume? ( >=dev-libs/e_dbus-9999[hal] )
	>=media-libs/evas-9999[eet,X,jpeg,png]
	bluetooth? ( net-wireless/bluez )
	udev? ( dev-libs/eeze )
	spell? ( app-text/aspell )
	e_modules_everything-calc? ( sys-devel/bc )"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/quickstart.diff
	enlightenment_src_prepare
}

src_configure() {
	export MY_ECONF="
		--disable-install-sysactions
		$(use_enable acpi conf-acpibindings)
		$(use_enable bluetooth bluez)
		$(use_enable doc)
		$(use_enable exchange)
		$(use_enable hal device-hal)
		$(use_enable hal mount-hal)
		$(use_enable nls)
		$(use_enable pam)
		$(use_enable spell everything-aspell)
		$(use_enable udev device-udev)
		$(use_enable udev mount-udisks)
	"
	if ( !use hal && !use udev ); then
		ECONF+=" --enable device.udev --enable-mount-udev"
		einfo "Either hal or udev USE flag required"
		einfo "enabling udev support by default"
	fi
	local u c
	for u in ${IUSE_E_MODULES} ; do
		u=${u#+}
		c=${u#e_modules_}
		MY_ECONF+=" $(use_enable ${u} ${c})"
	done
	#enable e_modules_everything, if any of the everything modules is enabled
	for u in ${__EVRY_MODS} ; do
		u=${u#+}
		c=${u//@/e_modules_everything-}
		if use ${c} ; then
			MY_ECONF+=" --enable-everything"
			ewarn "You enabled everything modules without"
			ewarn "enabling everything itself. Enabling everything"
			continue
		fi
	done
	if use e_modules_illume2 && use e_modules_illume ; then
		ewarn "You enabled both illume2 and illume modules,"
		ewarn "but only one of them can be active."
		ewarn "illume will be disabled"
	fi
	use e_modules_illume2 && MY_ECONF+=" --disable-illume"
	enlightenment_src_configure
}

src_install() {
	enlightenment_src_install
	insinto /etc/enlightenment
	newins "${FILESDIR}"/gentoo-sysactions.conf sysactions.conf || die
}
