# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"
LLVM_COMPAT=( 21 )

inherit cargo desktop llvm-r2 xdg

# To create bundled dependencies:
# 1. Rust:
# rust_stage=$(mktemp -d /tmp/codexia-rust.XXXXXX)
# mkdir -p "${rust_stage}/cargo_home"
# cd "${src}"
# CARGO_HOME="${rust_stage}/cargo_home" cargo vendor --locked --versioned-dirs \
#     "${rust_stage}/cargo_home/gentoo" >/dev/null
# XZ_OPT='-T0 -9' tar -C "${rust_stage}" -cJf "${dist}/codexia-0.42.2-crates.tar.xz" \
#     cargo_home/gentoo cargo_home/git
# 2. node modules:
# bun install --frozen-lockfile
# XZ_OPT='-T0 -9' tar -C "${src}/.." \
#     -cJf "${dist}/codexia-0.42.2-node_modules.tar.xz" \
#    codexia-0.42.2/node_modules

DESCRIPTION="Agent workstation for Codex CLI and Claude Code"
HOMEPAGE="https://github.com/milisp/codexia"
SRC_URI="
	https://github.com/milisp/${PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/pva/pva.github.io/releases/download/v1.0/${P}-crates.tar.xz
	https://github.com/pva/pva.github.io/releases/download/v1.0/${P}-node_modules.tar.xz
"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/libayatana-appindicator
	dev-libs/openssl:0=
	media-libs/alsa-lib
	net-libs/webkit-gtk:4.1
	net-misc/curl
	sys-apps/dbus
	x11-libs/gtk+:3
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	dev-build/cmake
	dev-lang/bun-bin
	virtual/pkgconfig
	$(llvm_gen_dep 'llvm-core/clang:${LLVM_SLOT}')
"

pkg_setup() {
	llvm-r2_pkg_setup
	rust_pkg_setup
}

src_configure() {
	local myfeatures=(
		tauri/custom-protocol
	)

	cargo_src_configure --package "${PN}" --bin "${PN}" --locked
}

src_compile() {
	# bindgen-0.69.5 generates opaque whisper.cpp structs with libclang-22.
	local llvm_prefix=$(get_llvm_prefix -b)
	export CLANG_PATH="${llvm_prefix}/bin/clang"
	export LIBCLANG_PATH="${llvm_prefix}/$(get_libdir)"
	export LLVM_CONFIG_PATH="${llvm_prefix}/bin/llvm-config"

	bun run build || die
	cargo_src_compile --package "${PN}" --bin "${PN}"
}

src_install() {
	dobin "$(cargo_target_dir)/${PN}"

	newicon -s 32 src-tauri/icons/32x32.png "${PN}.png"
	newicon -s 128 src-tauri/icons/128x128.png "${PN}.png"
	newicon -s 256 src-tauri/icons/128x128@2x.png "${PN}.png"
	make_desktop_entry "${PN}" "Codexia" "${PN}" "Development;Utility;"

	einstalldocs
}
