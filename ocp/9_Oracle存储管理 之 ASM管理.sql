asm
ASM 支持Oracle Real Application Clusters (RAC)

SQL> show parameter type

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
instance_type                        string      RDBMS
plsql_code_type                      string      INTERPRETED

rdbms 关系型数据
	instance+database
asm 用来管理存储
	instance
	external redundance
	normal redundance
	high redundance
	
ASM 的安装与配置
1) 检查内存 
服务器内存：最少1.5 GB
[root@oel ~]# grep MemTotal /proc/meminfo
MemTotal:      2075500 kB
2) 服务器交换分区 
服务器交换分区内存：建议1.5 倍内存大小
[root@oel ~]# grep SwapTotal /proc/meminfo
SwapTotal:     4128760 kB
3) 磁盘空间需求
/tmp 目录：1024MB
数据库软件：5-10GB，依赖于安装类型
Grid Infrastructure：5GB
文件系统：5GB 用来放置安装软件

4) 安装系统需求的安装包
binutils-2.17.50.0.6
compat-libstdc++-33-3.2.3
elfutils-libelf-0.125
elfutils-libelf-devel-0.125
elfutils-libelf-devel-static-0.125
gcc-4.1.2
gcc-c++-4.1.2
glibc-2.5-24
glibc-common-2.5
glibc-devel-2.5
glibc-headers-2.5
kernel-headers-2.6.18
ksh-20060214
libaio-0.3.106
libaio-devel-0.3.106
libgcc-4.1.2
libgomp-4.1.2
libstdc++-4.1.2
libstdc++-devel-4.1.2
make-3.81
sysstat-7.0.2
unixODBC-2.2.11
unixODBC-devel-2.2.11

在虚拟机中选中你的虚拟机，右键->settings->CD/DVD(IDE)->Use ISO Image file,勾选Connected,Connect at power on 
mount -o loop /dev/cdrom /mnt/
df -h
[root@oracle ~]# cat /etc/yum.repos.d/server.repo
[server]
name=oel5.4
baseurl=file:///mnt/Server
gpgcheck=0
[root@oel ~]# cat /opt/yum.sh 
yum install binutils* -y
yum install compat* -y
yum install elfutils* -y
yum install gcc* -y
yum install glibc* -y
yum install kernel* -y
yum install ksh* -y
yum install libaio* -y
yum install libgcc* -y
yum install libgomp* y
yum install libgomp* -y
yum install libstdc* -y
yum install make* -y
yum install sysstat* -y
[root@oel ~]# chmod 755 /opt/yum.sh
[root@oel ~]# /opt/yum.sh 

2．Oracle ASM 需求
[root@oel ~]# uname -a --获取操作系统版本
Linux oel.example.com 2.6.18-164.el5 #1 SMP Thu Sep 3 02:16:47 EDT 2009 i686 i686 i386 GNU/Linux
[root@oel ~]# getconf LONG_BIT --获取操作系统位数
32
2) 守装asm软件包
登录oracle 官方网站，搜索关键字oracle asm red hat 5，下载asm 的软件包。
http://www.oracle.com/technetwork/server-storage/linux/downloads/rhel5-084877.html
[root@oel ~]# yum remove oracleasm*
[root@oel ~]# yum install oracleasm*
3．创建用户和用户组
[root@oel ~]# groupadd asmadmin
[root@oel ~]# groupadd asmdba
[root@oel ~]# groupadd asmoper
[root@oel ~]# useradd -g oinstall -G asmadmin,asmdba,asmoper grid
4．创建目录并授权
[root@oel ~]# mkdir -p /u01/app/oracle
[root@oel ~]# mkdir -p /u01/app/grid
[root@oel ~]# chown -R grid:oinstall /u01
[root@oel ~]# chown -R oracle:oinstall /u01/app/oracle
[root@oel ~]# chmod -R 775 /u01/app/oracle
[root@oel ~]# chmod -R 775 /u01/app/grid
5．修改环境变量
--向环境变量文件中追加以下行
[root@oel ~]# cat /home/grid/.bash_profile   
export ORACLE_SID=+ASM
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=$ORACLE_BASE/11.2.0
export PATH=$PATH:$ORACLE_HOME/bin
[root@oel ~]# source /home/grid/.bash_profile  
6．配置虚拟磁盘
[root@oel ~]# more /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: VMware,  Model: VMware Virtual S Rev: 1.0 
  Type:   Direct-Access                    ANSI SCSI revision: 02
[root@oel ~]# fdisk -l

Disk /dev/sda: 53.6 GB, 53687091200 bytes
255 heads, 63 sectors/track, 6527 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          13      104391   83  Linux
/dev/sda2              14        6527    52323705   8e  Linux LVM
[root@oel ~]# echo "scsi add-single-device 0 0 1 0" >/proc/scsi/scsi
[root@oel ~]# fdisk -l

Disk /dev/sda: 53.6 GB, 53687091200 bytes
255 heads, 63 sectors/track, 6527 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          13      104391   83  Linux
/dev/sda2              14        6527    52323705   8e  Linux LVM

Disk /dev/sdb: 8589 MB, 8589934592 bytes
255 heads, 63 sectors/track, 1044 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
[root@oel ~]# ls -l /dev/sd*
brw-r----- 1 root disk 8,  0 Mar 26 18:04 /dev/sda
brw-r----- 1 root disk 8,  1 Mar 26 18:04 /dev/sda1
brw-r----- 1 root disk 8,  2 Mar 26 18:04 /dev/sda2
brw-r----- 1 root disk 8, 16 Mar 26 18:48 /dev/sdb
--对新添加的磁盘进行分区（我们添加了sdb。注意：这里仅进行分区，不进行格式化）
[root@oel ~]# fdisk /dev/sdb

The number of cylinders for this disk is set to 1044.
There is nothing wrong with that, but this is larger than 1024,
and could in certain setups cause problems with:
1) software that runs at boot time (e.g., old versions of LILO)
2) booting and partitioning software from other OSs
   (e.g., DOS FDISK, OS/2 FDISK)

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-1044, default 1): 
Using default value 1
Last cylinder or +size or +sizeM or +sizeK (1-1044, default 1044): 261

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 2
First cylinder (262-1044, default 262): 
Using default value 262
Last cylinder or +size or +sizeM or +sizeK (262-1044, default 1044): 522

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 3
First cylinder (523-1044, default 523): 
Using default value 523
Last cylinder or +size or +sizeM or +sizeK (523-1044, default 1044): 738

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Selected partition 4
First cylinder (739-1044, default 739): 
Using default value 739
Last cylinder or +size or +sizeM or +sizeK (739-1044, default 1044): 
Using default value 1044

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@oel ~]# fdisk -l

Disk /dev/sda: 53.6 GB, 53687091200 bytes
255 heads, 63 sectors/track, 6527 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          13      104391   83  Linux
/dev/sda2              14        6527    52323705   8e  Linux LVM

Disk /dev/sdb: 8589 MB, 8589934592 bytes
255 heads, 63 sectors/track, 1044 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         261     2096451   83  Linux
/dev/sdb2             262         522     2096482+  83  Linux
/dev/sdb3             523         738     1735020   83  Linux
/dev/sdb4             739        1044     2457945   83  Linux

7．配置ASM
root@oel ~]# /etc/init.d/oracleasm configure
Configuring the Oracle ASM library driver.

This will configure the on-boot properties of the Oracle ASM library
driver.  The following questions will determine whether the driver is
loaded on boot and what permissions it will have.  The current values
will be shown in brackets ('[]').  Hitting <ENTER> without typing an
answer will keep that current value.  Ctrl-C will abort.

Default user to own the driver interface []: oracle
Default group to own the driver interface []: oinstall
Start Oracle ASM library driver on boot (y/n) []: y
Scan for Oracle ASM disks on boot (y/n) []: y
Writing Oracle ASM library driver configuration: done
Initializing the Oracle ASMLib driver:                     [  OK  ]
Scanning the system for Oracle ASMLib disks:               [  OK  ]

8．添加ASM 磁盘
[root@oel ~]# oracleasm createdisk VOL1 /dev/sdb1
Writing disk header: done
Instantiating disk: done
[root@oel ~]# oracleasm createdisk VOL2 /dev/sdb2
Writing disk header: done
Instantiating disk: done
[root@oel ~]# oracleasm createdisk VOL3 /dev/sdb3
Writing disk header: done
Instantiating disk: done
[root@oel ~]# oracleasm createdisk VOL4 /dev/sdb4
Writing disk header: done
Instantiating disk: done

9．配置侦听器并启动（略）
10．安装Grid Infrastructure 软件
[root@oel ~]# mv /opt/p10404530_112030_LINUX_3of7.zip /u01/app/grid/
[root@oel ~]# su - grid
[grid@oel grid]$ cd /u01/app/grid/
[grid@oel grid]$ unzip p10404530_112030_LINUX_3of7.zip 
[root@oel app]# chown -R grid.oinstall grid/          
[grid@oel grid]$ cd grid/
[grid@oel grid]$ export DISPLAY=192.168.21.1:0.0
[grid@oel grid]$ ./runInstaller 
勾选　Configure Oracle Grid Infrastructure for a Stardalone Server
默认　English
Create ASM Disk GROUP
	Disk Group Name: DATA
	Redundancy:	NORMAL
	Chang Discovery Path
		/dev/oracleasm/disks/*
[grid@oel grid]$ export DISPLAY=192.168.21.1:0.0
[grid@oel grid]$ asmca

11．管理ASM 实例
[grid@oel ~]$ su - oracle
Password: 
[oracle@oel ~]$ cd $ORACLE_HOME/dbs
[oracle@oel dbs]$ ll
total 20
-rwxrwxr-x 1 oracle oinstall 1544 Mar 25 13:35 hc_orcl.dat
-rwxrwxr-x 1 oracle oinstall 2851 May 15  2009 init.ora
-rwxrwxr-x 1 oracle oinstall   24 Mar 25 13:38 lkORCL
-rwxrwxr-x 1 oracle oinstall 1536 Mar 25 13:41 orapworcl
-rwxrwxr-x 1 oracle oinstall 2560 Mar 26 12:00 spfileorcl.ora