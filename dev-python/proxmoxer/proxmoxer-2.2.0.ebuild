# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..13} )
inherit distutils-r1 optfeature

DESCRIPTION="Python Wrapper for the Proxmox 2.x API (HTTP and SSH)"
HOMEPAGE="https://proxmoxer.github.io/docs/2.0/ https://pypi.org/project/proxmoxer/"
SRC_URI="https://github.com/proxmoxer/proxmoxer/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="test"
RESTRICT="!test? ( test )"

DOCS="README.rst"

RDEPEND="dev-python/requests[${PYTHON_USEDEP}]"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/responses[${PYTHON_USEDEP}]
		dev-python/openssh-wrapper[${PYTHON_USEDEP}]
	)"

distutils_enable_tests pytest

pkg_postinst() {
	optfeature_header "${PN} functionality can be extended by installing the following packages:"
	optfeature "Use openssh commands as the backend" dev-python/openssh-wrapper
	optfeature "Use ssh as the backend using paramiko" dev-python/paramiko
}
