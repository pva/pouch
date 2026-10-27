# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 cmake flag-o-matic

DESCRIPTION="Open Neural Network Exchange (ONNX)"
HOMEPAGE="https://onnx.ai/ https://github.com/onnx/onnx"
SRC_URI="https://github.com/onnx/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# BSD/MIT are from nanobind and its robin-map headers in the Python module.
LICENSE="Apache-2.0 BSD MIT"
# Upstream does not provide a stable C++ ABI or versioned SONAME.
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64"
IUSE="disableStaticReg"

RDEPEND="
	dev-cpp/abseil-cpp:=
	>=dev-libs/protobuf-31.1:=
	>=dev-python/ml-dtypes-0.5.4[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.23.2[${PYTHON_USEDEP}]
	>=dev-python/protobuf-6.31.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.7.1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
"
BDEPEND="
	>=dev-cpp/robin-map-1.3.0
	>=dev-libs/protobuf-31.1[protoc(+)]
	>=dev-python/nanobind-2.13[${PYTHON_USEDEP}]
	test? (
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
EPYTEST_XDIST=1
distutils_enable_tests pytest

PATCHES=(
	"${FILESDIR}/${P}-released-opset.patch"
	"${FILESDIR}/${P}-export-symbols.patch"
)

src_prepare() {
	distutils-r1_src_prepare
	# pyproject.toml always passes this Windows-only option, so CMake warns
	# that it is unused.
	sed -i '/^ONNX_USE_MSVC_STATIC_RUNTIME = /d' pyproject.toml || die
	cmake_prepare
}

src_configure() {
	# cmake.eclass's default RelWithDebInfo build lacks CMake's -DNDEBUG,
	# so debug checks stay enabled. Disable them as in distutils-r1.eclass.
	use debug || append-cppflags -DNDEBUG

	# Configure the shared C++ libraries. The Python extension is configured
	# separately by scikit-build-core when python_compile() builds a wheel.
	python_setup
	mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DONNX_BUILD_PYTHON=OFF
		-DONNX_BUILD_TESTS=$(usex test)
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
		# C++ tests are built once, against the shared library.
		-DONNX_BUILD_TESTS=OFF
		-DONNX_INSTALL=OFF
		-DNB_USE_SUBMODULE_DEPS=OFF
		-DPython3_EXECUTABLE="${PYTHON}"
		-DPython_EXECUTABLE="${PYTHON}"
		-Dnanobind_DIR="$(python_get_sitedir)/nanobind/cmake"
		# Override USE=disableStaticReg: the Python bindings never register
		# operator schemas themselves and rely on the static registration.
		-DONNX_DISABLE_STATIC_REGISTRATION=OFF
	)
	# Override the source-tree build directory from pyproject.toml.
	local -x SKBUILD_BUILD_DIR="${BUILD_DIR}/build"
	distutils-r1_python_compile
}

src_compile() {
	cmake_src_compile
	distutils-r1_src_compile
}

python_test() {
	local EPYTEST_IGNORE=(
		# Tests the docs generator, imported from ${S}/docs.
		"${S}/tests/python/onnx_sphinx_test.py"
	)

	# python -m pytest puts the cwd on sys.path, so run outside ${S}, where
	# the onnx/ source directory would shadow the built package.
	cd "${T}" || die
	epytest "${S}/tests/python"
}

src_test() {
	# Without static registration the schema registry starts empty, so like
	# upstream CI run only the tests that register schemas themselves.
	if use disableStaticReg; then
		local -x GTEST_FILTER='SchemaRegistrationTest*'
	fi
	cmake_src_test
	distutils-r1_src_test
}

src_install() {
	cmake_src_install
	distutils-r1_src_install
}
