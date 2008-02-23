# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

NEED_PYTHON=2.4

inherit eutils subversion distutils python multilib
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/trunk/"

DESCRIPTION="Official Sabayon Linux Package Manager library"
HOMEPAGE="http://www.sabayonlinux.org"
PYTHON_MODNAME="pysqlite2"
PYSQLITE_VER="2.3.5"
PYSQLITE_DIRNAME="pysqlite"
SRC_URI="http://initd.org/pub/software/pysqlite/releases/${PYSQLITE_VER:0:3}/${PYSQLITE_VER}/pysqlite-${PYSQLITE_VER}.tar.gz"

LICENSE="GPL-2 pysqlite"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="
	dev-db/sqlite:3
	sys-apps/diffutils
	"
RDEPEND="${DEPEND}"

src_unpack() {

	# prepare entropy stuff
	subversion_src_unpack

	# prepare sqlite stuff
	cd ${WORKDIR}
	distutils_src_unpack
	cd ${WORKDIR}/${PYSQLITE_DIRNAME}-${PYSQLITE_VER}
	sed -i -e 's/, "pysqlite2.test"//' \
		setup.py || die "sed in setup.py failed"
	# workaround to make checks work without installing them
	sed -i -e "s/pysqlite2.test/test/" \
		pysqlite2/test/__init__.py || die "sed failed"
	# correct encoding
	sed -i -e "s/\(coding: \)ISO-8859-1/\1utf-8/" \
		pysqlite2/__init__.py pysqlite2/dbapi2.py || die "sed failed"

	# setting svn revision
	#cd ${ESVN_STORE_DIR}/${PN}/trunk
	#SVNREV=$(svnversion)
	echo "${PV}" > ${S}/libraries/revision
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {

	##########
	#
	# Entropy
	#
	#########

	dodir /usr/$(get_libdir)/entropy/libraries
	
	# copying libraries
	cd ${S}/libraries
	insinto /usr/$(get_libdir)/entropy/libraries
	doins *.py
	doins revision

	# copy configuration
	cd ${S}/conf
	dodir /etc/entropy
	insinto /etc/entropy
	doins -r *
	rm ${D}/etc/entropy/equo.conf
	rm ${D}/etc/entropy/repositories.conf
	rm ${D}/etc/entropy/reagent.conf
	rm ${D}/etc/entropy/activator.conf
	rm ${D}/etc/entropy/remote.conf
	rm ${D}/etc/entropy/server.conf

	#########
	#
	# PySQLite
	#
	#########

	cd ${WORKDIR}/${PYSQLITE_DIRNAME}-${PYSQLITE_VER}
	distutils_src_install
	rm -rf "${D}"/usr/pysqlite2-doc
	rm -rf "${D}"/usr/share/doc

	########
	#
	# Python
	#
	########
	
	python_version
	mkdir "${D}"/usr/$(get_libdir)/entropy/libraries/pysqlite2
	mv "${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/${PYTHON_MODNAME}/* "${D}"/usr/$(get_libdir)/entropy/libraries/pysqlite2/ || die "cannot move pysqlite library"
	rm -rf "${D}"/usr/$(get_libdir)/python${PYVER}
	if use amd64; then
		cp ${S}/libraries/python/amd64/libpython* "${D}"/usr/$(get_libdir)/entropy/libraries/pysqlite2/
	else
		cp ${S}/libraries/python/x86/libpython* "${D}"/usr/$(get_libdir)/entropy/libraries/pysqlite2/
	fi
	chmod 555 "${D}"/usr/$(get_libdir)/entropy/libraries/pysqlite2/libpython*
}
