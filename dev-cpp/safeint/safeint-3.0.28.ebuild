# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C and C++ libraries for checked integer arithmetic"
HOMEPAGE="https://github.com/dcleblanc/SafeInt"
SRC_URI="https://github.com/dcleblanc/SafeInt/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/SafeInt-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

DOCS=( README.md helpfile.md )

src_prepare() {
	# Upstream's test build searches for and runs GCC, Clang and MSVC
	# independently. Use the selected toolchain and respect the user's flags.
	cp "${FILESDIR}/${P}-CMakeLists.txt" CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}
