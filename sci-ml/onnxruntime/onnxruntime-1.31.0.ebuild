# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit cmake python-any-r1

DESCRIPTION="Cross-platform inference engine for ONNX machine learning models"
HOMEPAGE="https://onnxruntime.ai/ https://github.com/microsoft/onnxruntime"
SRC_URI="
	https://github.com/microsoft/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/pva/pva.github.io/releases/download/v1.0/${P}-onnx-1.23.patch.xz
"

# Eigen, Boost.MP11 and other system headers are compiled into the library.
LICENSE="MIT Apache-2.0 BSD Boost-1.0 MPL-2.0"
SLOT="0/1"
KEYWORDS="~amd64"
IUSE="onednn xnnpack"
# The upstream unit suite additionally needs ONNX sources and model data.
RESTRICT="test"

RDEPEND="
	>=dev-cpp/abseil-cpp-20250814.0:=
	>=dev-libs/cpuinfo-2026.04.13:=
	>=dev-libs/flatbuffers-23.5.9:=
	>=dev-libs/protobuf-31.1:=
	>=dev-libs/re2-2024.07.02:=
	>=sci-ml/onnx-1.23.1:=[-disableStaticReg]
	onednn? ( >=sci-ml/oneDNN-3.0.1:=[openmp,-static-libs] )
	xnnpack? (
		>=dev-libs/pthreadpool-2025.05.14:=
		>=sci-ml/XNNPACK-2025.06.22:=
	)
"
DEPEND="${RDEPEND}
	>=dev-cpp/eigen-3.4.1:3
	>=dev-cpp/ms-gsl-4.2.1
	>=dev-cpp/nlohmann_json-3.11.3
	>=dev-cpp/safeint-3.0.28
	>=dev-libs/boost-1.82.0
	>=dev-libs/date-3.0.1
"
BDEPEND="${PYTHON_DEPS}
	>=dev-libs/flatbuffers-23.5.9
	>=dev-libs/protobuf-31.1[protoc(+)]
"

CMAKE_USE_DIR="${S}/cmake"
DOCS=( "${S}/README.md" "${S}/ThirdPartyNotices.txt" )

PATCHES=(
	"${WORKDIR}/${P}-onnx-1.23.patch"
	"${FILESDIR}/${P}-system-cpuinfo.patch"
	"${FILESDIR}/${P}-flatc-args.patch"
	"${FILESDIR}/${P}-system-cpu-providers.patch"
)

src_prepare() {
	default

	# Regenerate the checked-in C++ bindings with the system flatc version.
	"${PYTHON}" onnxruntime/core/flatbuffers/schema/compile_schema.py \
		--flatc "${BROOT}/usr/bin/flatc" --language cpp \
		--flatc-args --include-prefix core/flatbuffers/schema/ || die
	"${PYTHON}" onnxruntime/lora/adapter_format/compile_schema.py \
		--flatc "${BROOT}/usr/bin/flatc" --language cpp || die

	# Keep the upstream wrapper (test/flatbuffers/flatbuffers_utils_test.fbs#L4-L6)
	sed -e 's@"flatbuffers/flatbuffers.h"@"core/common/flatbuffers.h"@' -i \
		onnxruntime/core/flatbuffers/schema/{ort,ort_training_checkpoint}.fbs.h \
		onnxruntime/test/flatbuffers/flatbuffers_utils_test.fbs.h || die

	cmake_prepare
}

src_configure() {
	local mycmakeargs=(
		--compile-no-warning-as-error
		-DCMAKE_PROJECT_onnxruntime_INCLUDE="${FILESDIR}/${P}-system-deps.cmake"
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS
		-DONNX_CUSTOM_PROTOC_EXECUTABLE="${BROOT}/usr/bin/protoc"
		-DPython_EXECUTABLE="${PYTHON}"
		# Build the shared inference library with the selected CPU providers.
		-Donnxruntime_BUILD_SHARED_LIB=ON
		-Donnxruntime_BUILD_UNIT_TESTS=OFF
		-Donnxruntime_USE_DNNL=$(usex onednn)
		-Donnxruntime_USE_SYSTEM_DNNL=$(usex onednn)
		-Donnxruntime_USE_XNNPACK=$(usex xnnpack)
		-Donnxruntime_USE_SYSTEM_XNNPACK=$(usex xnnpack)
		# The tree lacks upstream's patched CUTLASS 4.7.0 and DeepGEMM
		# needed for SM90+ GPUs, so CUDA support is not exposed yet.
		-Donnxruntime_USE_CUDA=OFF
		# No package in the tree currently needs the Python bindings.
		-Donnxruntime_ENABLE_PYTHON=OFF
		-Donnxruntime_ENABLE_TRAINING=OFF
		# Match the system ONNX library built with ONNX_USE_LITE_PROTO=ON.
		-Donnxruntime_USE_FULL_PROTOBUF=OFF
	)
	cmake_src_configure
}
