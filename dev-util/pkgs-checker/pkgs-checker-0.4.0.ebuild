# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/Sabayon/${PN}"
S="${WORKDIR}/${P}/src/${EGO_PN}"

inherit golang-vcs golang-build user systemd git-r3

DESCRIPTION="Sabayon Packages Checker"
HOMEPAGE="https://github.com/Sabayon/pkgs-checker"

KEYWORDS="~amd64 ~arm ~arm64"
RESTRICT="mirror"

EGIT_CHECKOUT_DIR="${S}"
EGIT_REPO_URI="https://${EGO_PN}"

if [[ ${PV} == *9999 ]]; then
	EGIT_BRANCH="master"
else
	EGIT_COMMIT="v${PV}"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""
DEPEND=""
RDEPEND=""

src_install() {
	dobin pkgs-checker
}
