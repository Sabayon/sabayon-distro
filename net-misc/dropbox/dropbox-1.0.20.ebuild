EAPI='3'

DESCRIPTION="Dropbox daemon (pretends to be GUI-less)."
HOMEPAGE="http://dropbox.com/"
SRC_URI="x86? ( http://dl-web.dropbox.com/u/17/dropbox-lnx.x86-${PV}.tar.gz )
	amd64? ( http://dl-web.dropbox.com/u/17/dropbox-lnx.x86_64-${PV}.tar.gz )"

LICENSE="EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror strip"

QA_EXECSTACK_x86="opt/dropbox/_ctypes.so"
QA_EXECSTACK_amd64="opt/dropbox/_ctypes.so"

DEPEND=""
RDEPEND="net-misc/wget"

src_unpack() {
	unpack "${A}"
	mv "${WORKDIR}/.dropbox-dist" "${S}" || die
}

src_install() {
	# We don't need icons and default wrapper.
	rm -rf "${S}/icons" "${S}/dropboxd" || die

	local targetdir="/opt/dropbox"
	insinto "${targetdir}" || die
	doins -r * || die
	doins "${FILESDIR}/dropbox-launcher" || die
	fperms a+x "${targetdir}/dropbox" || die
	fperms a+x "${targetdir}/dropbox-launcher" || die
	dosym "${targetdir}/dropbox-launcher" "${targetdir}/dropboxd" || die
	dosym "${targetdir}/dropbox-launcher" "/opt/bin/dropbox" || die
}

pkg_postinst() {
	ewarn
	ewarn "This is testing dropbox ebuild. Designed to be GUI-less."
	ewarn "If anything goes wrong, let me know at ."
	ewarn
}
