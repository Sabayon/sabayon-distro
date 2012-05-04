# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

if [[ ${PV} == "9999" ]] ; then
    inherit git
    EGIT_REPO_URI="git://github.com/andoma/tvheadend.git"
    KEYWORDS="~x86"
else
    SRC_URI="http://www.lonelycoder.com/debian/dists/hts/main/source/hts-tvheadend_${PV}.tar.gz"
    KEYWORDS="~amd64 ~x86"
    S="${WORKDIR}/hts-${P}"
fi

DESCRIPTION="Tvheadend is a combined DVB receiver, Digital Video Recorder and Live TV streaming server"
HOMEPAGE="http://www.lonelycoder.com/hts/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="avahi xmltv"

DEPEND="virtual/linuxtv-dvb-headers"

RDEPEND="${DEPEND}
    xmltv? ( media-tv/xmltv )
    avahi? ( net-dns/avahi-base )"

pkg_setup() {
    enewuser tvheadend -1 -1 /dev/null video
}

src_prepare() {
    if [[ ${PV} == "9999" ]] ; then
        # set version number to avoid subversion dependency
        sed -i \
            -e 's:\$(shell support/version.sh):${PV}:' \
            Makefile || die "sed failed!"
    else
        # set version number to avoid subversion and git dependency
        sed -i \
            -e 's:\$(shell support/version.sh):git-${EGIT_VERSION}:' \
            Makefile || die "sed failed!"
    fi

    # remove stripping
    sed -i \
        -e 's:install -s:install:' \
        support/posix.mk || die "sed failed!"
}

src_configure() {
    econf \
        $(use_enable avahi) \
        --release \
        || die "Configure failed!"
}

src_install() {
    emake DESTDIR="${D}" install || die "Install failed!"

    dodoc ChangeLog README
    doman man/tvheadend.1

    newinitd "${FILESDIR}/tvheadend.initd" tvheadend
    newconfd "${FILESDIR}/tvheadend.confd" tvheadend

    dodir /etc/tvheadend
    fperms 0700 /etc/tvheadend
    fowners tvheadend:video /etc/tvheadend
}

pkg_postinst() {
    elog "To start Tvheadend:"
    elog "/etc/init.d/tvheadend start"
    elog
    elog "To start Tvheadend at boot:"
    elog "rc-update add tvheadend default"
    elog
    elog "The Tvheadend web interface can be reached at:"
    elog "http://localhost:9981/"
    elog
    elog "Make sure that you change the default username"
    elog "and password via the Configuration / Access control"
    elog "tab in the web interface."
}

