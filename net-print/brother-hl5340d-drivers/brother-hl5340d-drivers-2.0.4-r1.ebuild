# Copyright 1999-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils multilib rpm

WRAPPER_VER="2.0.4-1"
LPR_VER="2.0.3-1"

DESCRIPTION="CUPS filters and drivers for Brother HL-5340D"
HOMEPAGE="http://welcome.solutions.brother.com/bsc/public_s/id/linux/en/download_prn.html"
SRC_URI="http://www.brother.com/pub/bsc/linux/dlf/hl5340dlpr-${LPR_VER}.i386.rpm
	http://www.brother.com/pub/bsc/linux/dlf/cupswrapperHL5340D-${WRAPPER_VER}.i386.rpm
	http://www.brother.com/pub/bsc/linux/dlf/BR5340_2_GPL.ppd.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="${DEPEND}"
RDEPEND="amd64? ( app-emulation/emul-linux-x86-baselibs )
	app-text/ghostscript-gpl
	net-print/cups"

S="${WORKDIR}"
RESTRICT="strip"

src_prepare() {
	default
	epatch "${FILESDIR}/cupswrapper.patch"
}

src_install() {
	# Thanks to the Arch folks!
	mkdir -p usr/share || die
	mv "${S}/usr/local/Brother" "${S}/usr/share/brother" || die

	# Fix paths, move away from /usr/local
	sed -i "s;/usr/local/Brother;/usr/share/brother;g" $(grep -rl "/usr/local/Brother" .) || die

	# Create and install the file 'brPrintList'. This file must exist and contain the name
	# of the printer in order to make CUPS settings work. Else, settings done in CUPS are
	# not reflected in the file /usr/share/brother/inf/brHL5340Drc and thus are not considered
	# by the LPR driver that's doing the actual printing.
	mkdir -p "${S}/usr/share/brother/inf" || die
	echo "HL5340D" > "${S}/usr/share/brother/inf/brPrintList" || die

	# Generate the cups filter
	cd "${S}" || die
	./usr/share/brother/cupswrapper/cupswrapperHL5340D-2.0.4 || die
	insinto /usr/share/cups/model
	newins "${WORKDIR}/BR5340_2_GPL.ppd" HL5340D.ppd
	exeinto /usr/libexec/cups/filter
	doexe brlpdwrapperHL5340D || die

	# move /usr/local crap to /usr/share
	dodir /usr/share
	cd "${S}/usr/share" || die
	insinto /usr/share
	# preserve permissions
	cp -rp brother "${D}/usr/share/" || die
	fperms 0755 /usr/share/brother/inf/brHL5340Drc

	dodir /usr/$(get_libdir)
	exeinto /usr/$(get_libdir)
	doexe "${S}"/usr/lib/*

	dodir /usr/bin
	exeinto /usr/bin
	doexe "${S}"/usr/bin/*
}
