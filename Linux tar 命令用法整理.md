# Linux tar 命令用法整理


# Tar

tar 是 Unix 和类 Unix 系统上的归档打包工具，可以将多个文件合并为一个文件，打包后的文件名亦为“tar”。程序最初的设计目的是将文件备份到[磁带](https://zh.wikipedia.org/wiki/%E7%A3%81%E5%B8%A6)上（**t**ape **ar**chive），因而得名tar。

## 缩写

tar 代表未压缩的 tar 文件。已压缩的 tar 文件则附加数据压缩格式的扩展名，如经过 gzip 压缩后的 tar 文件，扩展名为“.tar.gz”。

压缩文件常使用下列缩写，缩写与原始后缀等价。

| 缩写     | 原始后缀  |
| -------- | --------- |
| .tgz     | .tar.gz   |
| .tbz/tb2 | .tar.bz2  |
| .taz     | .tar.Z    |
| .tlz     | .tar.lzma |
| .txz     | .tar.xz          |

## tar的用法

```
 tar 功能 选项 文件

```

可以将代表功能和选项的单个字母合并；当使用单个字母时，可以不用在字母前面加“-”。功能只能使用一个，选项可以使用多个。

### 功能

功能只能使用一个，一般使用单字母关键词。

| 单字母关键词 | 等效关键词                | 作用                                                         |
| ------------ | ------------------------- | ------------------------------------------------------------ |
| -c           | --create                  | 建立新的 tar 档案                                              |
| -x           | --extract，--get          | 解开 tar 文件                                                  |
| -t           | --list                    | 列出 tar 文件中包含的文件的信息                                |
| -r           | --append                  | 附加新的文件到 tar 文件中                                      |
| -u           | --update                  | 用已打包的文件的较新版本更新 tar 文件                          |
| -A           | --catenate，--concatenate | 将 tar 文件作为一个整体追加到另一个 tar 文件中                   |
| -d           | --diff，--compare         | 将文件系统里的文件和 tar 文件里的文件进行比较                  |
|              | --delete                  | 删除 tar 文件里的文件。注意，这个功能不能用于已保存在磁带上的 tar 文件！ |

### 选项

选项可以使用多个，一般使用单字母关键词。其中 **f** 是必须的，并且放在最后，用来指定文件。

| 单字母关键词 | 等效关键词                 | 作用                                                         |
| ------------ | -------------------------- | ------------------------------------------------------------ |
| -v           | --verbose                  | 列出每一步处理涉及的文件的信息，只用一个“v”时，仅列出文件名，使用两个“v”时，列出权限、所有者、大小、时间、文件名等信息 |
| -k           | --keep-old-files           | 不覆盖文件系统上已有的文件                                   |
| -f           | --file                     | 文件名 指定要处理的文件名|
| -P           | --absolute-names           | 使用绝对路径|
| -j           | --bzip2                    | 调用 [bzip2](https://zh.wikipedia.org/wiki/Bzip2) 执行压缩或解压缩
| -J           | --xz，--lzma               | 调用 [XZ Utils](https://zh.wikipedia.org/w/index.php?title=XZ_Utils&action=edit&redlink=1) 执行压缩或解压缩。依赖 XZ Utils |
| -z           | --gzip，--gunzip，--ungzip | 调用 [gzip](https://zh.wikipedia.org/wiki/Gzip) 执行压缩或解压缩 |
| -Z           | --compress，--uncompress   | 调用 [compress](https://zh.wikipedia.org/w/index.php?title=Compress&action=edit&redlink=1) 执行压缩或解压缩 |

### 实例

```
tar -cvf jpg.tar *.jpg        // 将目录里所有 jpg 文件打包成 tar.jpg
tar -czf jpg.tar.gz *.jpg     // 将目录里所有 jpg 文件打包成 jpg.tar，并且用 gzip 压缩，生成一个 gzip 压缩过的包，命名为 jpg.tar.gz
tar -cjf jpg.tar.bz2 *.jpg    // 将目录里所有 jpg 文件打包成 jpg.tar，并且用 bzip2 压缩，生成一个 bzip2 压缩过的包，命名为 jpg.tar.bz2
tar -cZf jpg.tar.Z *.jpg      // 将目录里所有 jpg 文件打包成 jpg.tar，并且用 compress 压缩，生成一个 umcompress 压缩过的包，命名为 jpg.tar.Z

tar -xvf file_name.tar        // 解压 tar 包
tar -xzvf file_name.tar.gz    // 解压 tar.gz
tar -xjvf file_name.tar.bz2   // 解压 tar.bz2
tar -xZvf file_name.tar.Z     // 解压 tar.Z

```

## 参考

[Linux 下的 tar 压缩解压缩命令详解 - 博客园](https://www.cnblogs.com/songanwei/p/9367319.html)[Tar - 维基百科](https://zh.wikipedia.org/wiki/Tar)