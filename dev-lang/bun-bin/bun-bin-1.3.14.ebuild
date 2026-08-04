# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"

DESCRIPTION="All-in-one JavaScript and TypeScript runtime and toolkit"
HOMEPAGE="https://bun.com/ https://github.com/oven-sh/bun"
SRC_URI="
	amd64? (
		https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64.zip
			-> ${P}-amd64.zip
	)
	arm64? (
		https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-aarch64.zip
			-> ${P}-arm64.zip
	)
"

S="${WORKDIR}"

LICENSE="MIT LGPL-2 LGPL-2.1 BSD BSD-2 Apache-2.0 Apache-2.0-with-LLVM-exceptions ZLIB Artistic GPL-2 icu IJG"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2"
REQUIRED_USE="
	elibc_glibc
	amd64? (
		cpu_flags_x86_avx
		cpu_flags_x86_avx2
	)
"

RESTRICT="strip test"
QA_PREBUILT="usr/bin/${MY_PN}"

BDEPEND="app-arch/unzip"

src_install() {
	local bun_dir

	case ${ARCH} in
		amd64) bun_dir="bun-linux-x64" ;;
		arm64) bun_dir="bun-linux-aarch64" ;;
		*) die "unsupported architecture: ${ARCH}" ;;
	esac

	dobin "${bun_dir}/${MY_PN}"
	dosym "${MY_PN}" "/usr/bin/bunx"
}
