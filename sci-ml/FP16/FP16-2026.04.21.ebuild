# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

CommitId=782eea126dc5c755827be751a099eb01826175cf

DESCRIPTION="conversion to/from half-precision floating point formats"
HOMEPAGE="https://github.com/Maratyszcza/FP16/"
SRC_URI="https://github.com/Maratyszcza/${PN}/archive/${CommitId}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${CommitId}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

DEPEND="test? ( dev-cpp/gtest )"

PATCHES=(
	"${FILESDIR}/${P}-system-deps.patch"
)

src_prepare() {
	# >=dev-cpp/gtest-1.13.0 requires C++14 or later.
	sed -i -e 's/CXX_STANDARD 11/CXX_STANDARD 17/g' CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DFP16_BUILD_BENCHMARKS=OFF
		-DFP16_BUILD_TESTS=$(usex test)
	)
	cmake_src_configure
}
