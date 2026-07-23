# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.88.0"

# Update npm tarbal
# npm ci --include=dev --ignore-scripts --audit=false --fund=false --cache="../npm-cache"
# cd .. && XZ_OPT='-T0 -9' tar -acf codex-trace-0.4.0-node_modules.tar.xz npm-cache
inherit cargo desktop xdg

DESCRIPTION="OpenAI Codex CLI session log viewer"
HOMEPAGE="https://github.com/PixelPaw-Labs/codex-trace"
SRC_URI="
	https://github.com/PixelPaw-Labs/${PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/pva/pva.github.io/releases/download/v1.0/${P}-crates.tar.xz
	https://github.com/pva/pva.github.io/releases/download/v1.0/${P}-node_modules.tar.xz
"

LICENSE="MIT"
# Dependent Cargo and npm package licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 BlueOak-1.0.0
	CC0-1.0 ISC MIT MIT-0 MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

DEPEND="
	net-libs/webkit-gtk:4.1
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-lang/typescript
"

NPM_FLAGS=(
	--audit false
	--color false
	--foreground-scripts
	--offline
	--progress false
	--save false
	--verbose
	--cache "../npm-cache"
)

pkg_setup() {
	rust_pkg_setup
}

src_configure() {
	local myfeatures=(
		tauri/custom-protocol
	)

	cargo_src_configure --manifest-path src-tauri/Cargo.toml --locked
}

src_compile() {
	npm ci "${NPM_FLAGS[@]}" || die
	npm run build || die
	cargo_src_compile --bin "${PN}"
}

src_test() {
	./node_modules/.bin/vitest run || die
	cargo_src_test
}

src_install() {
	dobin "src-tauri/$(cargo_target_dir)/${PN}"

	newicon -s 32 src-tauri/icons/32x32.png "${PN}.png"
	newicon -s 128 src-tauri/icons/128x128.png "${PN}.png"
	newicon -s 256 src-tauri/icons/128x128@2x.png "${PN}.png"
	make_desktop_entry "${PN}" "Codex Trace" "${PN}" "Development;Utility;"

	einstalldocs
}
