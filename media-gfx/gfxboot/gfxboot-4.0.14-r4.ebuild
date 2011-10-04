# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI='1'
inherit rpm toolchain-funcs

DESCRIPTION="gfxboot allows you to create gfx menus for bootmanagers."
HOMEPAGE="http://suse.com"
# We need find better place for src and repack it, but now...
SRC_URI="http://download.opensuse.org/distribution/11.0/repo/src-oss/suse/src/gfxboot-${PV}-${PR/r/}.1.src.rpm"

LICENSE="GPL-2"
SLOT="4"
KEYWORDS="x86 amd64"

LANGS="af ar bg ca cs da de el en es et fi fr gu hi hr hu id it ja lt mr nb nl pa pl pt_BR pt ro ru sk sl sr sv ta tr uk wa xh zh_CN zh_TW zu"
IUSE="themes doc animate speech beep"
for i in ${LANGS}; do
	IUSE="${IUSE} linguas_${i}"
done

DEPEND="app-arch/cpio
	dev-lang/nasm
	>=media-libs/freetype-2
	themes? ( dev-libs/fribidi )
	doc? (	app-text/xmlto
		dev-libs/libxslt
		app-text/docbook-xml-dtd:4.1.2
		dev-perl/HTML-Parser )"
RDEPEND="${DEPEND}"
RESTRICT="mirror"

pkg_setup() {
	if ! use themes; then
		if use animate || use beep || use speech; then
			ewarn "There is no use for 'animate', 'beep' or 'speech' flags"
			ewarn "if themes are disabled."
		fi
	fi
}

src_unpack () {
	rpm_src_unpack ${A}
	mv "${WORKDIR}/themes" "${S}/"
	cd "${S}"

	# going Gentoo-way
	sed -i	-e 's:^CFLAGS:#:' \
		-e 's:$(CFLAGS): -Wno-pointer-sign :' \
		-e 's:bootsplash/$$i:bootsplash/`basename $$i`:g' \
		-e 's:sbin:bin:g' Makefile

	if use themes; then
		[[ -n $LINGUAS ]] && LINGUAS="${LINGUAS/da/dk}" || LINGUAS=en
		# We want to see penguins, many penguins... all the time
		use animate && sed -i "/penguin=/s:0:100:" `find . -type f -name gfxboot.cfg`
		# some signal on start
		use beep || sed -i "/beep=/s:1:0:" `find . -type f -name gfxboot.cfg`
		# experimental talking
		use speech && sed -i "/talk=/s:0:1:" `find . -type f -name gfxboot.cfg`

		# We want our native language by default
		sed -i "/DEFAULT_LANG =/s:$: `echo $LINGUAS|cut -f1 -d\ `:" \
			`find . -type f -name Makefile`

		# We want _only_ our favorite languages...
		for i in `find themes/* -type f -name languages`; do
			cp $i $i-
			locale -a >> $i-
			sort $i-|uniq -d > $i
			rm $i-
		done
		# ...and nothing else
		for i in `find . -path "./themes/*/help-*" -type f -name "*.html"; \
			find . -path "./themes/*" -type f -name "*.po"`;do
			if has `basename "$i" .po` "$LINGUAS" || has `basename "$i" .html` "$LINGUAS"; then
				einfo "keeping $i"
				else	rm "$i"
			fi
		done
	fi
}

src_compile() {
	emake -j1 || die "Make failed!"

	if use themes; then
		emake -j1 themes || die "Make themes failed!"
	fi

	if use doc; then
		emake -j1 doc || die "Make doc failed!"
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "Install failed"
	if use doc; then
		dodoc Changelog gfxboot
		dohtml doc/gfxboot.html
	fi
}

pkg_postinst() {
	if use themes; then
		elog "To use gfxboot themes on your machine do following:"
		echo
		elog "1) Pick up one of build-in themes in /etc/bootsplash"
		elog "   or one from kde-look.org or similar site"
		elog "2) Patch your grub_legacy to use gfxmenu or use grub2"
		elog "   or lilo"
		elog "3) copy 'message' to /boot/ [aka root of boot partition]"
		elog "4) Set up gfxmenu in bootloader, as example"
		elog "   'gfxmenu /message' line if your root=boot partition"
		elog "   in grub_legacy"
	fi
}
