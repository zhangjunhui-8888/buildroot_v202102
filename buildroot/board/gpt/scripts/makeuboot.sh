#!/bin/sh
set -x

cur_data=`date "+%F"`

SRC_UBOOT_NAME=u-boot.bin
DST_UBOOT_NAME=u-boot.img
FLASH_UBOOT_NAME=uboot_gp8300_$cur_data.bin
SPL_UBOOT_NAME=u-boot-spl.bin

IMG_DIR=$PWD/output/images
SRPT_DIR=$PWD/board/gpt/scripts

#make -j8
#cd output/images/
#./tools/mkimage [-x] -A arch -O os -T type -C comp -a addr -e ep -n name -d data_file[:data_file...] image
$SRPT_DIR/mkimage  -A gpt -O u-boot -C none  -a 0xc000000 -e 0xc000000 -d $IMG_DIR/$SRC_UBOOT_NAME  $IMG_DIR/$DST_UBOOT_NAME
dd if=$IMG_DIR/u-boot-spl.bin of=$IMG_DIR/spl-out.bin bs=128K conv=sync
 
cat $IMG_DIR/spl-out.bin $IMG_DIR/u-boot.img > $IMG_DIR/out.bin 

dd if=$IMG_DIR/out.bin of=$IMG_DIR/$FLASH_UBOOT_NAME bs=1M conv=sync

if [ -f "$IMG_DIR/../build/uboot-origin_master/monitor.bin.ihex" ];then
	`cat $IMG_DIR/../build/uboot-origin_master/monitor.bin.ihex >> $IMG_DIR/$FLASH_UBOOT_NAME`
fi

rm $IMG_DIR/spl-out.bin $IMG_DIR/out.bin 
