# Copyright 1999-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: transmission-2.52.eclass
# @MAINTAINER:
# slawomir.nizio@sabayon.org
# @AUTHOR:
# Sławomir Nizio <slawomir.nizio@sabayon.org>
# @BLURB: eclass to ease managing of Sabayon split net-p2p/transmission
# @DESCRIPTION:
# This eclass is to ease managing of split net-p2p/transmission for Sabayon.
# Its name contains a version that corresponds to net-p2p/transmission one,
# because the eclass will change often when needed to follow changes
# in Gentoo ebuild.

# @ECLASS-VARIABLE: TRANSMISSION_ECLASS_VERSION_OK
# @DESCRIPTION:
# Set this to x.y if you want to use transmission-x.y.eclass from ebuild
# with ${PV} different than x.y. This is to catch bugs.
: ${TRANSMISSION_ECLASS_VERSION_OK:=${PV}}

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

LANGS="en es kk lt pt_BR ru" # used only for -qt

unset _live_inherits
if [[ ${PV} == *9999* ]]; then
	# not tested in the eclass
	ESVN_REPO_URI="svn://svn.transmissionbt.com/Transmission/trunk"
	_live_inherits=subversion
fi

MY_ECLASSES=""
_transmission_is gtk && MY_ECLASSES+="fdo-mime gnome2-utils"
_transmission_is qt4 && MY_ECLASSES+="fdo-mime qt4-r2"
_transmission_is "" || MY_ECLASSES+=" autotools"

inherit eutils multilib ${MY_ECLASSES} ${_live_inherits}

unset MY_ECLASSES

case ${EAPI:-0} in
	4|3) EXPORT_FUNCTIONS pkg_setup src_prepare src_configure src_compile \
		pkg_preinst pkg_postinst pkg_postrm ;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

[[ ${PN} = transmission* ]] || \
	die "This eclass can only be used with net-p2p/transmission* ebuilds!"
# Bug catcher!
if ! [[ ${PV} = *9999* ]] && [[ ${TRANSMISSION_ECLASS_VERSION_OK} != ${ECLASS#*-} ]]; then
	eerror "used eclass ${ECLASS}"
	eerror "TRANSMISSION_ECLASS_VERSION_OK=${TRANSMISSION_ECLASS_VERSION_OK}"
	die "ebuild version ${PV} doesn't match with the eclass"
fi

MY_PN="transmission"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${MY_PN}/files/${MY_P}.tar.xz"

LICENSE="GPL-2 MIT"
SLOT="0"
IUSE=""

# only common dependencies plus blockers
RDEPEND=""
_transmission_is base || RDEPEND+="~net-p2p/transmission-base-${PV}"
if ! _transmission_is ""; then
	RDEPEND+="
	>=dev-libs/libevent-2.0.10
	dev-libs/openssl:0
	>=net-libs/miniupnpc-1.6.20120509
	>=net-misc/curl-7.16.3[ssl]
	net-libs/libnatpmp
	sys-libs/zlib"
fi

DEPEND="${RDEPEND}"
if _transmission_is base; then
	RDEPEND+=" !<net-p2p/transmission-gtk-${PV}
	!<net-p2p/transmission-qt4-${PV}
	!<net-p2p/transmission-daemon-${PV}
	!<net-p2p/transmission-cli-${PV}"
fi
if ! _transmission_is ""; then
	DEPEND+=" dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	virtual/os-headers"
fi

S="${WORKDIR}/${MY_P}"
_transmission_is "" && S="${WORKDIR}"

transmission-2.52_pkg_setup() {
	if _transmission_is base; then
		enewgroup transmission
		enewuser transmission -1 -1 -1 transmission
	fi
}

transmission-2.52_src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		subversion_src_unpack
	else
		default
	fi
}

transmission-2.52_src_prepare() {
	_transmission_is "" && return

	if [[ ${PV} == *9999* ]]; then
		subversion_src_prepare
		./update-version-h.sh
	fi

	sed -i -e '/CFLAGS/s:-ggdb3::' configure.ac || die

	if ! use_if_iuse ayatana; then
		sed -i -e '/^LIBAPPINDICATOR_MINIMUM/s:=.*:=9999:' configure.ac || die
	fi

	# http://trac.transmissionbt.com/ticket/4324
	sed -i -e 's|noinst\(_PROGRAMS = $(TESTS)\)|check\1|' lib${MY_PN}/Makefile.am || die

	# [eclass] patch for FreeBSD skipped

	eautoreconf

	if _transmission_is qt4; then
		cat <<-EOF > "${T}"/${MY_PN}-magnet.protocol
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

	if ! _transmission_is base; then
		local sedcmd="s:\$(top_builddir)/libtransmission/libtransmission.a:"
		sedcmd+="${EROOT}usr/$(get_libdir)/libtransmission.a:"
		find . -name Makefile.in -exec sed -i -e "${sedcmd}" {} \; || die
		sed -i -e '/libtransmission \\/d' Makefile.in || die
		if _transmission_is qt4; then
			sedcmd="s:\$\${TRANSMISSION_TOP}/libtransmission/libtransmission.a:"
			sedcmd+="${EROOT}usr/$(get_libdir)/libtransmission.a:"
			sed -i -e "${sedcmd}" qt/qtr.pro || die
		fi
	fi
}

transmission-2.52_src_configure() {
	_transmission_is "" && return

	local econfargs=(
		--enable-external-natpmp
	)

	if _transmission_is base; then
		export ac_cv_header_xfs_xfs_h=$(usex xfs)
		econfargs+=(
			--disable-cli
			--disable-daemon
			--without-gtk
			$(use_enable lightweight)
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
		econfargs+=(
			--disable-cli
			--disable-daemon
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

	econf "${econfargs[@]}"
	if _transmission_is qt4; then
		pushd qt >/dev/null
		eqmake4 qtr.pro
		popd >/dev/null
	fi
}

transmission-2.52_src_compile() {
	_transmission_is "" && return

	emake
	if _transmission_is qt4; then
		pushd qt >/dev/null
		emake

		local l
		for l in ${LANGS}; do
			if use linguas_${l}; then
				lrelease translations/${MY_PN}_${l}.ts
			fi
		done
		popd >/dev/null
	fi
}


# Note: not providing src_install. Too many differences and too much code
# which would only clutter this pretty eclass.

transmission-2.52_pkg_preinst() {
	_transmission_is gtk && gnome2_icon_savelist
}

transmission-2.52_pkg_postinst() {
	if _transmission_is gtk || _transmission_is qt4; then
		fdo-mime_desktop_database_update
	fi

	_transmission_is gtk && gnome2_icon_cache_update

	if _transmission_is daemon; then
		elog "If you use ${MY_PN}-daemon, please, set 'rpc-username' and"
		elog "'rpc-password' (in plain text, ${MY_PN}-daemon will hash it on"
		elog "start) in settings.json file located at /var/${MY_PN}/config or"
		elog "any other appropriate config directory."
	fi

	if _transmission_is gtk; then
		# in -gtk only?
		elog
		elog "To enable sound emerge media-libs/libcanberra and check that at least"
		elog "some sound them is selected. For this go:"
		elog "Gnome/system/preferences/sound themes tab and 'sound theme: default'"
		elog
	fi

	elog "Since µTP is enabled by default, ${MY_PN} needs large kernel buffers for"
	elog "the UDP socket. You can append following lines into /etc/sysctl.conf:"
	elog " net.core.rmem_max = 4194304"
	elog " net.core.wmem_max = 1048576"
	elog "and run sysctl -p"
}

transmission-2.52_pkg_postrm() {
	if _transmission_is gtk || _transmission_is qt4; then
		fdo-mime_desktop_database_update
	fi

	_transmission_is gtk && gnome2_icon_cache_update
}
