# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

ESVN_URI_APPEND="e"
inherit enlightenment

DESCRIPTION="Enlightenment DR17 window manager"

SLOT="0.17"

# The @ is just an anchor to expand from
__EVRY_MODS=""
__CONF_MODS="
	+@applications +@dialogs +@display +@edgebindings
	+@interaction +@intl +@keybindings +@menus
	+@paths +@performance +@shelves +@theme
	+@wallpaper2 +@window-manipulation +@window-remembers"
__NORM_MODS="
	+@backlight +@battery +@clock +@comp +@connman +@cpufreq +@dropshadow
	+@everything +@fileman +@fileman-opinfo +@gadman +@ibar +@ibox +@illume2
	+@mixer	+@msgbus @ofono +@pager +@shot +@start +@syscon +@systray
	+@temperature +@winlist +@wizard"
IUSE_E_MODULES="
	${__CONF_MODS//@/e_modules_conf-}
	${__NORM_MODS//@/e_modules_}"

KEYWORDS="~amd64 ~x86"
IUSE="bluetooth exchange pam spell static-libs +udev ukit ${IUSE_E_MODULES}"

RDEPEND="exchange? ( >=app-misc/exchange-9999 )
	pam? ( sys-libs/pam )
	>=dev-libs/efreet-9999
	>=dev-libs/eina-9999[mempool-chained]
	|| ( >=dev-libs/ecore-9999[X,evas,inotify] >=dev-libs/ecore-9999[xcb,evas,inotify] )
	>=media-libs/edje-9999
	>=dev-libs/e_dbus-9999[libnotify,udev?]
	ukit? ( >=dev-libs/e_dbus-9999[udev] )
	e_modules_connman? ( >=dev-libs/e_dbus-9999[connman] )
	e_modules_ofono? ( >=dev-libs/e_dbus-9999[ofono] )
	|| ( >=media-libs/evas-9999[eet,X,jpeg,png] >=media-libs/evas-9999[eet,xcb,jpeg,png] )
	bluetooth? ( net-wireless/bluez )
	dev-libs/eeze"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/quickstart.diff
	enlightenment_src_prepare
}

src_configure() {
	export MY_ECONF="
		--disable-install-sysactions
		$(use_enable bluetooth bluez)
		$(use_enable doc)
		$(use_enable exchange)
		--disable-device-hal
		--disable-mount-hal
		$(use_enable nls)
		$(use_enable pam)
		--enable-device-udev
		$(use_enable udev mount-eeze)
		$(use_enable ukit mount-udisks)
	"
	local u c
	for u in ${IUSE_E_MODULES} ; do
		u=${u#+}
		c=${u#e_modules_}
		MY_ECONF+=" $(use_enable ${u} ${c})"
	done
	enlightenment_src_configure
}

src_install() {
	enlightenment_src_install
	insinto /etc/enlightenment
	newins "${FILESDIR}"/gentoo-sysactions.conf sysactions.conf || die
}
