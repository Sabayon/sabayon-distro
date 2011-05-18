# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/paraview/paraview-3.6.1.ebuild,v 1.7 2009/07/28 15:16:45 markusle Exp $

EAPI="2"

inherit distutils eutils flag-o-matic toolchain-funcs versionator python qt4-r2

MAIN_PV=$(get_major_version)
MAJOR_PV=$(get_version_component_range 1-2)

DESCRIPTION="ParaView is a powerful scientific data visualization application"
HOMEPAGE="http://www.paraview.org"
SRC_URI="mirror://gentoo/${P}.tar.gz
	mirror://gentoo/${P}-openfoam-gpl-r120.patch.bz2
	mirror://gentoo/${P}-openfoam-r120.patch.bz2"

LICENSE="paraview GPL-2"
KEYWORDS="~x86 ~amd64"
SLOT="0"
IUSE="mpi python hdf5 doc examples qt4 plugins boost"
RDEPEND="hdf5? ( sci-libs/hdf5 )
	mpi? ( || (
				sys-cluster/openmpi
				sys-cluster/mpich2[cxx] ) )
	python? ( >=dev-lang/python-2.0 )
	qt4? ( x11-libs/qt-gui:4
			x11-libs/qt-qt3support:4
			x11-libs/qt-assistant:4 )
	boost? ( >=dev-libs/boost-1.37 )
	dev-libs/libxml2
	media-libs/libpng
	media-libs/jpeg
	media-libs/tiff
	virtual/ffmpeg
	dev-libs/expat
	sys-libs/zlib
	media-libs/freetype
	>=app-admin/eselect-opengl-1.0.6-r1
	virtual/opengl
	sci-libs/netcdf
	x11-libs/libXmu"

# NOTE: vtk and paraview currently don't get along well
# (#279264, #212947) hence we need to block it
DEPEND="${RDEPEND}
		!!sci-libs/vtk
		doc? ( app-doc/doxygen )
		>=dev-util/cmake-2.6.4"

PVLIBDIR="$(get_libdir)/${PN}-${MAJOR_PV}"
BUILDDIR="${WORKDIR}/build"
S="${WORKDIR}"/ParaView${MAIN_PV}

src_prepare() {
	mkdir "${BUILDDIR}" || die "Failed to generate build directory"
	epatch "${FILESDIR}"/${P}-qt.patch
	epatch "${FILESDIR}"/${P}-pointsprite-disable.patch
	epatch "${FILESDIR}"/${P}-assistant.patch
	epatch "${DISTDIR}"/${P}-openfoam-r120.patch.bz2
	epatch "${DISTDIR}"/${P}-openfoam-gpl-r120.patch.bz2
	epatch "${FILESDIR}"/${P}-no-doc-finder.patch

	epatch "${FILESDIR}"/${P}-zlib-include.patch	

	if use hdf5 && has_version '>=sci-libs/hdf5-1.8.0'; then
		epatch "${FILESDIR}"/${P}-hdf-1.8.3.patch
	fi

	# fix GL issues
	sed -e "s:DEPTH_STENCIL_EXT:DEPTH_COMPONENT24:" \
		-i VTK/Rendering/vtkOpenGLRenderWindow.cxx \
		|| die "Failed to fix GL issues."

	# fix plugin install directory
	sed -e "s:\${PV_INSTALL_BIN_DIR}/plugins:/usr/${PVLIBDIR}/plugins:" \
		-i CMake/ParaViewPlugins.cmake \
		|| die "Failed to fix plugin install directories"
}

src_compile() {
	cd "${BUILDDIR}"
	local CMAKE_VARIABLES=""
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPV_INSTALL_LIB_DIR:PATH=${PVLIBDIR}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_SKIP_RPATH:BOOL=YES"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_RPATH:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_INSTALL_PREFIX:PATH=/usr"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_SHARED_LIBS:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_SYSTEM_FREETYPE:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_SYSTEM_JPEG:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_SYSTEM_PNG:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_SYSTEM_TIFF:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_SYSTEM_ZLIB:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_SYSTEM_EXPAT:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DEXPAT_INCLUDE_DIR:PATH=/usr/include"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DEXPAT_LIBRARY=/usr/$(get_libdir)/libexpat.so"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DOPENGL_gl_LIBRARY=/usr/$(get_libdir)/libGL.so"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DOPENGL_glu_LIBRARY=/usr/$(get_libdir)/libGLU.so"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_GLEXT_FILE=/usr/include/GL/glext.h"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_GLXEXT_FILE=/usr/include/GL/glxext.h"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_COLOR_MAKEFILE:BOOL=TRUE"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_SYSTEM_LIBXML2:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_StreamingParaView:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_OFFSCREEN=TRUE"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_USE_PTHREADS:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_TESTING:BOOL=OFF"

	# FIXME: compiling against ffmpeg is currently broken
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_FFMPEG_ENCODER:BOOL=OFF"

	if use boost; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_BOOST:BOOL=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_USE_BOOST:BOOL=OFF"
	fi

	if use hdf5; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_USE_SYSTEM_HDF5:BOOL=ON"

		# we also need to append -DH5Tget_array_dims_vers=1 to our CFLAGS
		# to make sure we can compile against >=hdf5-1.8.3
		append-flags -DH5_USE_16_API
	fi

	if use mpi; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_USE_MPI:BOOL=ON"
	fi

	if use python; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_ENABLE_PYTHON:BOOL=ON"
	fi

	use doc && CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_DOCUMENTATION:BOOL=ON"

	if use examples; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_EXAMPLES:BOOL=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_EXAMPLES:BOOL=OFF"
	fi

	local plugin_toggle="OFF"
	if use plugins; then
		plugin_toggle="ON"
	fi
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_OverView:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ARRAY:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ClientGraphViewFrame:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_CosmoFilters:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_Infovis:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_Moments,:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_PointSprite:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_Prism:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_SLACTools:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_Streaming:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_netCDFReaders:BOOL=${plugin_toggle}"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_pvblot:BOOL=${plugin_toggle}"

	# these plugins currently don't configure so turn them off for now
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_VisItReaderPlugin:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_TableToSparseArrayPanel:BOOL=OFF"

	# these plugins currently don't compile so turn them off for now
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ClientGraphView:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_SplitTableFieldPanel:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_SQLDatabaseGraphSourcePanel:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_SQLDatabaseTableSourcePanel:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_TableToGraphPanel:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ThresholdTablePanel:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_StatisticsToolbar:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ClientGeoView2D:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ClientGeoView:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ClientTableView:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ClientHierarchyView:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_ClientRecordView:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_CommonToolbar:BOOL=OFF"
	CMAKE_VARIABLES="${CMAKE_VARIABLES}	-DPARAVIEW_BUILD_PLUGIN_ClientTreeView:BOOL=no"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_PLUGIN_GraphLayoutFilterPanel:BOOL=OFF"

	if use qt4; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_QT_GUI:BOOL=ON"
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DVTK_INSTALL_QT_DIR=/${PVLIBDIR}/plugins/designer"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DPARAVIEW_BUILD_QT_GUI:BOOL=OFF"
	fi

	cmake ${CMAKE_VARIABLES} "${S}" \
		|| die "cmake configuration failed"

	emake || die "emake failed"

}

src_install() {
	cd "${BUILDDIR}"
	make DESTDIR="${D}" install || die "make install failed"

	# rename the assistant wrapper
	if use qt4; then
		mv "${D}"/usr/bin/assistant "${D}"/usr/bin/paraview-assistant \
			|| die "Failed to rename assistant wrapper"
		chmod 0755 "${D}"/usr/${PVLIBDIR}/assistant-real \
			|| die "Failed to change permissions on assistant wrapper"
	fi

	# set up the environment
	echo "LDPATH=/usr/${PVLIBDIR}" >> "${T}"/40${PN}
	doenvd "${T}"/40${PN}

	# move and remove some of the files that should not be 
	# in /usr/bin
	dohtml "${D}/usr/bin/about.html" && rm -f "${D}/usr/bin/about.html" \
		|| die "Failed to move about.html into doc dir"

	# this binary does not work and probably should not be installed
	rm -f "${D}/usr/bin/vtkSMExtractDocumentation" \
		|| die "Failed to remove vtkSMExtractDocumentation"
}

pkg_postinst() {
	# with Qt4.5 there seem to be issues reading data files
	# under certain locales. Setting LC_ALL=C should fix these.
	echo
	elog "If you experience data corruption during parsing of"
	elog "data files with paraview please try setting your"
	elog "locale to LC_ALL=C."
}
