## 安装
```shell
sudo apt update
sudo apt install apache2
```

## 查看运行状态
```shell
sudo systemctl status apache2
```

## 开启端口
```shell
sudo ufw allow 'Apache Full'
```

## Apache 配置文件介绍

- /etc/apache2/apache2.conf
	是主要配置文件 (这个文件的末尾可以看到，include 了其它所有的配置文件)。
- /etc/apache2/ports.conf
	始终包含在主配置文件中。它用于确定传入连接的侦听端口，默认为 80，我们一般都会重新配置新的端口。
- /etc/apache2/sites-enabled，/etc/apache2/conf-enabled
	其它配置文件目录。
- /etc/apache2/mods-enabled
	其它配置文件目录。
- /var/www/html
	apache2 的默认 web 目录
- /etc/apache2/envvars
	apache2 的默认用户是 www-data，定义在该文件中。
- /etc/apache2/mods-enabled/dir.conf
	设置默认主页的配置文件

## 配置一个新的虚拟主机

### 创建目录
```shell
mkdir -p ~/www/var/firmware.com/html
```

### 创建主页文件
```shell
echo "Hello world!" >> ~/www/var/firmware.com/html/index.html
```

### 创建虚拟主机配置文件
```shell
sudo vi /etc/apache2/sites-available/firmware.com.conf
```

firmware.com.conf 文件内容如下：
```xml
<VirtualHost *:11030>
    ServerName firmware.com
    ServerAlias www.firmware.com
    ServerAdmin webmaster@firmware.com
    DocumentRoot ~/www/var/firmware.com/firmware.com

    <Directory ~/www/var/firmware.com/firmware.com>
        Options -Indexes +FollowSymLinks
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/firmware.com-error.log
    CustomLog ${APACHE_LOG_DIR}/firmware.com-access.log combined
</VirtualHost>
```

### 添加监听端口号
```shell
sudo vi /etc/apache2/ports.conf
```

修改后文件内容如下：
```xml
Listen 11030

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
```

### 创建配置文件链接
```shell
sudo a2ensite example.com
```

### 测试配置文件
```shell
sudo apachectl configtest
```

## 重启服务
```shell
sudo systemctl reload apache2
```

## 测试访问主页
在浏览器访问 http://192.168.1.24:11030