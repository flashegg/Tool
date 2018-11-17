#!/bin/bash
<<!
 **********************************************************
 * Author        : JiZiWen
 * Email         : 1292144771@qq.com
 * Last modified : 2018-11-16 21:00
 * Filename      : Disk Expansion
 * Description   : 磁盘跟分区扩容
 **********************************************************
!

read -p "输入新添加的盘符：" DRIVE

#fdisk对新添加的磁盘进行分区
echo "n
p



t
8e
w" | fdisk /dev/$DRIVE 1>/dev/null 2>&1

#重新定义变量
DRIVE2=${DRIVE}'1'

#创建物理卷
pvcreate /dev/$DRIVE2 1>/dev/null 2>&1

#获取VG Name
VGNAME=`vgdisplay | awk 'NR==2{print $3}'`

#将新增加的分区加入到根目录分区
vgextend $VGNAME /dev/$DRIVE2 1>/dev/null 2>&1

#获取根分区盘符
MB=`df -h|awk 'NR==2{print $1}'`

#进行卷扩容
lvextend -l +100%FREE $MB 1>/dev/null 2>&1

#调整卷分区大小
xfs_growfs $MB 1>/dev/null 2>&1

#查看扩容后的空间大小
DISK=`df -h|awk 'NR==2{print $4}'`
echo "扩容成功！目前磁盘跟分区容量："$DISK
