/*
基本上shell 分两大类：
1) 图形界面shell（Graphical User Interface shell 即GUI shell）
2) 命令行式shell（Command Line Interface shell ，即CLI shell）
*/

[root@example ~]# cd /  --切换到根目录
[root@example /]# pwd
/
[root@example /]# cd ~	--切换当前用户的家目录
[root@example ~]# pwd
/root
[root@example ~]# cd ~root	--切换到root 用户的家目录
[root@example ~]# pwd
/root
[root@example ~]# cd .	--切换到当前目录
[root@example ~]# pwd
/root
[root@example ~]# cd ..	--切换到上一级目录
[root@example /]# pwd
/
[root@example /]# cd -	--切换到上一个（历史）工作目录
/root
[root@example ~]# 
/*
Linux 重要的目录
/bin 
系统有很多放置执行文件的目录，但/bin 比较特殊。因为/bin 放置的是在单人维护模式下还能够被操作的指令。
在/bin 底下的指令可以被root与一般账号所使用，
主要有：cat, chmod, chown, date, mv, mkdir, cp,bash 等等常用的指令。

/boot 
这个目录主要在放置开机会使用到的文件，包括Linux 核心文件以及开机选单与开机所需配置文件等等
Linux kernel 常用的档名为：vmlinuz*，
如果使用的是grub 这个开机管理程序， 则还会存在/boot/grub/

/dev 
在Linux 系统上，任何装置与接口设备都是以文件的型态存在于这个目录当中的。
比要重要的文件有/dev/null, /dev/zero, /dev/tty, /dev/lp*,/dev/hd*, /dev/sd*等等

/etc 
系统主要的配置文件几乎都放置在这个目录内，例如人员的账号密码文件、各种服务的启始档等等。
比较重要的文件有： /etc/inittab,/etc/init.d/, /etc/modprobe.conf, /etc/X11/, /etc/fstab, /etc/sysconfig/ 等等。
/etc/init.d/：所有服务的预设启动script 都是放在这里的
/etc/xinetd.d/：super daemon 管理的各项服务的配置文件目录。
/etc/X11/ ： 与X Window 有关的各种配置文件都在这里

/home 
这是系统默认的用户家目录(home directory)。

/lib 
系统的函式库非常的多，而/lib 放置的则是在开机时会用到的函式库，以及在/bin 或/sbin 底下的指令会呼叫的函式库而已。

/media 
包括软盘、光盘、DVD 等等装置都暂时挂载于此。
常见的档名有：/media/floppy, /media/cdrom 等等。

/mnt 
如果妳想要暂时挂载某些额外的装置

/opt 
这个是给第三方协力软件放置的目录

/root 
系统管理员(root)的家目录。

/sbin
Linux 有非常多指令是用来设定系统环境的，这些指令只有root 才能够利用来『设定』系统，其他用户最多只能用来『查询』而已。
放在/sbin底下的为开机过程中所需要的，里面包括了开机、修复、还原系统所需要的指令。至于某些服务器软件程序，一般则放置到/usr/sbin/当中。
至于本机自行安装的软件所产生的系统执行文件(system binary)， 则放置到/usr/local/sbin/当中了。
常见的指令包括：fdisk, fsck, ifconfig, init, mkfs等等。

/srv 
可以视为『service』的缩写，是一些网络服务启动之后，这些服务所需要取用的数据目录。

/tmp 
这是让一般使用者或者是正在执行的程序暂时放置文件的地方。
这个目录是任何人都能够存取的，所以你需要定期的清理一下。

/lost+found 
这个目录是使用标准的ext2/ext3文件系统格式才会产生的一个目录，
目的在于当文件系统发生错误时， 将一些遗失的片段放置到这个目录下。

/proc 
他放置的数据都是在内存当中， 
例如系统核心、行程信息(process)、周边装置的状态及网络状态等等。因为这个目录下的数据都是在内存当中， 所以本身不占任何硬盘空间啊！ 
比较重要的文件例如：/proc/cpuinfo, /proc/dma, /proc/interrupts, /proc/ioports, /proc/net/等等。

/sys 
这个目录其实跟/proc 非常类似，也是一个虚拟的文件系统，主要也是记录与核心相关的信息。
包括目前已加载的核心模块与核心侦测到的硬件装置信息等等。这个目录同样不占硬盘容量喔！

/usr  
	Unix Software Resource
	/usr/X11R6/ 为X Window System 重要数据所放置的目录，之所以取名为X11R6是因为最后的X 版本为第11版，且该版的第6次释出之意。
	/usr/bin/ 绝大部分的用户可使用指令都放在这里！请注意到他与/bin 的不同之处。(是否与开机过程有关)
	/usr/include/ c/c++等程序语言的档头(header)与包含档(include)放置处
	/usr/lib/ 
		包含各应用软件的函式库、目标文件(object file)，以及不被一般使用者惯用的执行档或脚本(script)。
		某些软件会提供一些特殊的指令来进行服务器的设定，这些指令也不会经常被系统管理员操作， 那就会被摆放到这个目录下啦。
		要注意的是，如果你使用的是X86_64的Linux 系统， 那可能会有/usr/lib64/目录产生喔！
	/usr/local/ 系统管理员在本机自行安装自己下载的软件(非distribution 默认提供者)，建议安装到此目录， 这样会比较便于管理。
	/usr/sbin/ 非系统正常运作所需要的系统指令。最常见的就是某些网络服务器软件的服务指令(daemon)啰！
	/usr/share/ 放置共享文件的地方，在这个目录下放置的数据几乎是不分硬件架构均可读取的数据，
	因为几乎都是文本文件嘛！在此目录下常见的还有这些次目录：
		/usr/share/man：联机帮助文件
		/usr/share/doc：软件杂项的文件说明
		/usr/share/zoneinfo：与时区有关的时区文件
	/usr/src/ 一般原始码建议放置到这里，src 有source 的意思。至于核心原始码则建议放置到/usr/src/linux/目录下。
/var
	/var/cache/ 应用程序本身运作过程中会产生的一些暂存档；
	/var/lib/
		程序本身执行的过程中，需要使用到的数据文件放置的目录。
		在此目录下各自的软件应该要有各自的目录。
		举例来说，MySQL 的数据库放置到/var/lib/mysql/，而rpm 的数据库则放到/var/lib/rpm 去！
	/var/lock/
		某些装置或者是文件资源一次只能被一个应用程序所使用，如果同时有两个程序使用该装置时， 
		就可能产生一些错误的状况，因此就得要将该装置上锁(lock)，以确保该装置只会给单一软件所使用。
	/var/log/
		这是登录文件放置的目录！里面比较重要的文件如/var/log/messages, /var/log/wtmp(记录登入者的信息)等。
	/var/mail/
		放置个人电子邮件信箱的目录， 不过这个目录也被放置到/var/spool/mail/目录中！ 通常这两个目录是互为链接文件啦！
	/var/run/
		某些程序或者是服务启动后，会将他们的PID 放置在这个目录下喔！
	/var/spool/
		这个目录通常放置一些队列数据，所谓的『队列』就是排队等待其他程序使用的数据啦！ 这些数据被使用后通常都会被删除。
		举例来说，系统收到新信会放置到/var/spool/mail/中， 但使用者收下该信件后该封信原则上就会被删除。
		信件如果暂时寄不出去会被放到/var/spool/mqueue/中， 等到被送出后就被删除。
		如果是工作排程数据(crontab)，就会被放置到/var/spool/cron/目录中！
*/
--有关目录的命令	
man cd 	--查看cd 指令的帮助文档	
pwd 	--显示当前工作目录	
ls		--列出当前目录下的内容
cd / 	--切换到根目录
mkdir -p study/oracle/OC{A,P,M}	--创建目录
rmdir oracle --删除oracle 目录
mv oracle /opt --移动文件/目录
cp [options] source1 source2 source3 .... directory --拷贝文件/目录 如果来源档有两个以上，则最后一个目的档一定要是『目录』才行
--打开文件
more oracle.log
less oracle.log
tail -20f oracle.log --文件尾部输出
cat oracle.log
--用户和组
cat /etc/passwd
cat /etc/shadow
cat /etc/group
cat /etc/gshadow 


[root@example]# groupadd test --添加用户useradd
[root@example]# groupadd test1
[root@example]# useradd test -g test -G test1
[root@example]# grep test /etc/passwd /etc/group /etc/shadow
/etc/passwd:test:x:500:500::/home/test:/bin/bash
/etc/group:test:x:500:
/etc/group:test1:x:501:test
/etc/shadow:test:!!:17246:0:99999:7:::
[root@example]# su test
[test@example]$ groups
test test1