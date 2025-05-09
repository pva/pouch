# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..13} )
PYPI_NO_NORMALIZE=true
inherit distutils-r1 pypi

DESCRIPTION="scp module for paramiko"
HOMEPAGE="https://github.com/jbardin/scp.py"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-python/paramiko-1.15.2[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
