# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit enlightenment

DESCRIPTION="hardware-accelerated retained canvas API"
HOMEPAGE="http://trac.enlightenment.org/e/wiki/Evas"

KEYWORDS="~amd64 ~x86"
IUSE="altivec bidi +cache directfb +eet fbcon +fontconfig gles gif +jpeg mmx opengl +png sdl sse svg static-libs +threads tiff X xcb xpm"

RDEPEND="
	>=dev-libs/eina-9999
	>=media-libs/freetype-2.3.9
	fontconfig? ( media-libs/fontconfig )
	gles? ( media-libs/mesa[gallium,gles] )
	gif? ( media-libs/giflib )
	jpeg? ( media-libs/jpeg )
	png? ( media-libs/libpng )
	bidi? ( >=dev-libs/fribidi-0.19.1 )
	directfb? ( >=dev-libs/DirectFB-0.9.16 )
	sdl? ( media-libs/libsdl )
	tiff? ( media-libs/tiff )
	xpm? ( x11-libs/libXpm )
	X? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXrender
		opengl? ( virtual/opengl )
	)
	!X? (
		xcb? (
			x11-libs/xcb-util
		) )
	eet? ( >=dev-libs/eet-9999 )
	svg? (
		>=gnome-base/librsvg-2.14.0
		x11-libs/cairo
		x11-libs/libsvg-cairo
	)"
DEPEND="${RDEPEND}"

src_configure() {
	if use X ; then
		if use xcb ; then
			ewarn "You have enabled both 'X' and 'xcb', so we will use"
			ewarn "X as it's considered the most stable for evas"
		fi
		MY_ECONF+="
			--disable-software-xcb
			--disable-xrender-xcb
			$(use_enable opengl gl-x11 static)
		"
	elif use xcb ; then
		use opengl && ewarn "opengl support is not implemented with xcb"
		MY_ECONF+="
			--disable-gl-x11
			--enable-software-xcb=static
			--enable-xrender-xcb=static
		"
	else
		MY_ECONF+="
			--disable-gl-x11
			--disable-software-xcb
			--disable-xrender-xcb
		"
	fi

	if use opengl ; then
		MY_ECONF+=" $(use_enable cache metric-cache)"
	else
		MY_ECONF+=" $(use_enable cache word-cache)"
	fi

	MY_ECONF="
		$(use_enable altivec cpu-altivec)
		$(use_enable bidi fribidi)
		$(use_enable directfb)
		$(use_enable doc)
		$(use_enable fbcon fb)
		$(use_enable fontconfig)
		$(use_enable gles gl-flavor-gles)
		$(use_enable gles gles-variety-sgx)
		$(use_enable gif image-loader-gif)
		$(use_enable jpeg image-loader-jpeg)
		$(use_enable eet font-loader-eet)
		$(use_enable eet image-loader-eet)
		$(use_enable mmx cpu-mmx)
		$(use_enable png image-loader-png)
		$(use_enable sdl software-sdl)
		$(use_enable sse cpu-sse)
		$(use_enable svg image-loader-svg static)
		$(use_enable tiff image-loader-tiff static)
		$(use_enable threads pthreads)
		$(use_enable threads async-events)
		$(use_enable threads async-preload)
		$(use_enable threads async-render)
		$(use_enable X software-xlib static)
		$(use_enable X xrender-x11 static)
		$(use_enable X software-16-x11 static)
		$(use_enable xpm image-loader-xpm static)
		--enable-evas-magic-debug \
		--enable-static-software-generic \
		--enable-buffer \
		--enable-cpu-c \
		--enable-scale-sample \
		--enable-scale-smooth \
		--enable-convert-8-rgb-332 \
		--enable-convert-8-rgb-666 \
		--enable-convert-8-rgb-232 \
		--enable-convert-8-rgb-222 \
		--enable-convert-8-rgb-221 \
		--enable-convert-8-rgb-121 \
		--enable-convert-8-rgb-111 \
		--enable-convert-16-rgb-565 \
		--enable-convert-16-rgb-555 \
		--enable-convert-16-rgb-444 \
		--enable-convert-16-rgb-rot-0 \
		--enable-convert-16-rgb-rot-270 \
		--enable-convert-16-rgb-rot-90 \
		--enable-convert-24-rgb-888 \
		--enable-convert-24-bgr-888 \
		--enable-convert-32-rgb-8888 \
		--enable-convert-32-rgbx-8888 \
		--enable-convert-32-bgr-8888 \
		--enable-convert-32-bgrx-8888 \
		--enable-convert-32-rgb-rot-0 \
		--enable-convert-32-rgb-rot-270 \
		--enable-convert-32-rgb-rot-90 \
		--disable-image-loader-edb"

	enlightenment_src_configure
}
