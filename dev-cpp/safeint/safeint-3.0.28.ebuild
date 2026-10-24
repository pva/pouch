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

PATCHES=(
	"${FILESDIR}/${P}-install-the-library.patch"
	"${FILESDIR}/${P}-make-tests-optional.patch"
	"${FILESDIR}/${P}-strip-O3.patch"
	"${FILESDIR}/${P}-move-regression.patch"
	"${FILESDIR}/${P}-toolchain.patch"
)

src_prepare() {
	cmake_src_prepare

	# Match 3.0.28a: header-only C functions need internal linkage when
	# the compiler does not inline them (e.g. MultiplyInt64 with GCC).
	# https://github.com/dcleblanc/SafeInt/blob/3.0.28a/safe_math_impl.h
	sed -i -e 's/^inline /static inline /' safe_math{,_impl}.h || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}
