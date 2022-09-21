# GCC


## gcc 编译 C 程序的四个步骤

1. 预处理（宏展开）。`cpp main.c main.i`，输出为 main.i。
2. 编译（源代码编译为汇编语言）。`gcc -S main.i`，输出为 main.s。
3. 汇编（即汇编语言编译为机器语言），`as main.s -o main.o`，输出为 main.o。
4. 链接（创建最终的可执行文件），`gcc main.o`，输出为 main.out。

```makefile
# 保存编译过程临时文件
gcc -save-temps main.c
```

## 预处理

```makefile
gcc -E main.c
```

## 静态库和动态库

- 静态库：编译时链接，静态库的机器代码拷贝到调用者的最终可执行文件。
- 动态库：使用更高级的链接方式，最终可执行文件不包含库机器代码，程序执行时从内存进行动态链接。

### 查看依赖的动态库

```makefile
ldd a.out
```

## gcc 目录搜索选项（Options for Directory Search）

> -Idir
> 
> 添加 dir 目录作为头文件搜索路径，这个 dir 目录比系统头文件目录被搜索的早，所以可以通过它用自己的头文件代替系统头文件。如果有多个 -I 选项，按从左到右的顺序搜索，系统默认目录在这之后。如果该选项的 dir 是系统默认目录，则忽略该选项，且不改变搜索顺序。

> -iquotedir
>     
>     添加 dir 目录作为头文件搜索路径，只对引号情况有效：#include "file"; 不作为尖括号的情况：#include \<file\> 两者都搜索用 -I

> -Ldir
>     
>     添加 dir 目录到用于搜索 -l 选项的目录列表。
    
> -sysrootdir
>     
>     用 dir 作为头文件和库的根目录，例如，如果编译器正常情况下在 /usr/include 找头文件，在 /usr/lib 中找库文件，在这之后，更改为 dir/usr/include and dir/usr/lib.
    

## gcc 链接选项（Options for Linking）

> -llibrary
> -l library
> Search the library named library when linking.
> 
> 链接时候搜索名为 library 的库，-l 和库的名字之间可以有空格也可以没有，例如 -lname 意思是寻找名为 name 的库，在标准库中库的名字一般为：libname.a，搜索路径包括：
> 
> 1. 系统默认目录（/lib and /usr/lib）
> 2. 用 -L 参数指定的目录 

在没有使用 -static 选项时，发现共享库 name.so，则使用 name.so 进行动态链接。

> -static
>     
>     禁止与共享库链接。
    
> -shared
>     
>     尽量与共享库链接，这是默认选项。
    
> -c Compile or assemble the source files, but do not link.
>     
>     只对源文件进行编译，不链接生成可执行文件。只需要产生目标文件时候使用该选项。
    
> -S Stop after the stage of compilation proper; do not assemble.
>     
>     只对源码文件编译，不装配不链接。输出为装配码文件。
    
> -E Stop after the preprocessing stage; do not run the compiler proper.
>    
>     只进行预预处理，输出为与编译源码文件。
   

## 调试选项（Debugging Your Program）

> -g
> 
> 生成供 gdb 使用的调试信息。

> -ggdb
>     
>     产生更多的调试信息。
    
> -O [0,1,2,3]
>     
>     优化程序，默认 2 级优化，0 不优化，优化和调试不兼容，所以不要同时使用 -g 和 -O 选项。
    
> -o filename（小写）
>     
>     指定输出文件名，默认 a.out
    

## 头文件的来源

gcc 在编译时如何去寻找所需要的头文件：

1. header file 的搜寻会从 -I 开始
2. 然后找 gcc 的 环境变量 C_INCLUDE_PATH，CPLUS_INCLUDE_PATH，OBJC_INCLUDE_PATH
3. 再找内定目录
    * /usr/include
    * /usr/local/include（ centos7 中该目录下是空的）
    * gcc 的一系列自带目录
    * /usr/include/c++/4.8.5
    

## 库文件的来源

编译的时候：

1. gcc 会去找 -L
2. 再找 gcc 的环境变量 LIBRARY_PATH
3. 再找内定目录
    * /lib 和 /lib64
    * /usr/lib 和 /usr/lib64
    * /usr/local/lib 和 /usr/local/lib64
    

## 生成库文件

```makefile
ar cr libNAME.a file1.o file2.o file3.o ... filen.o

# 例子
ar cr libhello.a func1.o func2.o
```

## 查看库文件

```makefile
at t libNAME.a

# 例子
huqf@ubuntu:~/GitHub/mycmake/build$ ar t libstm32_lib.a 
misc.c.o
stm32f4xx_adc.c.o
stm32f4xx_can.c.o
stm32f4xx_dma.c.o
stm32f4xx_flash.c.o
stm32f4xx_rcc.c.o
stm32f4xx_gpio.c.o
stm32f4xx_tim.c.o
stm32f4xx_spi.c.o
stm32f4xx_pwr.c.o
stm32f4xx_sdio.c.o
stm32f4xx_usart.c.o
stm32f4xx_syscfg.c.o
system_stm32f4xx.c.o
usb_bsp.c.o
usbd_desc.c.o
usbd_cdc_core.c.o
usbd_ioreq.c.o
usbd_req.c.o
usbd_core.c.o
usb_core.c.o
usb_dcd_int.c.o
usb_dcd.c.o
```