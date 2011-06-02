# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit gnome2

DESCRIPTION="Adds a 'Resize Images' item to the context menu for all images"
HOMEPAGE="http://www.bitron.ch/software/nautilus-image-converter.php"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=gnome-base/nautilus-2.21.0"
RDEPEND="${DEPEND}
	|| ( media-gfx/imagemagick media-gfx/graphicsmagick[imagemagick] )"

DOCS="AUTHORS ChangeLog NEWS README"
