# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils games java-pkg-2

DESCRIPTION="Dedicated server for Minecraft"
HOMEPAGE="http://www.minecraft.net"
SRC_URI="http://www.minecraft.net/download/minecraft_server.jar -> ${P}.jar"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="virtual/jdk:1.6"

RDEPEND="virtual/jre:1.6
	app-misc/tmux
	sys-apps/openrc"

S="${WORKDIR}"

DIR="/var/lib/minecraft"
PID="/var/run/minecraft"

pkg_setup() {
	java-pkg-2_pkg_setup
	games_pkg_setup
}

src_unpack() {
	true # NOOP!
}

src_prepare() {
	cp "${FILESDIR}"/{directory,init,console}.sh . || die
	sed -i "s/@GAMES_USER_DED@/${GAMES_USER_DED}/g" directory.sh init.sh || die
	sed -i "s/@GAMES_GROUP@/${GAMES_GROUP}/g" console.sh || die
}

src_install() {
	java-pkg_register-optional-dependency hmod
	java-pkg_newjar "${DISTDIR}/${P}.jar" "${PN}.jar"

	java-pkg_dolauncher "${PN}" -into "${GAMES_PREFIX}" -pre "directory.sh" \
		--main net.minecraft.server.MinecraftServer --java_args "-Xmx1024M -Xms512M  -Djava.net.preferIPv4Stack=true" --pkg_args "nogui"

	diropts -o "${GAMES_USER_DED}" -g "${GAMES_GROUP}"
	keepdir "${DIR}" "${PID}" || die
	gamesperms "${D}${DIR}" "${D}${PID}" || die

	newinitd init.sh "${PN}" || die
	newgamesbin console.sh "${PN}-console" || die

	prepgamesdirs
}

pkg_postinst() {
	einfo "You may run minecraft-server as a regular user or start a system-wide"
	einfo "instance using /etc/init.d/minecraft. The server files are stored in"
	einfo "~/.minecraft/servers or /var/lib/minecraft respectively."
	echo
	einfo "The console for system-wide instances can be accessed by any user in"
	einfo "the ${GAMES_GROUP} group using the minecraft-server-console command. This"
	einfo "starts a client instance of tmux. The most important key-binding to"
	einfo "remember is Ctrl-b d, which will detach the console and return you to"
	einfo "your previous screen without stopping the server."
	echo
	einfo "This package allows you to start multiple Minecraft server instances."
	einfo "You can do this by adding a name after minecraft-server or by creating"
	einfo "a symlink such as /etc/init.d/minecraft.foo. You would then access the"
	einfo "console with \"minecraft-server-console foo\". The default server name"
	einfo "is \"main\"."
	echo

	games_pkg_postinst
}
