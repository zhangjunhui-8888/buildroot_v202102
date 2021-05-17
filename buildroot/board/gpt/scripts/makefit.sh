#!/bin/sh
set -x

IMG_DIR=$PWD/output/images
SRPT_DIR=$PWD/board/gpt/scripts

DTS_NAME=`cat $PWD/.config |grep -w BR2_LINUX_KERNEL_INTREE_DTS_NAME | awk -F '"' '{print $2}'`

cp $IMG_DIR/$DTS_NAME.dtb $IMG_DIR/fdt.dtb

$SRPT_DIR/mkimage -f $SRPT_DIR/kernel_fdt.its $IMG_DIR/$DTS_NAME.itb

$SRPT_DIR/mkimage -l $IMG_DIR/$DTS_NAME.itb
