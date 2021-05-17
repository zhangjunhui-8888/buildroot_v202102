#########################################################################
# File Name: mmcInit.sh
# Author: yangyang.liu
# mail: yangyang.liu@hxgpt.com
# Created Time: 2019年09月20日 星期五 14时44分26秒
#########################################################################
#!/bin/bash

print_log(){
	echo "$1" >>/tmp/mmcDisk.log
	#echo "$1" 
}

##################################
#
#
#return: 1,success 0,failed
############################
getConfOption() {
	EMMC1_BASE_NAME="variableEmmc1BaseName"
	EMMC2_BASE_NAME="variableEmmc2BaseName"
	EMMC3_BASE_NAME="variableEmmc3BaseName"
	EMMC_BOOT_BASE_NAME="variableBootBaseName"
	print_log "----------------"

	if [ -f $confFile ]; then
		confForceFormat=`cat $confFile | awk '/FORCE_FORMAT/ {print $3}'`
		confEmmcSize=`cat $confFile | awk '/EMMC_SIZE/ {print $3}'`
		#mmc_NAME          = sdb
		confPartitionCountMax=`cat $confFile | awk '/PARTITION_COUNT_MAX/ {print $3}'`
		confPartitionCount=`cat $confFile | awk '/PARTITION_COUNT_ALL/ {print $3}'`
		confEmmcMountDir1=`cat $confFile | awk '/EMMC_MOUNT_DIR_1/ {print $3}'`
		confEmmcMountDir2=`cat $confFile | awk '/EMMC_MOUNT_DIR_2/ {print $3}'`
		confEmmcMountDir3=`cat $confFile | awk '/EMMC_MOUNT_DIR_3/ {print $3}'`
		confEmmcMountDir4=`cat $confFile | awk '/EMMC_MOUNT_DIR_4/ {print $3}'`
		confPartitionSize1=`cat $confFile | awk '/PARTITION_SIZE_1/ {print $3}'`
		confPartitionSize2=`cat $confFile | awk '/PARTITION_SIZE_2/ {print $3}'`
		confPartitionSize3=`cat $confFile | awk '/PARTITION_SIZE_3/ {print $3}'`
		confPartitionSize4=`cat $confFile | awk '/PARTITION_SIZE_4/ {print $3}'`
		confPartitionStartSector=`cat $confFile | awk '/PARTITION_START_SECTOR/ {print $3}'`

		confBootDirCount=`cat $confFile | awk '/EMMC_BOOT_DIR_COUNT/ {print $3}'`
		if [ $confBootDirCount -ge 1 ];	then
			tempCount=1
			while [ $tempCount -le $confBootDirCount ]
			do
				tempCCount=`expr $tempCount + 2`
				tempName="$""$tempCCount"
				#print_log "tempName=$tempName"
				tempDir=`cat $confFile | awk '/EMMC_BOOT_DIR_NAME/ { print '$tempName' }'`
				#print_log "tempDir=$tempDir"
				eval $EMMC_BOOT_BASE_NAME$tempCount=$tempDir
				#print_log variableBootBaseName$tempCount
				#$EMMC_BOOT_BASE_NAME$tempCount=$tempDir
				tempCount=`expr $tempCount + 1`
			done
		fi
		return 1
	else
		print_log " read $confFile is error"
		return 0
	fi

}



##################################
#
#
#return: 1,success 0,failed
############################
getDiskInfo() {
	if [ $PC -eq 0 ]; then
		deviceName=`fdisk -l | awk '$2~/dev\/mmcblk[0-9]:/ {print $2}' | awk -F: '{print $1}'`
		#deviceName="/dev/mmcblk0"
		diskSize=`fdisk -l $deviceName | awk '$4~/GiB/ {print $3}' | awk -F. '{print $1}'`
		sectorsAll=`fdisk -l $deviceName | awk '$8~/sectors/ {print $7}'`
		cylindersAll=`fdisk -l $deviceName | awk '$6~/cylinders/ {print $5}'`
		headsAll=`fdisk -l $deviceName | awk '$2~/heads/ {print $1}'`
		perSectorSize=`fdisk -l $deviceName | awk '$3~/logical/ {print $4}'`
	else
		deviceName="/dev/mmcblk0"
		diskSize=`fdisk -l /dev/mmcblk0 | awk '$3~/GiB/ {print $2}' | awk -F： '{print $2}'`
		sectorsAll=`fdisk -l $deviceName |grep Disk |awk -F ， '{print $3}' | awk -F " " '{print $1}'`
		cylindersAll=`fdisk -l $deviceName | awk '$6~/cylinders/ {print $5}'`
		headsAll=`fdisk -l $deviceName | awk '$2~/heads/ {print $1}'`
		perSectorSize=`fdisk -l $deviceName | awk '$1~/单元/ {print $5}'`
	fi
	print_log "deviceName=$deviceName  diskSize=$diskSize sectorsAll=$sectorsAll cylindersAll=$cylindersAll headsAll=$headsAll perSectorSize=$perSectorSize"

	if [ -z "$deviceName" ]; then
		return 0
	fi

	#if [ $diskSize -lt 7 ]; then
	#	return 0
	#fi

	if [ -z "$sectorsAll" ]; then
		return 0
	fi

	#if [ -z "$cylindersAll" ]; then
	#	return 0
	#fi

	#if [ -z "$headsAll" ]; then
	#	return 0
	#fi

	if [ -z "$perSectorSize" ]; then
		return 0
	fi


	return 1
	#print_log "1"

}

##################################
#
#
#return: 1,success 0,failed
############################
CalculationPartationSectorInfo(){

	if [ $confPartitionCount -gt $confPartitionCountMax ]
	then
		return 0
	fi

	calcPartition1SectorCount=`expr $confPartitionSize1 \* 1024 \* 1024  / $perSectorSize`
	#print_log "calcPartition1SectorCount=$calcPartition1SectorCount"
	calcPartition2SectorCount=`expr $confPartitionSize2 \* 1024 \* 1024  / $perSectorSize`
	#print_log "calcPartition2SectorCount=$calcPartition2SectorCount"
	calcPartition3SectorCount=`expr $confPartitionSize3 \* 1024 \* 1024  / $perSectorSize`
	#print_log "calcPartition3SectorCount=$calcPartition3SectorCount"
	calcPartition4SectorCount=`expr $confPartitionSize4 \* 1024 \* 1024  / $perSectorSize`
	#print_log "calcPartition4SectorCount=$calcPartition4SectorCount"

	calcPart1sectorStart=$confPartitionStartSector
	#print_log "calcPart1sectorStart=$calcPart1sectorStart"
	calcPart1sectorEnd=`expr $calcPart1sectorStart + $calcPartition1SectorCount - 1`
	#print_log "calcPart1sectorEnd=$calcPart1sectorEnd"
	calcPart2sectorStart=`expr $calcPart1sectorEnd + 1`
	#print_log "calcPart2sectorStart=$calcPart2sectorStart"
	calcPart2sectorEnd=`expr $calcPart2sectorStart + $calcPartition2SectorCount - 1`
	#print_log "calcPart2sectorEnd=$calcPart2sectorEnd"
	calcPart3sectorStart=`expr $calcPart2sectorEnd + 1`
	#print_log "calcPart3sectorStart=$calcPart3sectorStart"
	calcPart3sectorEnd=`expr $calcPart3sectorStart + $calcPartition3SectorCount - 1`
	#print_log "calcPart3sectorEnd=$calcPart3sectorEnd"
	calcPart4sectorStart=`expr $calcPart3sectorEnd + 1`
	#print_log "calcPart4sectorStart=$calcPart4sectorStart"
	calcPart4sectorEnd=`expr $calcPart4sectorStart + $calcPartition4SectorCount - 1`
	if [ $calcPart4sectorEnd -gt $sectorsAll ]; then
	    calcPart4sectorEnd=`expr $sectorsAll - 1`
	fi
	#print_log "calcPart4sectorEnd=$calcPart4sectorEnd"

	#debug message.....
	if [ $DEBUG -eq 1 ]; then
		print_log ">>>>>>>>>>>>>>>>>>>>>>debug start"
		print_log "confForceFormat=$confForceFormat confEmmcSize=$confEmmcSize confPartitionCountMax=$confPartitionCountMax \
confPartitionCount=$confPartitionCount confEmmcMountDir1=$confEmmcMountDir1 confEmmcMountDir2=$confEmmcMountDir2 \
confEmmcMountDir3=$confEmmcMountDir3 confEmmcMountDir4=$confEmmcMountDir4 confPartitionSize1=$confPartitionSize1 \
confPartitionSize2=$confPartitionSize2 confPartitionSize3=$confPartitionSize3 confPartitionStartSector=$confPartitionStartSector confEmmc1DirCount=$confEmmc1DirCount"
		print_log "deviceName=$deviceName  diskSize=$diskSize sectorsAll=$sectorsAll cylindersAll=$cylindersAll headsAll=$headsAll perSectorSize=$perSectorSize"
		print_log "calcPartition1SectorCount=$calcPartition1SectorCount calcPartition2SectorCount=$calcPartition2SectorCount \
calcPartition3SectorCount=$calcPartition3SectorCount calcPartition4SectorCount=$calcPartition4SectorCount"
		print_log "calcPart1sectorStart=$calcPart1sectorStart calcPart1sectorEnd=$calcPart1sectorEnd "
		print_log "calcPart2sectorStart=$calcPart2sectorStart calcPart2sectorEnd=$calcPart2sectorEnd "
		print_log "calcPart3sectorStart=$calcPart3sectorStart calcPart3sectorEnd=$calcPart3sectorEnd "
		print_log "calcPart4sectorStart=$calcPart4sectorStart calcPart4sectorEnd=$calcPart4sectorEnd "
	fi


	return 1
}


fdiskCreate1P() {
	fdisk $deviceName<<EOF
	n
	p
	1
	$calcPart1sectorStart
	$calcPart1sectorEnd
	w
EOF

}

fdiskCreate2P() {
	fdisk $deviceName<<EOF
	n
	p
	1
	$calcPart1sectorStart
	$calcPart1sectorEnd
	n
	p
	2
	$calcPart2sectorStart
	$calcPart2sectorEnd
	w
EOF

}

fdiskCreate3P() {
	fdisk $deviceName<<EOF
	n
	p
	1
	$calcPart1sectorStart
	$calcPart1sectorEnd
	n
	p
	2
	$calcPart2sectorStart
	$calcPart2sectorEnd
	n
	p
	3
	$calcPart3sectorStart
	$calcPart3sectorEnd
	w
EOF

}

fdiskCreate4P() {
	fdisk $deviceName<<EOF
	n
	p
	1
	$calcPart1sectorStart
	$calcPart1sectorEnd

	n
	p
	2
	$calcPart2sectorStart
	$calcPart2sectorEnd

	n
	p
	3
	$calcPart3sectorStart
	$calcPart3sectorEnd

	n
	p
	4
	$calcPart4sectorStart
	$calcPart4sectorEnd

	w
EOF

}


##################################
#
#
#
############################
fdiskCreate(){
	case $confPartitionCount in
	1)
		if [ $calcPart1sectorEnd -gt $sectorsAll ]; then
			calcPart1sectorEnd=`expr $sectorsAll - 1`
		fi 
		fdiskCreate1P 
	;;
	2) 
		if [ $calcPart2sectorEnd -gt $sectorsAll ]; then
			calcPart2sectorEnd=`expr $sectorsAll - 1`
		fi 
		fdiskCreate2P 
	;;
	3) 
		if [ $calcPart3sectorEnd -gt $sectorsAll ]; then
			calcPart3sectorEnd=`expr $sectorsAll - 1`
		fi 
		fdiskCreate3P 
	;;
	4) 
		if [ $calcPart4sectorEnd -gt $sectorsAll ]; then
			calcPart4sectorEnd=`expr $sectorsAll - 1`
		fi 
		fdiskCreate4P 
	;;
		*) print_log " confPartitionCount=$confPartitionCount is error  ./EmmcDiskInit create|del|info" ;;
	esac
	sync
	sleep 1
}


##################################################
#
###################################################
fdiskDelOne() {
	fdisk $deviceName<<EOF
	d
	w
EOF
}

fdiskDelTwo() {
	fdisk $deviceName<<EOF
	d
	1
	d
	w
EOF
}

fdiskDelThree() {
	fdisk $deviceName<<EOF
	d
	1
	d
	2
	d
	w
EOF
}

fdiskDelFour() {
	fdisk $deviceName<<EOF
	d
	1
	d
	2
	d
	3
	d
	w
EOF
}

fdiskDelFive() {
	fdisk $deviceName<<EOF
	d
	1
	d
	2
	d
	3
	d
	4
	d
	w
EOF
}

##################################
#
#
#
############################
fdiskDel() {
	partitionCount=`fdisk -l $deviceName | awk '{if($1~/dev\/mmcblk[0-9]/) print $1}' | wc -l`
		umount -Avf ${deviceName}*

	if [ $partitionCount -lt 1 ]; then
		print_log "disk is empty"
		return 0
	fi
		
	case $partitionCount in
		1) fdiskDelOne ;;
		2) fdiskDelTwo ;;
		3) fdiskDelThree ;;
		4) fdiskDelFour ;;
		*) print_log " partition count $partitionCount > 4"
	esac

	# destroy the partition table
	dd if=/dev/zero of=${deviceName} bs=512 count=2
	sync
	partprobe

	return 1

}


##################################
#
#
#
############################
mkfsExt4(){
	local tempCount=1
	local mmcMountDir="/mnt"

	fdisk -l $deviceName | awk '{if($1~/dev\/mmcblk[0-9]/) print $1}' | while read line
	do
		print_log $line 
		if [ ! -d $mmcMountDir ]; then
			mkdir -p $mmcMountDir
		fi
			
		mountPoint=`lsblk -Pp |grep $line |awk -F = '{print $8}' | sed 's/\"//g'`	
		if [ "$mountPoint" != '' ];then
			umount -Avf $mountPoint
		fi

		tune2fs -c 30 $line

		if [ $confForceFormat -ne 0 ]; then
			print_log "mkfsExt4 $line"
			mkfs.ext4 -F $line
			sync
		
		else

			mount $line $mmcMountDir
			if [ $? -ne 0 ]; then
				mount -t squashfs $line $mmcMountDir
				if [ $? -ne 0 ]; then
					print_log "mkfsExt4 $line"
					mkfs.ext4 -F $line
					sync
				else
					print_log "[SUCCESS]***** [$line] ***** disk can mount with squashfs, do not exec format!"
					umount -Avf $line
				fi
			else
				print_log "[SUCCESS]***** [$line] ***** disk can mount with ext4."
				umount -Avf $line

				blockCount=`tune2fs $line -l|grep "Block count"|awk -F ' ' '{print $3}'`
				blockSize=`tune2fs $line -l|grep "Block size"|awk -F ' ' '{print $3}'`
				fsSize=`expr $blockCount \* $blockSize`
				partSize=`fdisk -l $line |grep $line |awk -F ' ' '{print $5}'`

				#compare format size and part size.
				if [ $partSize -ne $fsSize ];then
					print_log "mkfsExt4 $line, because partSize $partSize not equal fsSize $fsSize, format it."
					mkfs.ext4 -F $line
					sync
				fi
			fi
		fi
	done
	sleep 1

	return 1

}

mkBootDir(){
    local tempCount=1
	if [ ! -d "$confEmmcMountDir1" ]; then
		mkdir -p $confEmmcMountDir1
	fi

    mount $deviceName"p1" $confEmmcMountDir1
    if [ $confBootDirCount -gt 1 ]; then
	while [ $tempCount -le $confBootDirCount ]
	do
		tempDir1=`eval print_log '$'$EMMC_BOOT_BASE_NAME$tempCount`
		tempDir=$confEmmcMountDir1$tempDir1
		#print_log "tempDir=$tempDir"
		if [ ! -d "$tempDir" ]; then
			print_log "mkdir $tempDir."
			mkdir -p $tempDir
		fi
		tempCount=`expr $tempCount + 1`
	done
    fi
    #umount -Avf $deviceName"p1"
}

fsckPart(){
	maxMountSet=30
	local mmcMountDir="/mnt"
	local rootType=`cat /etc/fstab |grep /dev/root |awk '{print $3}'`
 
	mountCount=`tune2fs /dev/mmcblk0p2 -l|grep "Mount count"|awk -F ' ' '{print $3}'`
        maxMountCount=`tune2fs /dev/mmcblk0p2 -l|grep "Maximum mount count"|awk -F ' ' '{print $4}'`

	fdisk -l $deviceName | awk '{if($1~/dev\/mmcblk[0-9]/) print $1}' | while read line
	do
		print_log "fsck $line"
		if [ ! -d $mmcMountDir ]; then
			mkdir -p $mmcMountDir
		fi
		
		
		if [ $maxMountCount -ne $maxMountSet ];then
			tune2fs -c $maxMountSet $line
		fi

		mountPoint=`lsblk -Pp |grep $line |awk -F = '{print $8}' | sed 's/\"//g'`

		if [ "$mountPoint" = "" ];then
			mount $line $mmcMountDir
			#e2fsck -v -n -f $line
			if [ "$?" -ne 0 ]; then
				mount -t squashfs $line $mmcMountDir
				if [ "$?" -ne 0 ]; then
					print_log "++++++++++++++ fsck $line lite ++++++++++"
					e2fsck -v -y $line >> /tmp/mmcDisk.log
					mount $line $mmcMountDir
					if [ "$?" -ne 0 ]; then
						print_log "++++++++++++ fsck $line hardly! ++++++++++++"
						e2fsck -y -v -f -c $line
					else
						umount -Avf $line
					fi
					sync
				else
					umount -Avf $line
				fi
			else
				print_log "fsck $line no error."
				umount -Avf $line
			fi

		elif [ "$mountPoint" = "/" ]; then
			if [ "$rootType" = "ext4" ]; then
				/bin/mount -o remount,ro /
				e2fsck -v -n -f $line >/dev/null
				if [ "$?" -ne 0 -o $mountCount -gt $maxMountCount ]; then
					print_log "++++++++++++++ fsck $line lite ++++++++++"
					e2fsck -y $line 
				fi
				#/bin/mount -o remount,rw /
			fi
			#remount /dev/boot with read only.
			/bin/mount -o remount,ro /
		else
			print_log "$line already  mounted $mountPoint."

			if [ $mountCount -gt $maxMountCount ]; then
				umount -Avf $line
				print_log "++++++++++++++ fsck $line lite ++++++++++"
				e2fsck -y $line 
				mount $line $mountPoint
			fi
		fi
	done
}



##################################
#
#  start!!!
#
############################
DEBUG=1
#1. judge argument.
if [ $# -ne 1 ]; then
	echo "usage: ./mmcInit.sh create|del|info"
	exit 0
elif [ $1 != "create" -a $1 != "del" -a $1 != "info" ]; then
	echo "usage: ./mmcInit.sh create|del|info"
	exit 0
fi

PC=1
if [ `uname -a |grep Polaris | wc -l` -eq 1 ]; then
    PC=0
else
    PC=1
fi

#2. include config file.
if [ $PC -eq 1 ]; then
	confFile=$PWD/mmcDisk.conf
else
	confFile=/etc/mmcDisk.conf
fi

#3. fuction check disk exit and read info
getDiskInfo
if [ $? -ne 1 ]; then
	exit 0
fi

#4. fuction read config file information.
getConfOption
if [ $? -ne 1 ]; then
	exit 0
fi

#5. fuction calculation sector info, must after function's getDiskInfo
CalculationPartationSectorInfo
if [  $? -ne 1 ]; then
	exit 0
fi

# main process program
case $1 in
	"create")
	partitionCount=`fdisk -l $deviceName | awk '{if($1~/dev\/mmcblk[0-9]/) print $1}' | wc -l`
	if [ $partitionCount -le 1 ]; then
		fdiskDel
		fdiskCreate
		mkfsExt4
		fsckPart
		mkBootDir
		#mountEmmc
	elif [ $partitionCount -eq $confPartitionCount ]; then
		print_log "The hard disk is ok."
		fsckPart
		#mkBootDir
		#mountEmmc		
	else
		print_log "The hard disk is damaged, please format it."
		if [ $confForceFormat -eq 1 ]
		then
			fdiskDel
			fdiskCreate
			mkfsExt4
		fi

		fsckPart
		#fdiskDel
	fi
	;;
	"del")  fdiskDel ;;
	"info") getDiskInfo ;;
	*) print_log " $1 is error  ./EmmcDiskInit create|del|info";;
esac

#mount all filesystem.
mount -a

exit 0
