# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit enlightenment

DESCRIPTION="Enlightenment's data types library (List, hash, etc) in C"

LICENSE="LGPL-2.1"

KEYWORDS="~amd64 ~x86"
IUSE="altivec debug default-mempool mempool-buddy +mempool-chained
	mempool-ememoa-fixed mempool-ememoa-unknown
	mempool-fixed-bitmap +mempool-pass-through
	mmx sse sse2 static-libs test +threads"

RDEPEND="
	mempool-ememoa-fixed? ( sys-libs/ememoa )
	mempool-ememoa-unknown? ( sys-libs/ememoa )
	debug? ( dev-util/valgrind )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	test? (
		dev-libs/check
		dev-libs/glib
		dev-util/lcov
	)"

src_configure() {
	local EMEMOA_FLAGS=""

	local MODULE_ARGUMENT="static"
	if use debug ; then
		MODULE_ARGUMENT="yes"
	fi

	if use mempool-ememoa-fixed || use mempool-ememoa-unknown; then
		EMEMOA_FLAGS="--enable-ememoa"
	else
		EMEMOA_FLAGS="--disable-ememoa"
	fi

	# Evas benchmark is broken!
	MY_ECONF="
	$(use_enable altivec cpu-altivec)
	$(use_enable !debug amalgamation)
	$(use_enable debug stringshare-usage)
	$(use_enable debug assert)
	$(use_enable debug valgrind)
	$(use debug || echo " --with-internal-maximum-log-level=2")
	$(use_enable default-mempool)
	$(use_enable doc)
	$(use_enable mempool-buddy mempool-buddy $MODULE_ARGUMENT)
	$(use_enable mempool-chained mempool-chained-pool $MODULE_ARGUMENT)
	$(use_enable mempool-ememoa-fixed mempool-ememoa-fixed $MODULE_ARGUMENT)
	$(use_enable mempool-ememoa-unknown mempool-ememoa-unknown $MODULE_ARGUMENT)
	$(use_enable mempool-fixed-bitmap mempool-fixed-bitmap $MODULE_ARGUMENT)
	$(use_enable mempool-pass-through mempool-pass-through $MODULE_ARGUMENT)
	$(use_enable mmx cpu-mmx)
	$(use_enable sse cpu-sse)
	$(use_enable sse2 cpu-sse2)
	$(use_enable threads posix-threads)
	$(use test && echo " --disable-amalgamation")
	$(use_enable test e17)
	$(use_enable test tests)
	$(use_enable test coverage)
	$(use_enable test benchmark)
	${EMEMOA_FLAGS}
	--enable-magic-debug
	--enable-safety-checks
	"

	enlightenment_src_configure
}
