# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 git-r3

DESCRIPTION="USBIO Extension drivers on Intel Alder/Raptor/Meteor/Lunar Lake platforms"
HOMEPAGE="https://github.com/intel/usbio-drivers"
EGIT_REPO_URI="https://github.com/intel/usbio-drivers.git"

LICENSE="GPL-2"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

src_compile() {
	local modlist=( {gpio-usbio,i2c-usbio,usbio}=usb/drivers )
	local modargs=( KERNEL_SRC="${KV_OUT_DIR}" KERNELRELEASE="${KV_FULL}" )
	linux-mod-r1_src_compile
}
