# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

CommitId=15a6644ba1c45f1acc16ac1e883efc3e56c6bed2

DESCRIPTION="Portable and efficient thread pool implementation"
HOMEPAGE="https://github.com/google/pthreadpool"
SRC_URI="https://github.com/google/${PN}/archive/${CommitId}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${CommitId}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/FXdiv
	test? ( dev-cpp/gtest )
"

PATCHES=(
	"${FILESDIR}/${P}-system-deps.patch"
)

src_prepare() {
	cmake_src_prepare

	# The v2 tests use std::set::contains, which requires C++20.
	sed -i -e 's/CXX_STANDARD 11/CXX_STANDARD 20/g' CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DPTHREADPOOL_BUILD_BENCHMARKS=OFF
		-DPTHREADPOOL_BUILD_TESTS=$(usex test)
	)
	if use test; then
		# Explicitly selecting Linux's default backend enables the v2 tests.
		mycmakeargs+=( -DPTHREADPOOL_SYNC_PRIMITIVE=futex )
	fi
	cmake_src_configure
}
