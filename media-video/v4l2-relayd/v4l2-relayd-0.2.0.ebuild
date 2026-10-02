# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd

DESCRIPTION="Relay GStreamer video sources to v4l2loopback devices"
HOMEPAGE="https://gitlab.com/vicamo/v4l2-relayd"
SRC_URI="https://gitlab.com/vicamo/${PN}/-/archive/upstream/${PV}/${PN}-upstream-${PV}.tar.bz2 -> ${P}.tar.bz2"
S="${WORKDIR}/${PN}-upstream-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libcamera"

COMMON_DEPEND="
	>=dev-libs/glib-2.36:2
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
"
DEPEND="${COMMON_DEPEND}
	virtual/os-headers
"
RDEPEND="${COMMON_DEPEND}
	media-libs/gst-plugins-good:1.0
	media-plugins/gst-plugins-libpng:1.0
	media-plugins/gst-plugins-v4l2:1.0
	media-video/v4l2loopback
	libcamera? ( media-libs/libcamera[gstreamer] )
"
BDEPEND="
	dev-build/autoconf-archive
	virtual/pkgconfig
"

DOCS=( README.md "${FILESDIR}/README.gentoo" )

src_prepare() {
	default

	sed -i -e 's/ -Werror\b//' Makefile.am || die

	# The upstream generator hardcodes /lib/systemd/system.
	sed -i -e "s|/lib/systemd/system/|$(systemd_get_systemunitdir)/|" \
		data/systemd/v4l2-relayd-generator || die

	eautoreconf
}

src_configure() {
	econf \
		--disable-debug \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		--with-systemdsystemgeneratordir="$(systemd_get_systemgeneratordir)" \
		--with-modulesloaddir="${EPREFIX}/usr/lib/modules-load.d"
}

src_install() {
	default
	keepdir /etc/v4l2-relayd.d
}

pkg_postinst() {
	elog "Create /etc/v4l2-relayd.d/<name>.conf for each camera."
	elog "See /usr/share/doc/${PF}/README.gentoo* for configuration examples."
	elog "USE=libcamera installs libcamerasrc; select it with VIDEOSRC in the config."
}
