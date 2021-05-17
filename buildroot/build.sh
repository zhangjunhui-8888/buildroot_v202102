#!/bin/bash
KO_DIR=$PWD/../user_ko
KERNEL_DIR=$PWD/output/build/linux-custom

make ARCH=gpt clean
make ARCH=gpt

cd $KERNEL_DIR
find -name *.ko > ko.txt
count=1
cat ko.txt | while read line
do 
	cp $line $KO_DIR
	count=$[ $count + 1 ]
done

rm ko.txt
echo "==========build success!============"
