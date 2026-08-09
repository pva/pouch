# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 systemd

DESCRIPTION="Simple and generic Prometheus exporter for MQTT"
HOMEPAGE="https://github.com/kpetremann/mqtt-exporter"
SRC_URI="https://github.com/kpetremann/mqtt-exporter/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	acct-user/mqtt-exporter
	$(python_gen_cond_dep '
		>=dev-python/paho-mqtt-2.1.0[${PYTHON_USEDEP}]
		>=dev-python/prometheus-client-0.24.1[${PYTHON_USEDEP}]
	')
"

PATCHES=( "${FILESDIR}"/${P}-pyproject.patch )

EPYTEST_PLUGINS=( pytest-asyncio pytest-mock )
distutils_enable_tests pytest

src_install() {
	distutils-r1_src_install

	keepdir /var/log/${PN}
	fowners mqtt-exporter:mqtt-exporter /var/log/${PN}

	systemd_dounit "${FILESDIR}"/${PN}.service
	systemd_install_serviced "${FILESDIR}"/${PN}.service.conf
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
}
