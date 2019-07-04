# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Simple passphrase entry dialogs which utilize the Assuan protocol (meta package)"
HOMEPAGE="https://gnupg.org/aegypten2/index.html"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
<<<<<<<
KEYWORDS="~arm ~amd64 ~x86"
# some use flags are fake, used to mimic portage ebuild USE flags
=======
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
>>>>>>>
IUSE="caps emacs gnome-keyring fltk gtk ncurses qt5 static"

<<<<<<<
=======
DEPEND="
	app-eselect/eselect-pinentry
	>=dev-libs/libassuan-2.1
	>=dev-libs/libgcrypt-1.6.3
>>>>>>>
RDEPEND="
	~app-crypt/pinentry-base-${PV}
	caps? ( ~app-crypt/pinentry-base-${PV}[caps] )
	gnome-keyring? ( ~app-crypt/pinentry-gnome-${PV} )
	gtk? ( ~app-crypt/pinentry-gtk2-${PV} )
	qt5? ( ~app-crypt/pinentry-qt5-${PV} )
<<<<<<<
	static? ( ~app-crypt/pinentry-base-${PV}[static] )"
DEPEND=""
=======
	)
	static? ( >=sys-libs/ncurses-5.7-r5:0=[static-libs,-gpm] )
"
RDEPEND="${DEPEND}
	gnome-keyring? ( app-crypt/gcr )
"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"
>>>>>>>

REQUIRED_USE="
	gtk? ( !static )
	qt5? ( !static )
"
<<<<<<<
=======
	export QTLIB="$(qt5_get_libdir)"

	econf \
		$(use_enable emacs pinentry-emacs) \
		$(use_enable fltk pinentry-fltk) \
		$(use_enable gnome-keyring libsecret) \
		$(use_enable gnome-keyring pinentry-gnome3) \
		$(use_enable gtk pinentry-gtk2) \
		$(use_enable ncurses fallback-curses) \
		$(use_enable ncurses pinentry-curses) \
		$(use_enable qt5 pinentry-qt) \
		$(use_with caps libcap) \
		--enable-pinentry-tty \
		FLTK_CONFIG="${EROOT}/usr/bin/fltk-config" \
		MOC="$(qt5_get_bindir)"/moc \
		GPG_ERROR_CONFIG="${EROOT}/usr/bin/${CHOST}-gpg-error-config" \
		LIBASSUAN_CONFIG="${EROOT}/usr/bin/libassuan-config" \
		$("${S}/configure" --help | grep -- '--without-.*-prefix' | sed -e 's/^ *\([^ ]*\) .*/\1/g')
}

src_install() {
	default
	rm -f "${ED}"/usr/bin/pinentry

	use qt5 && dosym pinentry-qt /usr/bin/pinentry-qt4
}
>>>>>>>
