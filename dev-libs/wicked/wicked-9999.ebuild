# Copyright 1999-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
inherit git

EGIT_REPO_URI="git://git.glacicle.com/awesome/wicked.git"

DESCRIPTION="Wicked widgets for the awesome window manager"
HOMEPAGE="http://git.glacicle.com/?p=awesome/wicked.git;a=summary"

SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="dev-lang/lua"
DEPEND="${RDEPEND}"

src_install()
{
	doman "${PN}.7.gz"
	insinto "${ROOT}/usr/share/awesome/lib"
	doins "${PN}.lua"
}
