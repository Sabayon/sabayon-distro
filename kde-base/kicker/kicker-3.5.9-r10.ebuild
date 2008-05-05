# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

KMNAME=kdebase
EAPI="1"
inherit kde-meta kde-meta-suse eutils

SRC_URI="${SRC_URI}
	mirror://gentoo/kdebase-3.5-patchset-03.tar.bz2"

DESCRIPTION="Kicker is the KDE application starter panel, also capable of some useful applets and extensions."
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="kdehiddenvisibility xcomposite kickoff"

RDEPEND="
>=kde-base/libkonq-${PV}:${SLOT}
>=kde-base/kdebase-data-${PV}:${SLOT}
	x11-libs/libXau
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXtst
	xcomposite? ( x11-libs/libXcomposite )
	kickoff? ( app-misc/beagle:0 dev-libs/liblazy )"

DEPEND="${RDEPEND}"

KMCOPYLIB="libkonq libkonq"
KMEXTRACTONLY="libkonq
	kdm/kfrontend/themer/"
KMCOMPILEONLY="kdmlib/"

src_unpack() {

        if use kickoff; then

	        kde-meta-suse_src_unpack

                # Add Kickoff support
                epatch "${FILESDIR}/kicker-3.5.6.kickoff-r649417.diff"

                # Sabayon Linux integration
                epatch "${FILESDIR}/kickoff-sabayonlinux-integration-r649417.patch"

                # Fix KickOff button size
                epatch ${FILESDIR}/${PN}-3.5.7-fix-kickoff-button.patch

                # Fix Compiz Fusion freeze
                epatch ${FILESDIR}/${PN}-3.5.7-fix-kickoff-freeze.patch

                # Fix undeclared bool
                epatch ${FILESDIR}/${PN}-3.5.8-fix-kickertip.h.patch

                # Revert some SVN changes
                epatch ${FILESDIR}/${PN}-3.5.8-fix-revert-pagerapplet-changes.patch

                # copy icons over
                tar xjf ${FILESDIR}/kickoff-icons-r649417.tar.bz2 -C ${WORKDIR}/${PN}-${PV}/${PN}/data

        else
		kde-meta_src_unpack
	fi

}


src_compile() {

	myconf="$myconf $(use_with xcomposite composite)"

        if use kickoff; then

                # BUG HUNTERS - DO NOT REPORT BUGS AGAINST THIS EBUILD
                # AUTOMAKE IS BROKEN (AND CANNOT BE USED WITHOUT THESE
                # WORKAROUNDS) WITH SUSE_KICKOFF BRANCH
                # WE WILL ONLY ACCEPT REAL SOLUTIONS

                export UNSERMAKE="no"

                kde-meta-suse_src_compile

                # First try
                sed -i '/SUBDIRS/ s/ui core/core ui/' kicker/kicker/Makefile.am
                emake

                # Second try
                sed -i '/SUBDIRS/ s/core ui/interfaces core ui/' kicker/kicker/Makefile.am
                emake

                # Third try
                sed -i '/SUBDIRS/ s/interfaces core ui/ui interfaces core ui/' kicker/kicker/Makefile.am
                emake

        else

                kde-meta_src_compile

        fi


}
