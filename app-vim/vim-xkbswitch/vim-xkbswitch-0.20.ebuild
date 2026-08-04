# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit vim-plugin

DESCRIPTION="easily switch current keyboard layout when entering and leaving Insert mode"
HOMEPAGE="https://www.vim.org/scripts/script.php?script_id=4503 https://github.com/lyokha/vim-xkbswitch"
SRC_URI="http://www.vim.org/scripts/download_script.php?src_id=27984
	-> ${P}.tgz"

S="${WORKDIR}"

LICENSE="MIT"
KEYWORDS="~amd64"
RDEPEND="x11-apps/xkb-switch"
