#!/bin/bash
export CROSS_COMPILE=/home/minhka98/kernel/toolchain/arm-eabi-4.8/bin/arm-eabi-
export ARCH=arm
# Cleanup
make clean && make mrproper
make j2lte_MM_defconfig
make -j8
