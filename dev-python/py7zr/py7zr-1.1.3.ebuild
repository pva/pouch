# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Python library for reading and writing 7z archives"
HOMEPAGE="https://py7zr.readthedocs.io/ https://github.com/miurahr/py7zr"
# PyPI source distributions omit the test suite.
SRC_URI="https://github.com/miurahr/py7zr/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=app-arch/brotli-1.2.0[python,${PYTHON_USEDEP}]
	>=dev-python/inflate64-1.0.4[${PYTHON_USEDEP}]
	>=dev-python/multivolumefile-0.2.3[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	>=dev-python/pybcj-1.0.6[${PYTHON_USEDEP}]
	>=dev-python/pycryptodome-3.20.0[${PYTHON_USEDEP}]
	>=dev-python/pyppmd-1.3.1[${PYTHON_USEDEP}]
	dev-python/texttable[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/backports-zstd-1.0.0[${PYTHON_USEDEP}]
	' python3_{12..13})
"
BDEPEND="
	>=dev-python/setuptools-80[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-9.2.0[${PYTHON_USEDEP}]
	test? (
		dev-python/py-cpuinfo[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
	)
"

PATCHES=( "${FILESDIR}/${P}-pycryptodome.patch" )

EPYTEST_PLUGINS=(
	pytest-benchmark
	pytest-httpserver
	pytest-remotedata
	pytest-timeout
)
distutils_enable_tests pytest

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

python_test() {
	# Run benchmark cases once, without timing and calibration loops.
	# Skip remote tests and reject unexpected internet access; allow localhost.
	# Some tests leave cwd inside tmp_path; retain directories until the run ends.
	epytest --benchmark-disable --remote-data=none \
		-o remote_data_strict=true \
		-o tmp_path_retention_policy=all
}
