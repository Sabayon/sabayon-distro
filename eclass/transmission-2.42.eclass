# Copyright 1999-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: transmission-2.42.eclass
# @MAINTAINER:
# slawomir.nizio@sabayon.org
# @AUTHOR:
# Sławomir Nizio <slawomir.nizio@sabayon.org>
# @BLURB: eclass to ease managing of Sabayon split net-p2p/transmission
# @DESCRIPTION:
# This experimental eclass is to ease managing of split net-p2p/transmission
# for Sabayon.
# Its name contains a version that corresponds to net-p2p/transmission one,
# because the eclass will change often when needed to follow changes
# in Gentoo ebuild.

# @ECLASS-VARIABLE: E_TRANSM_TAIL
# @DESCRIPTION:
# "Tail" of package name. Can take value gtk, qt4, etc. or can be empty.
# It shouldn't be modified.
E_TRANSM_TAIL=${PN#transmission}
E_TRANSM_TAIL=${E_TRANSM_TAIL#-}

# @FUNCTION: _transmission_is
# @DESCRIPTION:
# Function used to check which variant of Transmission are we working on.
# Argument should be one of these: (none), gtk, qt4, daemon, cli, base.
# If argument is empty or omitted, true value means that it is
# net-p2p/transmission (metapackage).
# Consider it private.
_transmission_is() {
	local what=$1
	[[ ${what} = "${E_TRANSM_TAIL}" ]]
}

MY_ECLASSES=""
_transmission_is gtk && MY_ECLASSES+="fdo-mime gnome2-utils"
_transmission_is qt4 && MY_ECLASSES+="fdo-mime qt4-r2"
_transmission_is "" || MY_ECLASSES+=" autotools"
# eutils must be here (for in_iuse)
inherit eutils ${MY_ECLASSES}

unset MY_ECLASSES

case ${EAPI:-0} in
	4|3) EXPORT_FUNCTIONS pkg_setup src_prepare src_configure src_compile \
		pkg_preinst pkg_postinst pkg_postrm ;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

[[ ${PN} = transmission* ]] || \
	die "This eclass can only be used with net-p2p/transmission* ebuilds!"

MY_PN="transmission"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${MY_PN}/files/${MY_P}.tar.xz"
_transmission_is "" || \
	SRC_URI+=" http://dev.gentoo.org/~ssuominen/${MY_P}-patchset-1.tar.xz"

LICENSE="GPL-2 MIT"
SLOT="0"
IUSE=""

# only common dependencies plus blockers
RDEPEND=""
_transmission_is base || RDEPEND+="~net-p2p/transmission-base-${PV}"
_transmission_is "" || \
	RDEPEND+="
	>=dev-libs/libevent-2.0.10
	dev-libs/openssl:0
	>=net-misc/curl-7.16.3[ssl]
	net-libs/libnatpmp
	>=net-libs/miniupnpc-1.6
	sys-libs/zlib"

DEPEND="${RDEPEND}"
_transmission_is base && \
	DEPEND+=" !<net-p2p/transmission-gtk-${PV}
	!<net-p2p/transmission-qt-${PV}
	!<net-p2p/transmission-daemon-${PV}
	!<net-p2p/transmission-cli-${PV}"
_transmission_is "" || \
	DEPEND+=" dev-util/intltool
	>=sys-devel/libtool-2.2.6b
	dev-util/pkgconfig
	sys-apps/sed
	sys-devel/gettext"
# note: gettext is always a depend with eautoreconf

S="${WORKDIR}/${MY_P}"
_transmission_is "" && S="${WORKDIR}"

transmission-2.42_pkg_setup() {
	if _transmission_is base; then
		enewgroup transmission
		enewuser transmission -1 -1 -1 transmission
	fi
}

transmission-2.42_src_prepare() {
	_transmission_is "" && return

	# note: this patchset has useless bits for optionalizing UTP which can be
	# dropped from next one
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patches

	# note: http://trac.transmissionbt.com/ticket/4324
	sed -i -e 's|noinst\(_PROGRAMS = $(TESTS)\)|check\1|' libtransmission/Makefile.am || die

	if ! in_iuse ayatana || ! use ayatana; then
		sed -i -e '/^LIBAPPINDICATOR_MINIMUM/s:=.*:=9999:' configure.ac || die
	fi

	sed -i -e '/CFLAGS/s:-ggdb3::' configure.ac || die

	eautoreconf

	if _transmission_is qt4; then
		# note: magnet link support
		if use kde; then
			cat > qt/transmission-magnet.protocol <<-EOF
			[Protocol]
			exec=transmission-qt '%u'
			protocol=magnet
			Icon=transmission
			input=none
			output=none
			helper=true
			listing=
			reading=false
			writing=false
			makedir=false
			deleting=false
			EOF
		fi
	fi
}

transmission-2.42_src_configure() {
	_transmission_is "" && return

	local econfargs=(
		--enable-external-miniupnp
		--enable-external-natpmp
		--enable-utp
	)
	# cli and daemon doesn't have external deps and are enabled by default
	# let's disable them where not needed

	if _transmission_is base; then
		econfargs+=(
			--disable-cli
			--disable-daemon
			--without-gtk
		)
	elif _transmission_is cli; then
		econfargs+=(
			--enable-cli
			--disable-daemon
			--without-gtk
		)
	elif _transmission_is daemon; then
		econfargs+=(
			--disable-cli
			--enable-daemon
			--without-gtk
		)
	elif _transmission_is gtk; then
		# nls is required for Gtk+ client
		econfargs+=(
			--disable-cli
			--disable-daemon
			--enable-nls
			--with-gtk
		)
	elif _transmission_is qt4; then
		econfargs+=(
			--disable-cli
			--disable-daemon
			--without-gtk
		)
	else
		die "Something is wrong... (E_TRANSM_TAIL=$E_TRANSM_TAIL)"
	fi
	in_iuse nls && econfargs+=( $(use_enable nls) )

	econf "${econfargs[@]}"
	_transmission_is qt4 && cd qt && eqmake4 qtr.pro
}

transmission-2.42_src_compile() {
	_transmission_is "" && return

	emake
	_transmission_is qt4 && cd qt && emake
}

# Note: not providing src_install. Too many differences and too much code
# which would only clutter this pretty eclass.

transmission-2.42_pkg_preinst() {
	_transmission_is gtk && gnome2_icon_savelist
}

transmission-2.42_pkg_postinst() {
	if _transmission_is gtk || _transmission_is qt4; then
		fdo-mime_desktop_database_update
	fi

	_transmission_is gtk && gnome2_icon_cache_update

	if _transmission_is daemon; then
		ewarn "If you use transmission-daemon, please, set 'rpc-username' and"
		ewarn "'rpc-password' (in plain text, transmission-daemon will hash it on"
		ewarn "start) in settings.json file located at /var/transmission/config or"
		ewarn "any other appropriate config directory."
	fi

	if _transmission_is gtk; then
		# in -gtk only?
		elog
		elog "To enable sound emerge media-libs/libcanberra and check that at least"
		elog "some sound them is selected. For this go:"
		elog "Gnome/system/preferences/sound themes tab and 'sound theme: default'"
		elog
	fi

	ewarn
	ewarn "Since uTP is enabled ${PN} needs large kernel buffers for the UDP socket."
	ewarn "Please, add into /etc/sysctl.conf following lines:"
	ewarn " net.core.rmem_max = 4194304"
	ewarn " net.core.wmem_max = 1048576"
	ewarn "and run sysctl -p"
}

transmission-2.42_pkg_postrm() {
	if _transmission_is gtk || _transmission_is qt4; then
		fdo-mime_desktop_database_update
	fi

	_transmission_is gtk && gnome2_icon_cache_update
}
