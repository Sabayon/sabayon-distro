# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/Sabayon/${PN}"
S="${WORKDIR}/${P}/src/${EGO_PN}"

if [[ ${PV} == *9999 ]]; then
	inherit golang-vcs
else
#	SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64"
	RESTRICT="mirror"
	inherit golang-vcs git-r3
	EGIT_REPO_URI="https://${EGO_PN}"
	EGIT_COMMIT="95d242ad69567657ee2a0393b59319cbb8fffc4e"
	EGIT_CHECKOUT_DIR="${S}"
fi

inherit golang-build user systemd
DESCRIPTION="Sabayon Packages Checker"
HOMEPAGE="https://github.com/Sabayon/pkgs-checker"

LICENSE="GPL-3"
SLOT="0"
IUSE="systemd"
DEPEND=""
RDEPEND=""

src_install() {
	dobin pkgs-checker
}

