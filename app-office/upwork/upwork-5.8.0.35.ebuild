# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils xdg-utils unpacker

DESCRIPTION="Project collaboration and tracking software for upwork.com"
HOMEPAGE="https://www.upwork.com/"
SRC_URI="
	amd64? ( https://upwork-usw2-desktopapp.upwork.com/binaries/v5_8_0_35_be1a1520901c4eef/upwork_5.8.0.35_amd64.deb )
"

LICENSE="ODESK"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="fetch bindist mirror strip splitdebug"

RDEPEND="
	dev-libs/expat
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	sys-apps/dbus
	x11-libs/gtk+:3[cups]
"

S="${WORKDIR}"

PATCHES=( "${FILESDIR}/${PN}-desktop-r2.patch" )

# Binary only distribution
QA_PREBUILT="*"

pkg_nofetch() {
	einfo "This ebuild is fetch-restricted."
	einfo
	einfo "1. Open the following page in your browser:"
	einfo "   https://www.upwork.com/ab/downloads/?os=linux"
	einfo
	einfo "2. Download the Linux binary (deb, whatever matches)"
	einfo "3. Put this file into your distfiles directory:"
	einfo "   \${DISTDIR}"
	einfo
	einfo "To see your actual DISTDIR, run:"
	einfo "  portageq envvar DISTDIR"
	einfo
	einfo "After that, run emerge again."
}

src_install() {
	pax-mark m opt/Upwork/upwork

	insinto /opt
	doins -r opt/Upwork
	fperms 0755 /opt/Upwork/upwork

	insinto /usr/share
	doins -r usr/share/icons

	domenu usr/share/applications/upwork.desktop
	doicon usr/share/icons/hicolor/128x128/apps/upwork.png
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
