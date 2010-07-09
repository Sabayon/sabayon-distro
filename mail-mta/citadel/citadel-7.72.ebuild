
# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils multilib

DESCRIPTION="Groupware/Email/Jabberserver. Collaboration, Calender, BBS/Forum, Chat with easy install and usage"
HOMEPAGE="http://www.citadel.org/"
SRC_URI="http://easyinstall.citadel.org/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ldap mailwrapper pam pic ssl threads"

DEPEND="=dev-libs/libcitadel-${PV}
	>=sys-libs/db-4.1.25_p1
	virtual/libiconv
	ldap? ( >=net-nds/openldap-2.0.27 )
	pam? ( sys-libs/pam )
	ssl? ( >=dev-libs/openssl-0.9.6 )"
RDEPEND="${DEPEND}
	net-mail/mailbase
	!mailwrapper? ( !virtual/mta !net-mail/mailwrapper )
	mailwrapper? ( >=net-mail/mailwrapper-0.2 )"

PROVIDE="virtual/mta
	virtual/mda
	virtual/imapd"

MESSAGEBASE="/var/lib/citadel"

pkg_setup() {
	#Homedir needs to be the same as --with-datadir
	einfo "Adding Citadel User/Group"
	enewgroup citadel
	enewuser citadel -1 -1 ${MESSAGEBASE} citadel,mail
}

src_configure() {
	econf \
		--with-rundir=/var/run/citadel \
		--with-datadir=/var/lib/citadel \
		--with-spooldir=/var/spool/citadel \
		--with-autosysconfdir=/var/lib/citadel/data \
		--with-staticdatadir=/etc/citadel \
		--with-sysconfdir=/etc/citadel \
		--with-ssldir=/etc/ssl/citadel \
		--with-helpdir=/usr/share/citadel-server \
		--with-docdir=/usr/share/doc/${PF} \
		--with-utility-bindir=/usr/$(get_libdir)/citadel \
		--without-libdspam \
		$(use_enable pic pie) \
		$(use_with pam) \
		$(use_with ssl openssl) \
		$(use_with ldap) \
		--with-db
}

src_install() {
	if use pam ; then
		 dodir /etc/pam.d || die "Creating /etc/pam.d failed in sandbox"
	fi

	emake DESTDIR="${D}" install-new || die "make install failed"

	# Protect ${MESSAGEBASE}
	echo CONFIG_PROTECT="${MESSAGEBASE}" > "${T}"/10citadel
	doenvd "${T}"/10citadel || die "Config-protecting failed"

	# Keep emerge from removing empty directories when updating
	keepdir "${MESSAGEBASE}"/data
	keepdir /var/spool/citadel/network/{systems,spoolout,spoolin}
	keepdir /var/run/citadel/network/{systems,spoolout,spoolin}
	keepdir /etc/citadel/messages

	#Fix some permissions and sendmail stuff
	fowners citadel:citadel /etc/citadel /var/lib/citadel || die "Changing owner failed"
	fowners root:citadel /usr/sbin/citmail || die "Changing owner failed"
	rm "${D}"/usr/sbin/sendmail || die "Removinf sendmail bin failed"

	if use mailwrapper ; then
		insinto /etc/mail
		doins "${FILESDIR}"/mailer.conf || die "Installing mailer.conf failed"
	else
		dosym /usr/sbin/citmail /usr/sbin/sendmail || die "Linking sendmail to citmail failed"
		dosym /usr/sbin/citmail /usr/$(get_libdir)/sendmail || die "Compatibility sendmail link failed"
	fi

	if use ldap ; then
		insinto /etc/openldap/schema
		doins openldap/citadel.schema || die "Inserting LDAP schema failed"
		doins openldap/rfc2739.schema || die "Inserting LDAP schema failed"
	fi

	newinitd "${FILESDIR}"/citadel.init citadel || die "Inserting initscript failed"
	newconfd "${FILESDIR}"/citadel.confd citadel || die  "Inserting conf for initscript failed"
}

pkg_postinst() {
	#remove a file Citadel complains about in the logs while running
	rm /var/lib/citadel/data/.keep_mail-mta_citadel-0 || die "Removing keepdir dummie failed"

	einfo "The administration tools have been placed in /usr/$(get_libdir)/citadel"
	einfo
	einfo "There are two possible options to get Citadel running, if this is"
	einfo "a new install:"
	einfo
	einfo "1. The no-nonse fullspeed approach with most stuff done for you:"
	einfo "# emerge --config =${CATEGORY}/${PF}"
	einfo
	einfo "2. Manually configuring it with its setup routine:"
	einfo "You should make yourself familiar with Citadels setup:"
	einfo "http://www.citadel.org/doku.php/documentation:cmdman:setup"
	einfo "You probalby do not want to let setup chose the mode of starting"
	einfo
	einfo "The second approach is only recommended to experienced users!!!"
	einfo
	einfo "The service will automatically start after you configured it."
	einfo "Initscript is /etc/init.d/citadel. Also look into /etc/conf.d"
	einfo
	einfo "The following clients are available:"
	einfo "a) the citadel console client was installed with this ebuild"
	einfo "b) www-servers/webcit provides a web-based gui"
}

pkg_config() {
	#we have to stop the server if it is accidently running
	[ -f /var/run/citadel/citadel.socket ] && \
		die "Citadel seems to be running, please stop it while configuring!"

	#Citadel's setup uses a few enviromental variables to control it.
	# Mandatory for non-interactive setup!
	export CITADEL_INSTALLER="yes"

	# Citadel location.
	export CITADEL="/var/run/citadel/"

	if use ldap ; then
		export SLAPD_Binary="/usr/$(get_libdir)/openldap/slapd"
		export LDAP_CONFIG="/etc/openldap/sldap.conf"
	fi

	# Don't create any inittab/initscript/xinet stuff entry.
	# We'll provide our own init script
	export CREATE_INITTAB_ENTRY="no"
	export CREATE_XINETD_ENTRY="no"
	export NO_INIT_SCRIPTS="yes"
	export ACT_AS_MTA="no" #just prohibits setup to mess with init scripts

	einfo "On which ip should the server listen?"
	einfo "Press enter to default to 0.0.0.0 and listen on all interfaces."
	read -rp "   >" ipadress ; echo
	if  [ -z "$ipadress" ] ; then
		export IP_ADDR="0.0.0.0"
	else
		export IP_ADDR="$ipadress"
	fi

	# The main admin name for citadel can be chosen at random
	einfo "Insert a name for your citadel admin account:"
	read -rp "   >" sysadminname ; echo
	export SYSADMIN_NAME="$sysadminname"

	local pwd1="misch"
	local pwd2="masch"

	until [[ "x$pwd1" = "x$pwd2" ]] ; do
		einfo "Insert a password for the citadel admin user"
		einfo "Avoid [\"'\\_%] characters in the password"
		read -rsp "   >" pwd1 ; echo

		einfo "Retype the password"
		read -rsp "   >" pwd2 ; echo

		if [[ "x$pwd1" != "x$pwd2" ]] ; then
			ewarn "Passwords are not the same"
		fi
	done
	export SYSADMIN_PW="$pwd2"

	#Now we will create the config using defaults and enviromental variables.
	/usr/$(get_libdir)/citadel/setup -q
	unset SYSADMIN_PW

	#Verify the /etc/services entry was made
	if [ -f /etc/services ] && ! grep -q '^citadel' /etc/services ; then
		echo "citadel		504/tcp		# citadel" >> /etc/services
	fi

	einfo "Be sure to read the documentation in /usr/share/doc/${PF}"
	einfo
	einfo "The server should now be up and running, enjoy!"
	einfo "Citadel will listen on its default port 504"
	if use mailwrapper; then
		einfo
		einfo "Citadel listens on port 25 by default, even with mailwrapper useflag!"
		einfo "Right now this can only be disabled in WebCit or with the cli client."
		einfo "There is no elegant way to disable that atm, will be fixed upstream."
		einfo "Sorry for this inconvenience!"
	fi
}
