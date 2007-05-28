DESCRIPTION="Jabbin is an Open Source Jabber client program that allows free PC to PC calls using the VoIP system over the Jabber network."
HOMEPAGE="http://www.jabbin.com/"
VER="2.0beta2a"
SRC_URI="mirror://sourceforge/${PN}/${PN}-${VER}.tar.bz2 http://pub.jcw.pl/linux/${PN}/${PN}-${VER}_amd64.patch.tar.bz2"

inherit eutils qt3

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RESTRICT="mirror primaryuri"

DEPEND="=x11-libs/qt-3*
	net-misc/rsync
	>=app-crypt/qca-1.0
	media-libs/speex
	net-libs/libjingle
	>=sys-libs/zlib-1.1.4
	dev-libs/jrtplib
	dev-libs/ilbc-rfc3951"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack "${PN}-${VER}.tar.bz2"
	if [ ${ARCH} = "amd64" ] ; then
    		unpack "${PN}-${VER}_amd64.patch.tar.bz2"
	fi
	mv -v "${PN}-${VER}" "${P}"

	#cd ${S}
	#epatch ${FILESDIR}/${PN}-system-libgingle.patch

}

src_compile() {
	if [ ${ARCH} = "amd64" ] ; then
	    patch -t -p1 < "${PN}-${VER}_amd64.patch"
	fi
	chmod +x ./configure
	econf || die "could not configure"
	QMAKE=/usr/qt/3/bin/qmake QTDIR=/usr/qt/3 qmake QTDIR=/usr/qt/3 QMAKE=/usr/qt/3/bin/qmake jabbin.pro
	QMAKE=/usr/qt/3/bin/qmake QTDIR=/usr/qt/3 make QTDIR=/usr/qt/3 QMAKE=/usr/qt/3/bin/qmake qmake
	QMAKE=/usr/qt/3/bin/qmake QTDIR=/usr/qt/3 make QTDIR=/usr/qt/3 QMAKE=/usr/qt/3/bin/qmake
}

src_install() {
	dobin src/jabbin
	dodoc README INSTALL COPYING
	dodir /usr/share/jabbin
	rsync -rlptDv --exclude=.svn --exclude=readme sound iconsets "${D}"/usr/share/jabbin/
}

