# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Pytest plugin for controlling access to remote data"
HOMEPAGE="https://github.com/astropy/pytest-remotedata https://pypi.org/project/pytest-remotedata/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/pytest-4.6[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( "${PN}" )
EPYTEST_PLUGIN_LOAD_VIA_ENV=1
EPYTEST_DESELECT=(
	# These tests require successful internet access from a subprocess.
	tests/test_strict_check.py::test_default_behavior
	'tests/test_strict_check.py::test_strict_with_decorator[any]'
)
distutils_enable_tests pytest
