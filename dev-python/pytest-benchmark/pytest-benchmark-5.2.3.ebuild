# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Pytest fixture for benchmarking Python code"
HOMEPAGE="https://pytest-benchmark.readthedocs.io/ https://github.com/ionelmc/pytest-benchmark"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pytest-8.1[${PYTHON_USEDEP}]
	dev-python/py-cpuinfo[${PYTHON_USEDEP}]
"
BDEPEND="
	>=dev-python/setuptools-80[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( "${PN}" )
distutils_enable_tests pytest

python_test() {
	# Run upstream core tests. Optional integration tests require unpackaged
	# aspectlib, hunter and pygaljs.
	epytest -o addopts= \
		tests/test_normal.py \
		tests/test_pedantic.py \
		tests/test_stats.py
}
