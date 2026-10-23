# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit cmake flag-o-matic python-any-r1

# Snapshot used by ONNX Runtime 1.31.0.
CommitId=3cf85e705098622d59056dcb8f5f963ea7bb0a00

DESCRIPTION="library of floating-point neural network inference operators"
HOMEPAGE="https://github.com/google/XNNPACK/"
SRC_URI="https://github.com/google/${PN}/archive/${CommitId}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${CommitId}"

# Includes conversion routines from the MIT-licensed FP16 library.
LICENSE="BSD MIT"
# Rebuild consumers on snapshot updates, as the C API/ABI can change.
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="+assembly +memopt +sparse static-libs test"

RESTRICT="!test? ( test )"
REQUIRED_USE="test? ( static-libs )"

RDEPEND="
	dev-libs/cpuinfo
	dev-libs/pthreadpool
"
DEPEND="${RDEPEND}
	dev-libs/FXdiv
	sci-ml/FP16
	test? ( dev-cpp/gtest )
"
BDEPEND="${PYTHON_DEPS}"

src_configure() {
	# -Werror=strict-aliasing
	# https://bugs.gentoo.org/953467
	# https://github.com/google/XNNPACK/issues/8800
	append-flags -fno-strict-aliasing
	# -Werror=lto-type-mismatch
	# https://bugs.gentoo.org/933414
	# https://github.com/google/XNNPACK/issues/6806
	filter-lto

	local mycmakeargs=(
		-DXNNPACK_BUILD_BENCHMARKS=OFF
		-DXNNPACK_USE_SYSTEM_LIBS=ON
		-DXNNPACK_BUILD_TESTS=$(usex test)
		-DXNNPACK_BUILD_ALL_MICROKERNELS=$(usex test)
		-DXNNPACK_LIBRARY_TYPE=$(usex static-libs static shared)
		-DXNNPACK_ENABLE_ASSEMBLY=$(usex assembly)
		-DXNNPACK_ENABLE_MEMOPT=$(usex memopt)
		-DXNNPACK_ENABLE_SPARSE=$(usex sparse)
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON
		-DPython_EXECUTABLE="${PYTHON}"
		-DPTHREADPOOL_SOURCE_DIR="${ESYSROOT}/usr"
		-DCPUINFO_SOURCE_DIR="${ESYSROOT}/usr"
		-DFXDIV_SOURCE_DIR="${ESYSROOT}/usr"
	)
	cmake_src_configure
}

src_test() {
	local CMAKE_SKIP_TESTS=(
		subgraph-fp16-test
		workspace-test
	)
	cmake_src_test
}

src_install() {
	cmake_src_install
	if ! use static-libs; then
		rm "${ED}/usr/$(get_libdir)/libxnnpack-microkernels-prod.a" || die
	fi
}
