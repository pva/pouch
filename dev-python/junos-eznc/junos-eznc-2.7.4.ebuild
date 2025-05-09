# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..13} )
PYPI_NO_NORMALIZE=true
inherit distutils-r1 pypi

DESCRIPTION="Junos 'EZ' automation for non-programmers"
HOMEPAGE="https://github.com/Juniper/py-junos-eznc"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-python/lxml-3.2.4[${PYTHON_USEDEP}]
	>=dev-python/ncclient-0.6.15[${PYTHON_USEDEP}]
	>=dev-python/scp-0.7.0[${PYTHON_USEDEP}]
	>=dev-python/jinja2-2.7.1[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
	>=dev-python/paramiko-3.5.0[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/pyserial[${PYTHON_USEDEP}]
	dev-python/yamlordereddictloader[${PYTHON_USEDEP}]
	dev-python/pyparsing[${PYTHON_USEDEP}]
	dev-python/transitions[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"

python_prepare_all() {
	# use implicit namespace
	sed -i -e '/namespace_packages/d' setup.py || die
	distutils-r1_python_prepare_all
}
