# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..13} )
PYPI_NO_NORMALIZE=true
inherit distutils-r1 pypi

DESCRIPTION="YAML loader and dumper for PyYAML allowing to keep keys order"
HOMEPAGE="https://github.com/fmenabe/python-yamlordereddictloader"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/pyyaml[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
