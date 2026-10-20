# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="File-like interface for split multi-volume files"
HOMEPAGE="https://github.com/miurahr/multivolume https://pypi.org/project/multivolumefile/"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( hypothesis )
distutils_enable_tests pytest
