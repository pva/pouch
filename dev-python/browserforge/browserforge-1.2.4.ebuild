# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Browser header and fingerprint generator"
HOMEPAGE="https://github.com/daijro/browserforge https://pypi.org/project/browserforge/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	>=dev-python/apify-fingerprint-datapoints-0.15.0[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
"
