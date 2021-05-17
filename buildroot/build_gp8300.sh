#!/bin/bash

set -e

SHELL_FILE=$(readlink -f $0)
BUILDROOT_ROOT=$(dirname $SHELL_FILE)
BUILD_DIR=$ROOTFS_ROOT/build
LOCAL_TOOLCHAIN_PATH=$(which gpt-gcc)
export gpt_ver=v6.5

sub_dir=${LOCAL_TOOLCHAIN_PATH%/*}
dir=${sub_dir%/*}
#cd $BUILD_DIR"/"$BUILDROOT_DIR
#sed -i "s#gpt_toolchain_path#$dir#g" ./configs/gpt_polaris_dvb_mini_tools_defconfig

make
echo "==========build success!============"
