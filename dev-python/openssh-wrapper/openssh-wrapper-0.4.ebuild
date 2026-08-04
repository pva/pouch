# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=true
inherit distutils-r1 pypi

DESCRIPTION="Simple wrapper around OpenSSH ssh command-line utility"
HOMEPAGE="https://pypi.org/project/openssh-wrapper/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
RESTRICT="test"

DOCS="README.rst"

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
