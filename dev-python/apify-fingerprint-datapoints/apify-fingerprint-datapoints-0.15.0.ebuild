# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Browser fingerprint datasets collected by Apify"
HOMEPAGE="https://github.com/apify/fingerprint-suite https://pypi.org/project/apify-fingerprint-datapoints/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

DOCS=( apify_fingerprint_datapoints/README.md )
