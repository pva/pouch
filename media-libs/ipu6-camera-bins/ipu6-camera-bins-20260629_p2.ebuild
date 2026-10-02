# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV=${PV/_p/_}
DESCRIPTION="Intel IPU6 proprietary image processing libraries and headers"
HOMEPAGE="https://github.com/intel/ipu6-camera-bins"
SRC_URI="https://github.com/intel/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="Apache-2.0 Intel-ipu6"
SLOT="0/${PV}"
KEYWORDS="~amd64"
# Upstream permits unmodified redistribution; we remove embedded RUNPATHs.
RESTRICT="bindist strip"

RDEPEND="
	dev-libs/expat
	>=sys-libs/glibc-2.38
	virtual/zlib
"
BDEPEND="app-admin/chrpath"
QA_PREBUILT="usr/lib*/*"

src_prepare() {
	default

	# Remove paths to Intel's build host (including a current-directory entry).
	local lib
	for lib in lib/*.so.*; do
		if chrpath -l "${lib}" >/dev/null 2>&1; then
			chrpath -d "${lib}" || die
		fi
	done

	# Upstream ships pkg-config files for a non-multilib /usr/lib layout.
	sed -i \
		-e "s|^prefix=.*|prefix=${EPREFIX}/usr|" \
		-e "s|^libdir=.*|libdir=\${prefix}/$(get_libdir)|" \
		lib/pkgconfig/*.pc || die
}

src_install() {
	# Firmware is supplied by sys-kernel/linux-firmware, avoiding file collisions.
	insinto /usr/include
	doins -r include/.

	dolib.so lib/*.so.*
	# These archives have no shared-library counterparts and are required by HAL.
	dolib.a lib/*.a

	local lib
	for lib in lib/*.so.0; do
		lib=${lib##*/}
		dosym "${lib}" "/usr/$(get_libdir)/${lib%.0}"
	done

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins lib/pkgconfig/*.pc
	dodoc README.md LICENSE
}
