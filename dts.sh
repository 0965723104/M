#!/bin/bash
DTS=arch/arm/boot/dts
# GCC
export CROSS_COMPILE=/home/minhka98/arm-eabi-4.8/bin/arm-eabi-
### MANUAL DT.IMG GENERATION ###
echo -n "Build dt.img...."
make exynos3475-j2lte_sea_xsa_00.dtb exynos3475-j2lte_sea_xsa_01.dtb exynos3475-j2lte_sea_xsa_02.dtb exynos3475-j2lte_sea_xsa_03.dtb 
./tools/dtbtool -o ./boot.img-dtb -v -s 2048 -p ./scripts/dtc/ $DTS/
# get rid of the temps in dts directory
rm -rf $DTS/.*.tmp
rm -rf $DTS/.*.cmd
rm -rf $DTS/*.dtb

# Calculate DTS size for all images and display on terminal output
du -k "./boot.img-dtb" | cut -f1 >sizT
sizT=$(head -n 1 sizT)
rm -rf sizT
echo "$sizT Kb"

