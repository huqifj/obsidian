# Python FTP 操作

## FTP 登陆连接

```c

from ftplib import FTP                                    # 加载 FTP 模块
ftp = FTP()                                               # 设置变量
ftp.set_debuglevel(2)                                     # 打开调试级别，2：显示详细信息
ftp.connect(“IP”, “port”)                                 # 连接的 FTP SERVER 和端口
ftp.login(“user”, “password”)                             # 连接的用户名，密码
print ftp.getwelcome()                                    # 打印出欢迎信息
ftp.cmd(“xxx/xxx”)                                        # 进入远程目录
bufsize = 1024                                            # 设置的缓冲区大小
filename = “filename.txt”                                 # 需要下载的文件
file_handle = open(filename,“wb”).write                   # 以写模式在本地打开文件
ftp.retrbinaly(“RETR filename.txt”,file_handle,bufsize)   # 接收服务器上文件并写入本地文件
ftp.set_debuglevel(0)                                     # 关闭调试模式
ftp.quit()                                                # 退出 FTP
```

## FTP 相关命令操作

```c
ftp.cwd(pathname)                                          # 设置 FTP 当前操作的路径
ftp.dir()                                                  # 显示目录下所有目录信息
ftp.nlst()                                                 # 获取目录下的文件
ftp.mkd(pathname)                                          # 新建远程目录
ftp.pwd()                                                  # 返回当前所在位置
ftp.rmd(dirname)                                           # 删除远程目录
ftp.delete(filename)                                       # 删除远程文件
ftp.rename(fromname, toname)                               # 将 fromname 修改名称为 toname
ftp.storbinaly(“STOR filename.txt”,file_handel,bufsize)    # 上传目标文件
ftp.retrbinary(“RETR filename.txt”,file_handel,bufsize)    # 下载 FTP 文件
```

## 示例

```c
#!/usr/bin/env python
#coding:utf-8

from ctypes import *
import os
import sys
import ftplib
import time

today = time.strftime('%Y%m%d',time.localtime(time.time()))
ip = '111.111.111.6'
username = 'ftpUserName' 
password = 'ftpPassWord'
filename = '203200189'+ today + 'A001.tar.gz'
src_file = '/ftpFilePath/'+filename

class myFtp:
    ftp = ftplib.FTP()
    ftp.set_pasv(False) 
    def __init__(self, host, port=21):
        self.ftp.connect(host, port)
 
    def Login(self, user, passwd):
        self.ftp.login(user, passwd)
        print(self.ftp.welcome)
 
    def DownLoadFile(self, LocalFile, RemoteFile):  #下载指定目录下的指定文件
        file_handler = open(LocalFile, 'wb')
        print(file_handler)
        # self.ftp.retrbinary("RETR %s" % (RemoteFile), file_handler.write)#接收服务器上文件并写入本地文件
        self.ftp.retrbinary('RETR ' + RemoteFile, file_handler.write)
        file_handler.close()
        return True

    def DownLoadFileTree(self, LocalDir, RemoteDir):  # 下载整个目录下的文件
        print("remoteDir:", RemoteDir)
        if not os.path.exists(LocalDir):
            os.makedirs(LocalDir)
        self.ftp.cwd(RemoteDir)
        RemoteNames = self.ftp.nlst()
        print("RemoteNames", RemoteNames)
        for file in RemoteNames:
            Local = os.path.join(LocalDir, file)
            print(self.ftp.nlst(file))
            if file.find(".") == -1:
                if not os.path.exists(Local):
                    os.makedirs(Local)
                self.DownLoadFileTree(Local, file)
            else:
                self.DownLoadFile(Local, file)
        self.ftp.cwd("..")
        return True

    #从本地上传文件到ftp
    def uploadfile(self, remotepath, localpath):
      bufsize = 1024
      fp = open(localpath, 'rb')
      ftp.storbinary('STOR ' + remotepath, fp, bufsize)
      ftp.set_debuglevel(0)
      fp.close() 

    def close(self):
        self.ftp.quit()
 
 
if __name__ == "__main__":
    ftp = myFtp(ip)
    ftp.Login(username, password)
    ftp.DownLoadFile(filename,src_file )
    #ftp.DownLoadFileTree('.', '/cteidate/')

    ftp.close()
    print("ok!")
```

## TP.quit () 与 FTP.close () 的区别

- FTP.quit()
    
    发送 QUIT 命令给服务器并关闭掉连接。这是一个比较 “缓和” 的关闭连接方式，但是如果服务器对 QUIT 命令返回错误时，会抛出异常。
    
- FTP.close()
    
    单方面的关闭掉连接，不应该用在已经关闭的连接之后，例如不应用在 FTP.quit() 之后。