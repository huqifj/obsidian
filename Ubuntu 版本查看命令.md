# Ubuntu 版本查看命令


**简单的**

在命令终端输入

1.cat /etc/issue （简单）

2.cat /etc/lsb-release（具体）

3.uname -a（内核）

**具体的**

有时候我们安装软件或者搭建服务的时候，需要了解当前系统的版本信息，下面几个命令可以帮助我们查看当前ubuntu系统的版本信息。

一：利用命令:

```
cat /proc/version

```

显示如下：

[https://img-blog.csdn.net/20160730180212191](https://img-blog.csdn.net/20160730180212191)

1. Linux version 3.16.0-30-generic (buildd@kissel) linux内核版本号
2. gcc version 4.8.2 gcc编译器版本号
3. Ubuntu 4.8.2-19ubuntu1 Ubuntu版本号

二：

```
uname -a

```

[https://img-blog.csdn.net/20160730184022474](https://img-blog.csdn.net/20160730184022474)

显示linux的内核版本和系统是多少位的：X86_64代表系统是64位的。

三：

```
sb_release -a

```

[https://img-blog.csdn.net/20160730184501605](https://img-blog.csdn.net/20160730184501605)

这个命令显示的比较简洁，解释如下:

1. Distributor ID: Ubuntu //类别是ubuntu
2. Description: Ubuntu 14.04.2 LTS //14年2月4月发布的稳定版本，LTS是Long Term Support：长时间支持版本 三年 ，一般是18个月
3. Release: 14.04 //发行日期或者是发行版本号
4. Codename: trusty //ubuntu的代号名称