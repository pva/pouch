# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_PV=${PV/_p/_}
DESCRIPTION="Intel IPU6 camera hardware abstraction layer"
HOMEPAGE="https://github.com/intel/ipu6-camera-hal"
SRC_URI="https://github.com/intel/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

# The HAL links static image-processing libraries from ipu6-camera-bins.
LICENSE="Apache-2.0 Intel-ipu6"
SLOT="0/0"
KEYWORDS="~amd64"
RESTRICT="bindist"

RDEPEND="
	dev-libs/expat
	=media-libs/ipu6-camera-bins-${PV}*
	>=x11-libs/libdrm-2.4.114
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=( "${FILESDIR}/${PN}-20260629_p2-cmake.patch" )
DOCS=( README.md "${FILESDIR}/README.gentoo" )

src_configure() {
	local mycmakeargs=(
		-DBUILD_CAMHAL_ADAPTOR=ON
		-DBUILD_CAMHAL_PLUGIN=ON
		-DIPU_VERSIONS="ipu6;ipu6ep;ipu6epmtl"
		-DUSE_PG_LITE_PIPE=ON
		-DENABLE_SANDBOXING=OFF
		-DFACE_DETECTION=OFF
		-DSUPPORT_LIVE_TUNING=OFF
		-DVERSION="${PV}"
	)
	cmake_src_configure
}

pkg_postinst() {
	elog "This is Intel's camera HAL, separate from libcamera's software ISP."
	elog "It requires a compatible IPU6 PSYS driver and firmware."
	elog "GStreamer applications need Intel's icamerasrc plugin to use this HAL."
	elog "See /usr/share/doc/${PF}/README.gentoo* for details."
}
