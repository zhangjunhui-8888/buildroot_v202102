#!/bin/bash
KO_DIR=$PWD/../KO
KERNEL_DIR=$PWD/output/build/linux-custom

make ARCH=gpt clean
make ARCH=gpt
echo "========== build success! ============"

echo "========== Move KO file =========="
cd $KERNEL_DIR
find -name *.ko > ko.txt
cat ko.txt | while read line
do 
	cp $line $KO_DIR
done

rm ko.txt
echo "========== Move  KO file end! =========="
