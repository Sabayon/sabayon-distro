# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: $

EAPI=6

SRC_URI="https://github.com/Sabayon/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="https://github.com/Sabayon/enman"
inherit perl-module

DESCRIPTION="a layman equivalent for entropy repositories"

SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE=""

DEPEND="
    dev-perl/Module-Build
"
RDEPEND="
    dev-perl/App-Cmd
    dev-perl/LWP-Protocol-https
    virtual/perl-Encode
    dev-perl/libwww-perl
    dev-perl/libintl-perl
    virtual/perl-Term-ANSIColor
    ${DEPEND}"

SRC_TEST="do"
