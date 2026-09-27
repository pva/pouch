# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

inherit meson python-single-r1

DESCRIPTION="Complex camera support library"
HOMEPAGE="https://libcamera.org"
SRC_URI="https://gitlab.freedesktop.org/camera/libcamera/-/archive/v${PV}/libcamera-v${PV}.tar.bz2"
S="${WORKDIR}/libcamera-v${PV}"

LICENSE="Apache-2.0 CC0-1.0 BSD BSD-2 CC-BY-4.0 CC-BY-SA-4.0 GPL-2+ GPL-2 LGPL-2.1+ MIT"

# libcamera uses the major and minor version components as the soname.
# See: https://gitlab.freedesktop.org/camera/libcamera/-/blob/v0.7.2/meson.build#L59
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv ~x86"
IUSE="drm elfutils gstreamer gui jpeg openssl python sdl softisp-gpu test tiff +tools trace +udev unwind v4l virtual"
RESTRICT="
	!test? ( test )
"
# Code generators also use the selected Python when bindings are disabled.
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	jpeg? ( sdl )
	sdl? ( tools )
	test? ( udev )
	tiff? ( tools )
"

# 'dev-cpp/gtest' is required as runtime dependency because it's used by lc-compliance tool
COMMON_DEPEND="
	dev-libs/libyaml
	elfutils? ( dev-libs/elfutils )
	gstreamer? (
		dev-libs/glib:2
		>=media-libs/gstreamer-1.14.0:1.0
		>=media-libs/gst-plugins-base-1.14:1.0
	)
	!openssl? ( net-libs/gnutls:= )
	openssl? ( dev-libs/openssl:= )
	python? ( ${PYTHON_DEPS} )
	softisp-gpu? ( media-libs/libglvnd )
	tools? (
		>=dev-cpp/gtest-1.10.0:=
		dev-libs/libevent:=
		drm? ( x11-libs/libdrm )
		gui? (
			>=dev-qt/qtbase-6.2:6[gui,opengl,widgets]
		)
		sdl? (
			media-libs/libsdl2[video(+)]
			jpeg? ( media-libs/libjpeg-turbo:= )
		)
		tiff? ( media-libs/tiff:= )
	)
	trace? (
		dev-util/lttng-ust:=
	)
	udev? ( virtual/libudev:= )
	unwind? ( sys-libs/libunwind:= )
	virtual? ( media-libs/libyuv:= )
"

DEPEND="
	${COMMON_DEPEND}
	python? ( dev-python/pybind11 )
"

RDEPEND="
	${COMMON_DEPEND}
	softisp-gpu? ( media-libs/mesa[opengl] )
"

# 'dev-libs/openssl' is called by src/ipa/ipa-sign.sh to sign IPA modules
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/ply[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
	dev-libs/openssl
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.7.2-crypto-backend.patch
	"${FILESDIR}"/${PN}-disable-problematic-tests.patch
	"${FILESDIR}"/${PN}-0.7.2-disable-namespace-tests.patch
)

src_configure() {
	# Pipeline 'rpi/pisp' requires libpisp, not yet available in Gentoo.
	local pipelines=imx8-isi,ipu3,mali-c55,rkisp1,rpi/vc4,simple,uvcvideo,vimc
	use virtual && pipelines+=,virtual

	local emesonargs=(
		# Broken for >=dev-python/sphinx-7
		# $(meson_feature doc documentation)
		-Ddocumentation=disabled
		$(meson_feature python pycamera)
		# Requires TensorFlow Lite and separately supplied AWB models.
		-Drpi-awb-nn=disabled
		$(meson_feature softisp-gpu)
		-Dpipelines=${pipelines}
		$(meson_feature tools cam)
		$(meson_feature tools lc-compliance)
		$(meson_feature drm cam-output-kms)
		$(meson_feature sdl cam-output-sdl2)
		$(meson_feature jpeg cam-jpeg)
		$(meson_feature tiff apps-output-dng)
		$(meson_feature gstreamer)
		$(meson_feature !openssl gnutls)
		$(meson_feature trace tracing)
		$(meson_feature unwind libunwind)
		$(meson_feature elfutils libdw)
		$(meson_feature udev)
		$(meson_feature v4l v4l2)
		$(meson_use test)
	)

	# QCam requires both tools & gui USE flags to be enabled
	if use tools && use gui; then
		emesonargs+=(
			-Dqcam=enabled
		)
	else
		emesonargs+=(
			-Dqcam=disabled
		)
	fi

	meson_src_configure
}

src_install() {
	meson_src_install
	use python && python_optimize

	# Exclude IPA signed modules from stripping process
	# Note: This is required to prevent strip tool to invalidate their signature
	dostrip -x "/usr/$(get_libdir)/libcamera/ipa/"
}
