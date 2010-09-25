# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

# Don't change the order they are grouped by upstream categories:
# (easyer to add new template packages)
# Home & Family
# At the Office
# Creative Concepts
# Fun Outdoors
# Special Occasions
# Odds and Ends
TL="Food-n-Family Hobby Floral KidsKorner
	Business 9-to-5 Architecture
	Art Fantasy Urban Tattoo Music Mythology Tribal StreetStyle KickinIt GrabBag
	Sports Athletic Travel Animal Nature
	Wedding SpecialOccasion Holiday Bridal Seasonal LifeEvents Celebration
	Bonus QuickAndSimple"

DESCRIPTION="Theme files for LightScribe"
HOMEPAGE="http://www.lightscribe.com/ideas/index_top.aspx"

SRC_URI=""
for template in ${TL}
do
	SRC_URI="${SRC_URI} http://download.lightscribe.com/ls/TL_${template}Pack${PV}.tar.gz"
done

LICENSE="lightscribe"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}"

DEPEND=""
RDEPEND=""

RESTRICT="mirror"

src_unpack() {
	for template in ${TL}
	do
		mkdir ${template}
		pushd ${template}
		unpack TL_${template}Pack${PV}.tar.gz
		popd
	done
}

src_install() {
	for template in ${TL}
	do
		insinto /opt/lightscribe/template/${template}
		doins ${template}/*
	done
}
