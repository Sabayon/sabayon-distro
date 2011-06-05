# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2:2.5"

inherit versionator bash-completion linux-info prefix distutils

DESCRIPTION="A program used to manage a netfilter firewall"
HOMEPAGE="http://launchpad.net/ufw"
MY_PV_12=$(get_version_component_range 1-2)
SRC_URI="http://launchpad.net/ufw/${MY_PV_12}/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

DEPEND=""
RDEPEND=">=net-firewall/iptables-1.4"

RESTRICT="test"

pkg_setup() {
	local CONFIG_CHECK="~PROC_FS ~NETFILTER_XT_MATCH_COMMENT ~IP6_NF_MATCH_HL \
		~NETFILTER_XT_MATCH_LIMIT ~NETFILTER_XT_MATCH_MULTIPORT \
		~NETFILTER_XT_MATCH_RECENT ~NETFILTER_XT_MATCH_STATE"

	if kernel_is -ge 2 6 39; then
		CONFIG_CHECK="${CONFIG_CHECK} ~NETFILTER_XT_MATCH_ADDRTYPE"
	else
		CONFIG_CHECK="${CONFIG_CHECK} ~IP_NF_MATCH_ADDRTYPE"
	fi

	check_extra_config
}

src_prepare() {
	cp "${FILESDIR}"/ufw.initd "${T}/" \
		|| die "copying file to temporary directory failed"
	eprefixify "${T}"/ufw.initd
	# Set as enabled by default. User can enable or disable
	# the service by adding or removing it to/from a runlevel.
	sed -i 's/^ENABLED=no/ENABLED=yes/' conf/ufw.conf \
		|| die "sed failed (ufw.conf)"
}

src_install() {
	newconfd "${FILESDIR}"/ufw.confd ufw || die "inserting a file to conf.d failed"
	newinitd "${T}"/ufw.initd ufw || die "inserting a file to init.d failed"
	cat <<-EOF > "${T}"/99ufw
	CONFIG_PROTECT="${EPREFIX}/lib/ufw/user6.rules ${EPREFIX}/lib/ufw/user.rules"
	EOF
	doenvd "${T}"/99ufw || die "doenvd failed"
	if use examples; then
		dodoc doc/rsyslog.example || die "inserting example rsyslog configuration failed"
		insinto /usr/share/doc/${PF}/examples
		doins examples/* || die "inserting example files failed"
	fi
	distutils_src_install
	dobashcompletion shell-completion/bash
}

pkg_postinst() {
	distutils_pkg_postinst
	elog "Remember to enable ufw add it to your boot sequence:"
	elog "-- # ufw enable"
	elog "-- # rc-update add ufw boot"
	echo
	bash-completion_pkg_postinst
}
