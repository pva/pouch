# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="PPMd compression and decompression library for Python"
HOMEPAGE="https://pyppmd.readthedocs.io/ https://github.com/miurahr/pyppmd"

LICENSE="LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	>=dev-python/setuptools-scm-6.4.2[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( hypothesis pytest-benchmark pytest-timeout )
distutils_enable_tests pytest

python_test() {
	# Run benchmark cases once, without timing and calibration loops.
	epytest --benchmark-disable
}
