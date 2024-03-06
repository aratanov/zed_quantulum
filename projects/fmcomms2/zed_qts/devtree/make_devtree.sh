#!/bin/sh

BUILDDIR=./build
CURRENTDIR=$(pwd)

xsct -eval "source xsct_devtree.tcl; build_dts ${BUILDDIR}"

gcc -I . -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -o ${BUILDDIR}/system-top.dts.tmp ${BUILDDIR}/system-top.dts
dtc -@ -I dts -O dtb -o ${BUILDDIR}/system.dtb ${BUILDDIR}/system-top.dts.tmp
dtc -I dtb -O dts -o ${BUILDDIR}/devtree_decomp.dts ${BUILDDIR}/system.dtb

mv ./fsbl/executable.elf ./fsbl/fsbl.elf
mv ./fsbl/u-boot.elf ./fsbl/u-boot_zynq_zed.elf

cat << EOF > ./bootgen_zed.bif
the_ROM_image:
{
  [bootloader] ./fsbl/fsbl.elf
  ../fmcomms2_zed.runs/impl_1/system_top.bit
  ./fsbl/u-boot_zynq_zed.elf
}
EOF

bootgen -arch zynq -image bootgen_zed.bif -o BOOT.BIN -w

exit 0
