# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 cmake

DESCRIPTION="Open Neural Network Exchange (ONNX)"
HOMEPAGE="https://onnx.ai/ https://github.com/onnx/onnx"
SRC_URI="https://github.com/onnx/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# BSD/MIT are from nanobind and its robin-map headers in the Python module.
LICENSE="Apache-2.0 BSD MIT"
# Upstream does not provide a stable C++ ABI or versioned SONAME.
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64"
IUSE="disableStaticReg"
RESTRICT="test"

RDEPEND="
	dev-cpp/abseil-cpp:=
	>=dev-libs/protobuf-31.1:=
	>=dev-python/ml-dtypes-0.5.4[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.23.2[${PYTHON_USEDEP}]
	>=dev-python/protobuf-6.31.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.7.1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-cpp/robin-map-1.3.0
	>=dev-libs/protobuf-31.1[protoc(+)]
	>=dev-python/nanobind-2.13[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/${P}-released-opset.patch"
)

src_prepare() {
	distutils-r1_src_prepare
	cmake_prepare
}

src_configure() {
	# Configure the shared C++ libraries. The Python extension is configured
	# separately by scikit-build-core when python_compile() builds a wheel.
	python_setup
	mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DONNX_BUILD_PYTHON=OFF
		-DONNX_BUILD_TESTS=OFF
		-DONNX_INSTALL=ON
		-DONNX_USE_PROTOBUF_SHARED_LIBS=ON
		-DONNX_USE_LITE_PROTO=ON
		-DONNX_DISABLE_STATIC_REGISTRATION=$(usex disableStaticReg)
		-DONNX_PROTOC_EXECUTABLE="${BROOT}/usr/bin/protoc"
		-DPython3_EXECUTABLE="${PYTHON}"
	)
	cmake_src_configure
}

python_compile() {
	# Since 1.23 the Python module requires a static ONNX library. Build it
	# separately from the shared C++ libraries installed by cmake_src_install.
	local DISTUTILS_ARGS=(
		"${mycmakeargs[@]}"
		-DBUILD_SHARED_LIBS=OFF
		-DONNX_BUILD_PYTHON=ON
		-DONNX_INSTALL=OFF
		-DNB_USE_SUBMODULE_DEPS=OFF
		-DPython3_EXECUTABLE="${PYTHON}"
		-DPython_EXECUTABLE="${PYTHON}"
		-Dnanobind_DIR="$(python_get_sitedir)/nanobind/cmake"
	)
	# Override the source-tree build directory from pyproject.toml.
	local -x SKBUILD_BUILD_DIR="${BUILD_DIR}/build"
	distutils-r1_python_compile
}

src_compile() {
	cmake_src_compile
	distutils-r1_src_compile
}

src_install() {
	cmake_src_install
	distutils-r1_src_install
}
