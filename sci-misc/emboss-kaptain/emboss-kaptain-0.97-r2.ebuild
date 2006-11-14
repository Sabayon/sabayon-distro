# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/emboss-kaptain/emboss-kaptain-0.97-r2.ebuild,v 1.1 2006/09/12 04:27:53 ribosome Exp $

DESCRIPTION="Graphical interfaces for EMBOSS and EMBASSY programs"
HOMEPAGE="http://userpage.fu-berlin.de/~sgmd/"
SRC_URI="http://genetik.fu-berlin.de/sgmd/EMBOSS.kaptns_${PV}.tar.gz"
LICENSE="GPL-1"

SLOT="0"
KEYWORDS="~x86"
IUSE=""

S="${WORKDIR}/EMBOSS.kaptns_${PV}"

DEPEND="kde-misc/kaptain
	app-editors/nedit
	~sci-biology/emboss-4.0.0
	~sci-biology/embassy-phylipnew-3.6b
	~sci-biology/embassy-domainatrix-0.1.0"

src_compile() {
	einfo "Fixing nedit references:"
	for i in *.kaptn; do
		echo -e "\t${i}"
		sed -e 's/nc -noask/neditc -noask/' \
				-e 's/nc -svrname/neditc -svrname/' -i ${i} || \
				die "Failed setting correct nedit executable in ${i}."
	done

	einfo "Fixing PHYLIP references:"
	for i in clique consense contml contrast dnacomp dnadist dnainvar dnaml dnamlk \
			dnapars dnapenny dollop dolpenny factor fitch gendist kitsch mix \
			neighbor penny protdist protpars restml seqboot ; do
		echo -e "\t${i}"
		mv e${i}.kaptn f${i}.kaptn || \
				die "Failed to rename PHYLIP grammar rules for ${i}."
		sed -e "s/e${i}/f${i}/g" -e "s/E${i}/F${i}/g" -i f${i}.kaptn || \
				die "Failed to patch PHYLIP grammar rules for ${i}."
		mv EMBOSS/Phylip/e${i}.desktop EMBOSS/Phylip/f${i}.desktop || \
				die "Failed to rename PHYLIP desktop file for ${i}."
		sed -e "s/e${i}/f${i}/g" -e "s/E${i}/F${i}/g" -i EMBOSS/Phylip/f${i}.desktop \
				|| die "Failed to patch PHYLIP desktop file for ${i}."
	done

	einfo "Fixing drawtree references:"
	for i in clique consense contml dnacomp dnaml dnamlk dnapars dnapenny dollop \
			dolpenny fitch kitsch mix neighbor penny protpars restml; do
		echo -e "\t${i}"
		sed -e "s/drawtree/treeprint/g" -i f${i}.kaptn || \
				die "Failed to fix drawtree refenrece in ${i}."
	done

	einfo "Fixing desktop files:"
	cd EMBOSS
	for i in *; do
		if [ -d "${i}" ]; then
			echo -e "\t${i}"
			cd "${S}"/EMBOSS/"${i}"
			for j in *.desktop; do
				sed -i -e 's%Exec=%Exec=kaptain /usr/share/emboss-kaptain/%' ${j} || \
						die "Failed setting shared files path in ${i}/${j}."
			done
			cd "${S}"/EMBOSS
		fi
	done
	echo -e "\tDomainatrix"
	cd "${S}"/Domainatrix/Domainatrix
	for i in *.desktop; do
		sed -i -e 's%Exec=%Exec=kaptain /usr/share/emboss-kaptain/%' ${i} || \
				die "Failed setting shared files path in Domainatrix/${i}."
	done
}

src_install() {
	exeinto /usr/share/${PN}
	doexe *.kaptn || die "Failed to install grammar rules."
	doexe Domainatrix/*.kaptn || die "Failed to install Domainatrix grammar rules."
	mkdir -p "${D}"/usr/share/applnk/EMBOSS/Domainatrix
	cp -r EMBOSS/* ${D}/usr/share/applnk/EMBOSS || \
			die "Failed to install desktop files."
	cp -r Domainatrix/Domainatrix/* ${D}/usr/share/applnk/EMBOSS/Domainatrix || \
			die "Failed to install Domainatrix desktop files."
}
