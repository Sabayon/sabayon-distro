# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/kde-meta.eclass,v 1.85 2008/02/21 10:33:11 zlin Exp $

# @ECLASS: kde-meta.eclass
# @MAINTAINER:
# kde@gentoo.org
#
# Original authors:
# Dan Armak <danarmak@gentoo.org>
# Simone Gotti <motaboy@gentoo.org>
# @BLURB: This is the kde-meta eclass which supports broken-up kde-base packages.
# @DESCRIPTION:
# This is the kde-meta eclass which supports broken-up kde-base packages.


inherit kde-suse multilib

# only broken-up ebuilds can use this eclass
if [[ -z "$KMNAME" ]]; then
	die "kde-meta.eclass inherited but KMNAME not defined - broken ebuild"
fi

# Replace the $myPx mess - it was ugly as well as not general enough for 3.4.0-rc1
# The following code should set TARBALLVER (the version in the tarball's name)
# and TARBALLDIRVER (the version of the toplevel directory inside the tarball).
case "$PV" in
	3.5.0_beta2)		TARBALLDIRVER="3.4.92"; TARBALLVER="3.4.92" ;;
	3.5.0_rc1)		TARBALLDIRVER="3.5.0"; TARBALLVER="3.5.0_rc1" ;;
	*)				TARBALLDIRVER="$PV"; TARBALLVER="$PV" ;;
esac
if [[ "${KMNAME}" = "koffice" ]]; then
	case "$PV" in
		1.6_beta1)	TARBALLDIRVER="1.5.91"; TARBALLVER="1.5.91" ;;
		1.6_rc1)	TARBALLDIRVER="1.5.92"; TARBALLVER="1.5.92" ;;
	esac
fi

TARBALL="$KMNAME-$TARBALLVER.tar.bz2"

# BEGIN adapted from kde-dist.eclass, code for older versions removed for cleanness
if [[ "$KDEBASE" = "true" ]]; then
	unset SRC_URI

	need-kde $PV

	DESCRIPTION="KDE ${PV} - "
	HOMEPAGE="http://www.kde.org/"
	LICENSE="GPL-2"
	SLOT="$KDEMAJORVER.$KDEMINORVER"

	# Main tarball for normal downloading style
	# Note that we set SRC_PATH, and add it to SRC_URI later on
	case "$PV" in
		3.5.0_*)	SRC_PATH="mirror://kde/unstable/${PV/.0_/-}/src/$TARBALL" ;;
		3.5_*)		SRC_PATH="mirror://kde/unstable/${PV/_/-}/src/$TARBALL" ;;
		3.5.0)		SRC_PATH="mirror://kde/stable/3.5/src/$TARBALL" ;;
		3*)		SRC_PATH="mirror://kde/stable/$TARBALLVER/src/$TARBALL" ;;
		*)		die "$ECLASS: Error: unrecognized version $PV, could not set SRC_URI" ;;
	esac

elif [[ "$KMNAME" == "koffice" ]]; then
	SRC_PATH="mirror://kde/stable/koffice-$PV/src/koffice-$PV.tar.bz2"
	case $PV in
		1.3.5)
			SRC_PATH="mirror://kde/stable/koffice-$PV/src/koffice-$PV.tar.bz2"
			;;
		1.6_beta1)
			SRC_PATH="mirror://kde/unstable/koffice-${PV/_/-}/koffice-${TARBALLVER}.tar.bz2"
			;;
		*)
			# Identify beta and rc versions by underscore
			if [[ ${PV/_/} != ${PV} ]]; then
				SRC_PATH="mirror://kde/unstable/koffice-${PV/_/-}/src/koffice-${TARBALLVER}.tar.bz2"
			fi
			;;
	esac
fi

SRC_URI="$SRC_URI $SRC_PATH"

debug-print "$ECLASS: finished, SRC_URI=$SRC_URI"

# Add a blocking dep on the package we're derived from
if [[ "${KMNAME}" != "koffice" ]]; then
	DEPEND="${DEPEND} !=$(get-parent-package ${CATEGORY}/${PN})-${SLOT}*"
	RDEPEND="${RDEPEND} !=$(get-parent-package ${CATEGORY}/${PN})-${SLOT}*"
else
	case ${EAPI:-0} in
		0)  
		# EAPIs without SLOT dependencies.
		IFSBACKUP="$IFS"
		IFS=".-_"
		for x in ${PV}; do
			if [[ -z "$KOFFICEMAJORVER" ]]; then KOFFICEMAJORVER=$x
			else if [[ -z "$KOFFICEMINORVER" ]]; then KOFFICEMINORVER=$x
			else if [[ -z "$KOFFICEREVISION" ]]; then KOFFICEREVISION=$x
			fi; fi; fi
		done
		[[ -z "$KOFFICEMINORVER" ]] && KOFFICEMINORVER="0"
		[[ -z "$KOFFICEREVISION" ]] && KOFFICEREVISION="0"
		IFS="$IFSBACKUP"
		DEPEND="${DEPEND} !=$(get-parent-package ${CATEGORY}/${PN})-${KOFFICEMAJORVER}.${KOFFICEMINORVER}*"
		RDEPEND="${RDEPEND} !=$(get-parent-package ${CATEGORY}/${PN})-${KOFFICEMAJORVER}.${KOFFICEMINORVER}*"
		;;
		# EAPIs with SLOT dependencies.
		*)
		[[ -z ${SLOT} ]] && SLOT="0"
		DEPEND="${DEPEND} !$(get-parent-package ${CATEGORY}/${PN}):${SLOT}"
		RDEPEND="${RDEPEND} !$(get-parent-package ${CATEGORY}/${PN}):${SLOT}"
		;;
	esac
fi

# @ECLASS-VARIABLE: KMNAME
# @DESCRIPTION:
# Name of the metapackage (eg kdebase, kdepim). Must be set before inheriting
# this eclass, since it affects $SRC_URI. This variable MUST be set.

# @ECLASS-VARIABLE: KMNOMODULE
# @DESCRIPTION:
# Unless set to "true", then KMMODULE will be not defined and so also the docs.
# Useful when we want to installs subdirs of a subproject, like plugins, and we
# have to mark the topsubdir ad KMEXTRACTONLY.

# @ECLASS-VARIABLE: KMMODULE
# @DESCRIPTION:
# Defaults to $PN. Specify one subdirectory of KMNAME. Is treated exactly like items in KMEXTRA.
# Fex., the ebuild name of kdebase/l10n is kdebase-l10n, because just 'l10n' would be too confusing.
# Do not include the same item in more than one of KMMODULE, KMMEXTRA, KMCOMPILEONLY, KMEXTRACTONLY, KMCOPYLIB.

# @ECLASS-VARIABLE: KMNODOCS
# @DESCRIPTION:
# Unless set to "true", 'doc/$KMMODULE' is added to KMEXTRA. Set for packages that don't have docs.

# @ECLASS-VARIABLE: KMEXTRA
# @DESCRIPTION:
# Specify files/dirs to extract, compile and install. $KMMODULE is added to
# KMEXTRA automatically. So is doc/$KMMODULE (unless $KMNODOCS==true). Makefiles
# are created automagically to compile/install the correct files. Observe these
# rules:
#
# - Don't specify the same file in more than one of three variables (KMEXTRA,
# KMCOMPILEONLY, and KMEXTRACTONLY)
# - When using KMEXTRA, remember to add the doc/foo dir for the extra dirs if one exists.
# - KMEXTRACTONLY take effect over an entire directory tree, you can override it defining
#
# KMEXTRA, KMCOMPILEONLY for every subdir that must have a different behavior.
# eg. you have this tree:
# foo/bar
# foo/bar/baz1
# foo/bar/baz1/taz
# foo/bar/baz2
# If you define:
# KMEXTRACTONLY=foo/bar and KMEXTRA=foo/bar/baz1
# then the only directory compiled will be foo/bar/baz1 and not foo/bar/baz1/taz (also if it's a subdir of a KMEXTRA) or foo/bar/baz2
#
# IMPORTANT!!! you can't define a KMCOMPILEONLY SUBDIR if its parents are defined as KMEXTRA or KMMODULE. or it will be installed anywhere. To avoid this probably are needed some chenges to the generated Makefile.in.
# Do not include the same item in more than one of KMMODULE, KMMEXTRA, KMCOMPILEONLY, KMEXTRACTONLY, KMCOPYLIB.

# @ECLASS-VARIABLE: KMCOMPILEONLY
# @DESCRIPTION:
# Please see KMEXTRA

# @ECLASS-VARIABLE: KMEXTRACTONLY
# @DESCRIPTION:
# Please see KMEXTRA

# @ECLASS-VARIABLE: KMCOPYLIB
# @DESCRIPTION:
# Contains an even number of $IFS (i.e. whitespace) -separated words.
# Each two consecutive words, libname and dirname, are considered. symlinks are created under $S/$dirname
# pointing to $PREFIX/lib/libname*.
# Do not include the same item in more than one of KMMODULE, KMMEXTRA, KMCOMPILEONLY, KMEXTRACTONLY, KMCOPYLIB.


# ====================================================

# @FUNCTION: create_fullpaths
# @DESCRIPTION:
# create a full path vars, and remove ALL the endings "/"
create_fullpaths() {
	for item in $KMMODULE; do
		KMMODULEFULLPATH="$KMMODULEFULLPATH ${S}/${item%/}"
	done
	for item in $KMEXTRA; do
		KMEXTRAFULLPATH="$KMEXTRAFULLPATH ${S}/${item%/}"
	done
	for item in $KMCOMPILEONLY; do
		KMCOMPILEONLYFULLPATH="$KMCOMPILEONLYFULLPATH ${S}/${item%/}"
	done
	for item in $KMEXTRACTONLY; do
		KMEXTRACTONLYFULLPATH="$KMEXTRACTONLYFULLPATH ${S}/${item%/}"
	done
}

# @FUNCTION: change_makefiles
# @USAGE: < dir > < isextractonly >
# @DESCRIPTION:
# Creates Makefile.am files in directories where we didn't extract the originals.
# $isextractonly: true if the parent dir was defined as KMEXTRACTONLY
# Recurses through $S and all subdirs. Creates Makefile.am with SUBDIRS=<list of existing subdirs>
# or just empty all:, install: targets if no subdirs exist.
change_makefiles() {
	debug-print-function $FUNCNAME "$@"
	local dirlistfullpath dirlist directory isextractonly

	cd "${1}"
	debug-print "We are in ${PWD}"

	# check if the dir is defined as KMEXTRACTONLY or if it was defined is KMEXTRACTONLY in the parent dir, this is valid only if it's not also defined as KMMODULE, KMEXTRA or KMCOMPILEONLY. They will ovverride KMEXTRACTONLY, but only in the current dir.
	isextractonly="false"
	if ( ( hasq "$1" $KMEXTRACTONLYFULLPATH || [[ $2 = "true" ]] ) && \
		 ( ! hasq "$1" $KMMODULEFULLPATH $KMEXTRAFULLPATH $KMCOMPILEONLYFULLPATH ) ); then
		isextractonly="true"
	fi
	debug-print "isextractonly = $isextractonly"

	dirlistfullpath=
	for item in *; do
		if [[ -d "${item}" && "${item}" != "CVS" && "${S}/${item}" != "${S}/admin" ]]; then
			# add it to the dirlist, with the FULL path and an ending "/"
			dirlistfullpath="$dirlistfullpath ${1}/${item}"
		fi
	done
	debug-print "dirlist = $dirlistfullpath"

	for directory in $dirlistfullpath; do

		if ( hasq "$1" $KMEXTRACTONLYFULLPATH || [[ $2 = "true" ]] ); then
			change_makefiles $directory 'true'
		else
			change_makefiles $directory 'false'
		fi
		# come back to our dir
		cd $1
	done

	cd $1
	debug-print "Come back to ${PWD}"
	debug-print "dirlist = $dirlistfullpath"
	if [[ $isextractonly = "true" ]] || [[ ! -f Makefile.am ]] ; then
		# if this is a latest subdir
		if [[ -z "$dirlistfullpath" ]]; then
			debug-print "dirlist is empty => we are in the latest subdir"
			echo 'all:' > Makefile.am
			echo 'install:' >> Makefile.am
			echo '.PHONY: all' >> Makefile.am
		else # it's not a latest subdir
			debug-print "We aren't in the latest subdir"
			# remove the ending "/" and the full path"
			for directory in $dirlistfullpath; do
				directory=${directory%/}
				directory=${directory##*/}
				dirlist="$dirlist $directory"
			done
			echo "SUBDIRS=$dirlist" > Makefile.am
		fi
	fi
}

set_common_variables() {
	# Overridable module (subdirectory) name, with default value
	if [[ "$KMNOMODULE" != "true" ]] && [[ -z "$KMMODULE" ]]; then
		KMMODULE=$PN
	fi

	# Unless disabled, docs are also extracted, compiled and installed
	DOCS=""
	if [[ "$KMNOMODULE" != "true" ]] && [[ "$KMNODOCS" != "true" ]]; then
		DOCS="doc/$KMMODULE"
	fi
}

# @FUNCTION: kde-meta_src_unpack
# @USAGE: [ unpack ] [ makefiles ]
# @DESCRIPTION:
# This has function sections now. Call unpack, apply any patches not in $PATCHES,
# then call makefiles.
kde-meta-suse_src_unpack() {
	debug-print-function $FUNCNAME "$@"

	set_common_variables

	sections="$@"
	[[ -z "$sections" ]] && sections="unpack makefiles"
	for section in $sections; do
	case $section in
	unpack)

		# kdepim packages all seem to rely on libkdepim/kdepimmacros.h
		# also, all kdepim Makefile.am's reference doc/api/Doxyfile.am
		if [[ "$KMNAME" == "kdepim" ]]; then
			KMEXTRACTONLY="$KMEXTRACTONLY libkdepim/kdepimmacros.h doc/api"
		fi

		# Create final list of stuff to extract
		extractlist=""
		for item in admin Makefile.am Makefile.am.in configure.in.in configure.in.mid configure.in.bot \
					acinclude.m4 aclocal.m4 AUTHORS COPYING INSTALL README NEWS ChangeLog \
					$KMMODULE $KMEXTRA $KMCOMPILEONLY $KMEXTRACTONLY $DOCS
		do
			extractlist="$extractlist $KMNAME-$TARBALLDIRVER/${item%/}"
		done

		# $KMTARPARAMS is also available for an ebuild to use; currently used by kturtle
		TARFILE=$DISTDIR/$TARBALL
		KMTARPARAMS="$KMTARPARAMS -j"
		cd "${WORKDIR}"

		echo ">>> Unpacking parts of ${TARBALL} to ${WORKDIR}"
		# Note that KMTARPARAMS is also used by an ebuild
		tar -xpf $TARFILE $KMTARPARAMS $extractlist	2> /dev/null

		[[ -n ${A/${TARBALL}/} ]] && unpack ${A/${TARBALL}/}

		# Avoid syncing if possible
		# No idea what the above comment means...
		if [[ -n "$RAWTARBALL" ]]; then
			rm -f $T/$RAWTARBALL
		fi

		# Default $S is based on $P not $myP; rename the extracted dir to fit $S
		mv $KMNAME-$TARBALLDIRVER $P || die "mv $KMNAME-$TARBallDIRVER failed."
		S="${WORKDIR}"/${P}

		# Copy over KMCOPYLIB items
		libname=""
		for x in $KMCOPYLIB; do
			if [[ "$libname" == "" ]]; then
				libname=$x
			else
				dirname=$x
				cd "${S}"
				mkdir -p ${dirname}
				cd ${dirname}
				search_path=$(echo "${PREFIX}"/$(get_libdir)/{,kde3/{,plugins/{designer,styles}}})
				if [[ ! "$(find ${search_path} -maxdepth 1 -name "${libname}*" 2>/dev/null)" == "" ]]; then
					echo "Symlinking library ${libname} under ${PREFIX}/$(get_libdir)/ in source dir"
					ln -s "${PREFIX}"/$(get_libdir)/${libname}* .
				else
					die "Can't find library ${libname} under ${PREFIX}/$(get_libdir)/"
				fi
				libname=""
			fi
		done

		# Don't add a param here without looking at its implementation.
		kde-suse_src_unpack

		# kdebase: Remove the installation of the "startkde" script.
		if [[ "$KMNAME" == "kdebase" ]]; then
			sed -i -e s:"bin_SCRIPTS = startkde"::g "${S}"/Makefile.am.in
		fi

		# for ebuilds with extended src_unpack
		cd "${S}"

	;;
	makefiles)

		# Create Makefile.am files
		create_fullpaths
		change_makefiles "${S}" "false"

		# for ebuilds with extended src_unpack
		cd "${S}"

	;;
	esac
	done
}

# @FUNCTION: kde-meta_src_compile
# @DESCRIPTION:
# Does some checks before it invokes kde_src_compile
kde-meta-suse_src_compile() {
	debug-print-function $FUNCNAME "$@"

	set_common_variables

	if [[ "$KMNAME" == "kdebase" ]]; then
		# bug 82032: the configure check for java is unnecessary as well as broken
		myconf="$myconf --without-java"
	fi

	if [[ "$KMNAME" == "kdegames" ]]; then
		# make sure games are not installed with setgid bit, as it is a security risk.
		myconf="$myconf --disable-setgid"
	fi

	kde-suse_src_compile "$@"
}

# @FUNCTION: kde-meta_src_install
# @USAGE: [ make ] [ dodoc ] [ all ]
# @DESCRIPTION:
# The kde-meta src_install function
kde-meta-suse_src_install() {
	debug-print-function $FUNCNAME "$@"

	set_common_variables

	if [[ "$1" == "" ]]; then
		kde-meta-suse_src_install make dodoc
	fi
	while [[ -n "$1" ]]; do
		case $1 in
			make)
				for dir in $KMMODULE $KMEXTRA $DOCS; do
					if [[ -d "${S}"/$dir ]]; then
						cd "${S}"/$dir
						emake DESTDIR="${D}" destdir="${D}" install || die "emake install failed."
					fi
				done
				;;
			dodoc)
				kde-suse_src_install dodoc
				;;
			all)
				kde-meta-meta_src_install make dodoc
				;;
		esac
		shift
	done
}

EXPORT_FUNCTIONS src_unpack src_compile src_install

