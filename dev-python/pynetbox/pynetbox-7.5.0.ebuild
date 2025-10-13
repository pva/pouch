# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..13} )
PYPI_NO_NORMALIZE=true
inherit distutils-r1 pypi

DESCRIPTION="Python API client library for NetBox"
HOMEPAGE="https://github.com/netbox-community/pynetbox"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"
