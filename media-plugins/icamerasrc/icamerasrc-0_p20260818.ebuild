# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

# Snapshot of the icamerasrc_slim_api branch.
EGIT_COMMIT="7517af78f49a18dde6de86042055aa14ebe6d184"
DESCRIPTION="GStreamer source plugin for the Intel IPU6 camera HAL"
HOMEPAGE="https://github.com/intel/icamerasrc/tree/icamerasrc_slim_api"
SRC_URI="https://github.com/intel/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

LICENSE="|| ( MIT LGPL-2+ )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="vaapi"

RDEPEND="
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/ipu6-camera-hal:=
	x11-libs/libdrm[video_cards_intel]
	vaapi? (
		media-libs/gst-plugins-bad:1.0[vaapi]
		media-libs/libva:=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default

	sed -i -e 's/ -Werror\b//' src/Makefile.am src/interfaces/Makefile.am || die

	# Point to the installed headers, which include gst/gst.h and ICamera.h.
	sed -i \
		-e 's|/icamerasrc/interfaces|/gstreamer-1.0/gst/icamera|' \
		-e '/^Libs:/i Requires: gstreamer-1.0 libcamhal' \
		libgsticamerasrc.pc.in || die

	eautoreconf
}

src_configure() {
	# Required for the libcamhal API provided by media-libs/ipu6-camera-hal.
	export CHROME_SLIM_CAMHAL=ON

	econf $(use_enable vaapi gstdrmformat)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	elog "icamerasrc uses Intel's libcamhal, not libcamera."
	elog "Test the camera with, for example:"
	elog "  gst-launch-1.0 icamerasrc buffer-count=7 ! \\"
	elog "    video/x-raw,format=NV12,width=1280,height=720 ! videoconvert ! autovideosink"
	elog "The format and resolution depend on the sensor; see README.md."
}
