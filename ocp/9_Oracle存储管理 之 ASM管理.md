SQL> show parameter type

NAME                                 TYPE        VALUE
------------------------------------ ----------- 
instance_type                        string      RDBMS
plsql_code_type                      string      INTERPRETED
RDBMS 关系型数据库系统
asm:	instance
rdbms:	instance+database

ASM文档
file:///D:/%E8%85%BE%E7%A7%91/%E5%AE%98%E6%96%B9%E6%96%87%E6%A1%A3/E11882_01/server.112/e18951/toc.htm

getconf LONG_BIT 查看位数
32
uname -a  查看系统版本
Linux asm.oracle.com 2.6.18-164.el5 #1 SMP Thu Sep 3 02:16:47 EDT 2009 i686 i686 i386 GNU/Linux
mount /dev/cdrom -o loop /mnt 挂载光盘到/mnt
yum list all
cd /mnt/Server/
ls -l oracleasm*
rpm -ivh oracleasm*
选中你的虚拟机asm->右键->Settings->add->Hard Disk->SCSI
Create a new virtual disk->
	Maximum disk size: 8G
	勾上Store virtual disk as a single file

[root@asm Server]# cd /dev
[root@asm dev]# ls -l sd*
brw-r----- 1 root disk 8, 0 Feb 26 16:35 sda
brw-r----- 1 root disk 8, 1 Feb 26 16:40 sda1
brw-r----- 1 root disk 8, 2 Feb 26 17:41 sda2
需要重启才能识别新加的虚拟磁盘，用下面的方法不用重启
[root@asm dev]# more /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: VMware,  Model: VMware Virtual S Rev: 1.0 
  Type:   Direct-Access                    ANSI SCSI revision: 02
可以看到现在的磁盘Id: 00，那下一块磁盘应为01
[root@asm dev]# fdisk -l

Disk /dev/sda: 53.6 GB, 53687091200 bytes
255 heads, 63 sectors/track, 6527 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          13      104391   83  Linux
/dev/sda2              14        6527    52323705   8e  Linux LVM
把信息重定向到这个文件中去，相当于手动回进来
[root@asm dev]# echo "scsi add-single-device 0 0 1 0">/proc/scsi/scsi
[root@asm dev]# ls -l sd*                                            
brw-r----- 1 root disk 8,  0 Feb 26 16:35 sda
brw-r----- 1 root disk 8,  1 Feb 26 16:40 sda1
brw-r----- 1 root disk 8,  2 Feb 26 17:41 sda2
brw-r----- 1 root disk 8, 16 Feb 26 21:36 sdb
[root@asm dev]# fdisk /dev/sdb对磁盘进行分区
[root@asm dev]# fdisk /dev/sdb 分成4个分区，每个分区为2G
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
Last cylinder or +size or +sizeM or +sizeK (523-1044, default 1044): 783

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Selected partition 4（保存一下）
First cylinder (784-1044, default 784): 
Using default value 784
Last cylinder or +size or +sizeM or +sizeK (784-1044, default 1044): 
Using default value 1044

Command (m for help): w
The partition table has been altered!

[root@asm dev]# fdisk -l

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
/dev/sdb3             523         783     2096482+  83  Linux
/dev/sdb4             784        1044     2096482+  83  Linux
[root@asm dev]# /etc/init.d/oracleasm 
Usage: /etc/init.d/oracleasm {start|stop|restart|enable|disable|configure|createdisk|deletedisk|querydisk|listdisks|scandisks|status}
[root@asm dev]# /etc/init.d/oracleasm configure　第一次使用要配置一下，以后就不用配置了
Default user to own the driver interface []: grid
Default group to own the driver interface []: asmdba
Start Oracle ASM library driver on boot (y/n) []: y
Scan for Oracle ASM disks on boot (y/n) []: y

[root@asm ~]# ls -l /dev/sd*
brw-r----- 1 root disk 8,  0 Feb 26 16:35 /dev/sda
brw-r----- 1 root disk 8,  1 Feb 26 16:40 /dev/sda1
brw-r----- 1 root disk 8,  2 Feb 26 17:41 /dev/sda2
brw-r----- 1 root disk 8, 16 Feb 26 21:40 /dev/sdb
brw-r----- 1 root disk 8, 17 Feb 26 21:47 /dev/sdb1
brw-r----- 1 root disk 8, 18 Feb 26 21:47 /dev/sdb2
brw-r----- 1 root disk 8, 19 Feb 26 21:47 /dev/sdb3
brw-r----- 1 root disk 8, 20 Feb 26 21:47 /dev/sdb4
创建asm磁盘
[root@asm ~]# oracleasm createdisk VOL1 /dev/sdb1
Writing disk header: done
Instantiating disk: done
[root@asm ~]# oracleasm createdisk VOL2 /dev/sdb2
Writing disk header: done
Instantiating disk: done
[root@asm ~]# oracleasm createdisk VOL3 /dev/sdb3
Writing disk header: done
Instantiating disk: done
[root@asm ~]# oracleasm createdisk VOL4 /dev/sdb4
Writing disk header: done
Instantiating disk: done
列出asm磁盘
[root@asm ~]# oracleasm listdisks
VOL1
VOL2
VOL3
VOL4
[root@asm ~]# su - grid
[grid@asm ~]$ export DISPLAY=192.168.21.1:0.0
[grid@asm ~]$ dbca

export ORACLE_SID=+ASM
sqlplus / as sysdba
ps -ef | grep +ASM
[root@asm disks]# su  - grid
[grid@asm ~]$ export DISPLAY=192.168.21.1:0.0
[grid@asm ~]$ asmca
[root@asm ~]# cd /dev/oracleasm/disks/
[root@asm disks]# ls
VOL1  VOL2  VOL3  VOL4
[root@asm ~]# su - grid
[grid@asm ~]$ sqlplus / as sysdba
SQL> create pfile from spfile;

[grid@asm dbs]$ su - oracle
[oracle@asm ~]$ export DISPLAY=192.168.21.1:0.0
[oracle@asm ~]$ dbca
 create database->General or Transaction Processing
 Global Database Name: orcl
 SID: orcl
 Storage Type: Automatic Storage Management(ASM)
 Use oracle-Managed Files
	Database Area: +DATA
Enable Archiving:
	Archive Log Destinations:+RECOVER
勾上Sample Schemas

 SQL> select name,state from v$asm_diskgroup;

NAME                           STATE
------------------------------ -----------
DATA                           MOUNTED
RECOVER                        MOUNTED

$ORACLE_HOME/bin/sqlplus	管理数据库		orcl
$GRID_HOME/bin/sqlplus 		管理集群/asm	+ASM

[root@asm ~]# grep MemTotal /proc/meminfo
MemTotal:      2075500 kB
[root@asm ~]# grep SwapTotal /proc/meminfo 建议为内存的1.5倍
SwapTotal:     4128760 kB
[root@asm ~]# uname -a
Linux asm.oracle.com 2.6.18-164.el5 #1 SMP Thu Sep 3 02:16:47 EDT 2009 i686 i686 i386 GNU/Linux
[root@asm ~]# getconf LONG_BIT
32
cd /media/
mount /dev/cdrom -o loop /mnt/
cd /mnt/Server/
ls -l oracleasm*
rpm -ivh oracleasm*

1.　创建用户
[root@asm ~]# groupadd asmadmin
[root@asm ~]# groupadd asmdba
[root@asm ~]# groupadd asmoper
[root@asm ~]# useradd -g oinstall -G asmadmin,asmdba,asmoper grid    -g初始组，-G 有效组
[root@asm ~]# id grid
uid=601(grid) gid=501(oinstall) groups=501(oinstall),1003(asmadmin),1004(asmdba),1005(asmoper)
[root@asm ~]# usermod -g oinstall -G dba,asmdba oracle
[root@asm ~]# id oracle
uid=600(oracle) gid=501(oinstall) groups=501(oinstall),500(dba),1004(asmdba)
chown -R grid.oinstall /u01/
chown -R oracle.oinstall /u01/app/oracle
chown -R 775 /u01/app/oracle
mkdir /u01/app/grid
chown -R grid.oinstall /u01/app/grid
chown -R 775 /u01/app/grid
su - grid
2.　设置环境变量
vi .bash_profile
export ORACLE_SID=+ASM
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=$ORACLE_BASE/11.2.0
export PATH=$PATH:$ORACLE_HOME/bin
source .bash_profile
3.　增加虚拟磁盘
虚拟机->设置->添加->磁盘->scsi->创建新虚拟磁盘
	8G
	将虚拟磁盘存储为单个文件

echo "scsi add-single-device 0 0 1 0">/proc/scsi/scsi
ls -l /dev/sd*
4. 分区
fdisk sdb
Command (m for help): n
p
Partition number: 1
Last cylinder or +size or +sizeM or +sizeK (1-1044, default 1044): 261
Command (m for help): n
p
Partition number: 2
Last cylinder or +size or +sizeM or +sizeK (1-1044, default 1044): 522
Command (m for help): n
p
Partition number: 3
Last cylinder or +size or +sizeM or +sizeK (1-1044, default 1044): 783
Command (m for help): n
p
Partition number: 4
Last cylinder or +size or +sizeM or +sizeK (1-1044, default 1044): 
Command (m for help): w

fdisk -l 

5. 对asm扫描磁盘
/etc/init.d/oracleasm configure　
Default user to own the driver interface []：grid
Default group to own the driver interface []: oinstall
Start Oracle ASM library driver on boot (y/n) [n]:y
6. 创建asm磁盘
oracleasm createdisk VOL1 /dev/sdb1
oracleasm createdisk VOL2 /dev/sdb2
oracleasm createdisk VOL3 /dev/sdb3
oracleasm createdisk VOL4 /dev/sdb4

7.  安装grid软件
用winSCP上传到/u01/app/grid
cd /u01/app/grid
unzip linux_11gR2_grid.zip
export DISPLAY=192.168.21.1:0.0
cd grid
./runInstaller
选Install and Configure Grid Infrastructure for a Standalone Server,下一步
create ASM Disk Group
	Disk Group Name: DATA
	点击Change Discovery Path,输/dev/oracleasm/disks/VOL*
	Oracle Base: /u01/app/grid
	Software Location: /u01/app/grid/11.2.0

ps -ef | grep +ASM



