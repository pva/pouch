# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 git-r3

DESCRIPTION="MIPI cameras through the IPU6 on Alder/Raptor/Meteor/Lunar Lake platforms"
HOMEPAGE="https://github.com/intel/ipu6-drivers"
EGIT_REPO_URI="https://github.com/intel/ipu6-drivers.git"

LICENSE="GPL-2"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

RDEPEND="sys-kernel/usbio-drivers"
DEPEND="${RDEPEND}"

# Intel Vision Sensing Controller(IVSC)
CONFIG_CHECK="~SPI_LJCA ~GPIO_LJCA ~I2C_LJCA ~INTEL_MEI_VSC"
CONFIG_CHECK+=" ~MFD_LJCA ~I2C_LJCA ~SPI_LJCA ~GPIO_LJCA"
CONFIG_CHECK+=" ~INTEL_VSC ~INTEL_VSC_CSI ~INTEL_VSC_ACE ~INTEL_VSC_PSE"

src_compile() {
	local modlist=( drivers/media/{i2c/{ov02c10,ov02e10,ov01a10,hm11b1,hi556,hm2172,ov01a1s,hm2170,ov05c10,ov2740},pci/intel/ipu6/psys/intel-ipu6-psys}=ipu6 )
	local modargs=( KERNEL_SRC="${KV_OUT_DIR}" KERNELRELEASE="${KV_FULL}" EXTRA_CFLAGS="-I${KV_OUT_DIR}/drivers/media/pci/intel/ipu6/" )
	linux-mod-r1_src_compile
}
