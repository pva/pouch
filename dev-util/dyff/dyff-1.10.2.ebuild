# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

DESCRIPTION="diff tool for YAML files, and sometimes JSON"
HOMEPAGE="https://github.com/homeport/dyff"
SRC_URI="https://github.com/homeport/dyff/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/pva/pva.github.io/releases/download/v1.0/${P}-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

src_compile() {
	ego build -o ${PN} cmd/${PN}/main.go
}

src_install() {
	dobin ${PN}
	einstalldocs
}
