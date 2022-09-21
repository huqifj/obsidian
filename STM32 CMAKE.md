# STM32 CMAKE

![Untitled](assets/STM32%20CMAKE/Untitled.png)

## **前言**

由于工作原因，已经许久没有接触飞控了。18 年的时候曾经写过一个半成品开源飞控，是基于 Keil MDK 这款商业 IDE 开发的，只能在 Windows 下运行。由于笔者现在绝大部分时间都在使用 Linux，偶尔想回顾一下以前的代码，竟不太方便，因此萌生了将原先的飞控项目移植到 Linux 下的想法。

目前国内[单片机](https://so.csdn.net/so/search?q=%E5%8D%95%E7%89%87%E6%9C%BA&spm=1001.2101.3001.7020)开发的教程绝大部分都是基于 Keil 的，Keil MDK 作为一款商业 IDE，的确存在它的优势：集成度高、上手快、编译器优化较好等。但是其劣势也很明显，首先这是款商业软件，需要付费，虽然绝大部分人所使用的是盗版，在国内个人使用不是什么大问题，但是如果是公司使用的话，极可能会收到起诉函（笔者工作后已经碰见过数起案例了）。其次最重要的是无法跨平台，只能在 Windows 下使用，这也是笔者想要替换它的最大原因。最后，Keil MDK 的编辑器功能在 2019 年看来，已经算是古董级别了。。。

## **VSCode & CMake**

Linux 平台下，并没有一款成熟好用的单片机 IDE。笔者这里推荐的是较为热门的开源代码编辑器：**VSCode**，前面有几篇博文也均介绍了如何使用 VSCode 开发 APM 之类的开源飞控，感兴趣的可以去看一下，这里就不详细介绍了。

编译器使用 gcc，这是一款支持多种编程语言的开源编译器。虽然对代码的优化程度有所不及 Keil 内置的 armcc 商业编译器，但也足够我们使用了，主流开源嵌入式项目基本全部使用 gcc。

IDE 的便利之处在于自动搞定了编译及链接规则，解放了双手。现在我们要在不依赖 IDE 的情况下，手动编写编译规则，大名鼎鼎的 Makefile 便是这样的工具。但很多时候手动编写 Makefile 较为繁琐，工作量很大。所以通常我们会使用更加高级的自动构建工具，比如 **CMake**，同样类似的工具还有 SCons、Waf（APM 项目使用的工具）等等。这里笔者选择使用 CMake，原因很多无需赘述（其实只是因为对 CMake 更熟点），非常多的开源 C/C++ 项目都是基于 CMake 构建的。

CMake 是一个跨平台的自动构建工具，使用简单的描述语句，就能自动生成 Makefile 或其它 project 文件（和 Makefile 同级别的还有 ninja 之类的）。由于 VSCode、CMake 及 gcc 编译工具链都可以跨平台，因此这套开发编译系统同样能在 Windows 下运行，MDK 可以再见了。

## **安装 gcc-arm-none-eabi 交叉编译工具链**

gcc 编译工具链可从下面链接下载，版本的话没有特殊要求，最新的便可以。https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads

Linux 下具体的安装方式可以参考前面一篇博文：[使用 VSCode 打造 APM 飞控的编译 + 烧录 + 调试一体的终极开发环境](https://blog.csdn.net/loveuav/article/details/89969810)。

安装完后在终端中输入`arm-none-eabi-gcc --version`如果正确输出版本信息表示已经安装成功。

## **编写 CMakeLists.txt**

首先到 Github 上把[天穹飞控](https://github.com/loveuav/BlueSkyFlightControl) clone 下来，然后在项目根目录下新建一个 CMakeLists.txt。

由于网上资料丰富，这里就不仔细介绍 CMake 语法了，可自行百度或者谷歌，下面只会简单说明所使用到的 CMake 语句。

### **1. 指定 CMake 版本和工程名字**

```
cmake_minimum_required(VERSION 3.10)
project(BlueSkyPilot)
```

这里指定了项目所需求的 CMake 最低版本，并定义了工程名。

### **2. 设置编译工具链**

由于飞控使用 C 语言编写，因此这里指定 C 编译器为 arm-none-eabi-gcc，注意前面必须要正确安装了编译工具链，CMake 才能识别。

```makefile
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
```

下面还定义了几个需要用到的工具，其中 arm-none-eabi-objcopy 用于输出 bin 文件，arm-none-eabi-size 用于查看文件占用 flash 和 ram 的大小。

```
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_SIZE arm-none-eabi-size)
```

### **3. 添加宏定义**

如果你使用过 MDK 开发 STM32，可能会记得需要添加几个宏定义，这个主要是 STM32 固件库的需求，这里就照搬过来了。

```
add_definitions(
-DSTM32F40_41xxx
-DUSE_STDPERIPH_DRIVER
-DARM_MATH_CM4
)
```

其中 STM32F40_41xxx 指定了所使用的单片机型号（仅跟 STM32 固件库有关系）。

### **4. 设置编译选项**

```makefile
# set(CMAKE_BUILD_TYPE "Debug")
# set(CMAKE_BUILD_TYPE "Release")
set(MCU_FLAGS "-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")
set(CMAKE_C_FLAGS "${MCU_FLAGS} -w -Wno-unknown-pragmas")
set(CMAKE_C_FLAGS_DEBUG "-O0 -g2 -ggdb")
set(CMAKE_C_FLAGS_RELEASE "-O3")
```

**CMAKE_C_FLAGS** 表示编译 C 语言文件时需要附带的编译选项，其中：

- mcpu=cortex-m4 指定 CPU 类型
- mfloat-abi=hard 指定使用硬件浮点单元（即 M4 的 FPU）
- mfpu=fpv4-sp-d16 指定 FPU 的类型
- w 表示不开启警告信息，相对应的是 -Wall，开启所有警告信息

而 **CMAKE_C_FLAGS_DEBUG** 和 **CMAKE_C_FLAGS_RELEASE** 分别是 Debug 模式和 Release 模式下需要附带的编译选项。默认情况下编译器会使用 Debug 模式（但是也不会调用 CMakeLists.txt 中的 Debug 编译选项），因此需要我们在 CMakeLists.txt 中或者运行 CMake 时指定使用哪种编译模式。

在 CMakeLists 中可通过如下语句设置编译模式：`set(CMAKE_BUILD_TYPE "Debug")`或`set(CMAKE_BUILD_TYPE "Release")`

这两种模式区别在于，Debug 模式不会对代码做任何优化，并可以生成汇编文件和 Debug 链接信息，这样才能使用 gdb 工具在线调试代码并设置断点。而 Release 模式可以设置优化级别，能够减小固件体积，并在一定程度上加快代码运行速度。

### **5. 设置头文件路径**

使用 include_directories 语句，设置头文件路径，这样 CMake 才能识别到代码中引用的头文件，如下：

```makefile
include_directories(
    STMLIB
    STMLIB/inc
    STMLIB/CORE
    STMLIB/USB
    STMLIB/USB/STM32_USB_Device_Library/Class/cdc/inc
    STMLIB/USB/STM32_USB_Device_Library/Core/inc
    STMLIB/USB/STM32_USB_OTG_Driver/inc
    STMLIB/SDIO
    FreeRTOS/Source/include
    FreeRTOS/Source/portable/GCC/ARM_CM4F
    FatFs
    MAVLINK
    MAVLINK/common
    SRC/CONTROL
    SRC/DRIVER
    SRC/LOG
    SRC/MATH
    SRC/MESSAGE
    SRC/MODULE
    SRC/NAVIGATION
    SRC/SENSOR
    SRC/SYSTEM
    SRC/TASK
    ${CMAKE_CURRENT_BINARY_DIR}
)
```

### **6. 生成静态库**

gcc 编译器的最终输出有三种：静态库、动态库、可执行文件。其中静态库用于链接生成可执行文件，而动态库在程序运行时才会调用，而单片机上不存在什么动态链接机制，因此这个可以略过。

理论上可以一步直接链接所有 C 源文件，直接生成最终的可执行文件，但当源文件过多时，这样不便于管理，因此笔者选择将一些耦合性较低的单元生成静态库，最终再链接成可执行文件，主要使用到了 **add_library** 这个语句。

比如生成 FreeRTOS 库：

```makefile
add_library(freertos
    FreeRTOS/Source/tasks.c
    FreeRTOS/Source/list.c
    FreeRTOS/Source/queue.c
    FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c
    FreeRTOS/Source/portable/MemMang/heap_4.c
)
```

其中 FreeRTOS 中的 port.c 是针对不同编译器的移植文件，需要选择相对应的版本。

生成 STM32 固件库：

```makefile
add_library(stm32_lib
    STMLIB/startup_stm32f40_41xxx.s
    STMLIB/src/misc.c
    STMLIB/src/stm32f4xx_adc.c
    STMLIB/src/stm32f4xx_can.c
    STMLIB/src/stm32f4xx_dma.c
    STMLIB/src/stm32f4xx_flash.c
    STMLIB/src/stm32f4xx_rcc.c
    STMLIB/src/stm32f4xx_gpio.c
    STMLIB/src/stm32f4xx_tim.c
    STMLIB/src/stm32f4xx_spi.c
    STMLIB/src/stm32f4xx_pwr.c
    STMLIB/src/stm32f4xx_sdio.c
    STMLIB/src/stm32f4xx_usart.c
    STMLIB/src/stm32f4xx_syscfg.c
    STMLIB/system_stm32f4xx.c
    STMLIB/USB/usb_bsp.c
    STMLIB/USB/usbd_desc.c
    STMLIB/USB/STM32_USB_Device_Library/Class/cdc/src/usbd_cdc_core.c
    STMLIB/USB/STM32_USB_Device_Library/Core/src/usbd_ioreq.c
    STMLIB/USB/STM32_USB_Device_Library/Core/src/usbd_req.c
    STMLIB/USB/STM32_USB_Device_Library/Core/src/usbd_core.c
    STMLIB/USB/STM32_USB_OTG_Driver/src/usb_core.c
    STMLIB/USB/STM32_USB_OTG_Driver/src/usb_dcd_int.c
    STMLIB/USB/STM32_USB_OTG_Driver/src/usb_dcd.c
)
```

这里值得注意的是，由于启动文件 startup_stm32f40_41xxx.s 使用的是汇编语言，默认情况下会直接被 CMake 忽略，需要设置该文件属性为 C 语言，即使用 C 编译器去编译该汇编文件：`set_property(SOURCE STMLIB/startup_stm32f40_41xxx.s PROPERTY LANGUAGE C)`这里笔者曾经试过使能 CMake 识别汇编文件，并设置汇编编译器，但编译出错，原因还要待后人来解答。

**另外 STM32 的启动文件是分编译器的，在官方库中能够找到针对不同编译器编写的启动文件，注意区分。**

上面示例的两个静态库都能够单独编译，不依赖外部文件，若是库中使用了外部函数，则需要使用 **target_link_libraries** 来链接外部库，比如编译文件系统库 FatFs 时，需要链接前面编译好的 STM32 固件库：

```makefile
add_library(fatfs
    FatFs/diskio.c
    FatFs/ff.c
    FatFs/option/ccsbcs.c
    STMLIB/SDIO/stm32f4_sdio_sd_LowLevel.c
    STMLIB/SDIO/stm32f4_sdio_sd.c
)
target_link_libraries(fatfs
    stm32_lib
)
```

上面编译静态库时都是直接指定源文件路径，当代码文件较多时，这样操作并不太方便，可以使用 **file** 获取某目录下的文件列表：

```makefile
file(GLOB SRC_DRIVER SRC/DRIVER/*.c)
file(GLOB SRC_CONTROL SRC/CONTROL/*.c)
file(GLOB SRC_LOG SRC/LOG/*.c)
file(GLOB SRC_MATH SRC/MATH/*.c)
file(GLOB SRC_MESSAGE SRC/MESSAGE/*.c)
file(GLOB SRC_MODULE SRC/MODULE/*.c)
file(GLOB SRC_NAVIGATION SRC/NAVIGATION/*.c)
file(GLOB SRC_SENSOR SRC/SENSOR/*.c)
file(GLOB SRC_SYSTEM SRC/SYSTEM/*.c)
file(GLOB SRC_TASK SRC/TASK/*.c)
```

使用上述文件列表编译飞控主体代码

```makefile
add_library(${PROJECT_NAME}
    ${SRC_DRIVER}
    ${SRC_CONTROL}
    ${SRC_LOG}
    ${SRC_MATH}
    ${SRC_MESSAGE}
    ${SRC_MODULE}
    ${SRC_NAVIGATION}
    ${SRC_SENSOR}
    ${SRC_SYSTEM}
    ${SRC_TASK}
)
target_link_libraries(${PROJECT_NAME} -lm
    stm32_lib
    fatfs
    freertos
)
```

这里除了要链接上面编译的所有静态库之外，**使用 -lm 来单独链接 math 库。**

### **7. 设置链接选项**

编译 STM32 程序时，需要链接 ld 文件，主要作用在于告诉编译器单片机的 Flash 和 RAM 大小以及地址分布，这个文件在 ST 提供的 STM32 固件库中可以找到。

```makefile
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/STMLIB/STM32F405RGTx_FLASH.ld)
set(CMAKE_EXE_LINKER_FLAGS
"--specs=nano.specs -specs=nosys.specs -nostartfiles -T${LINKER_SCRIPT} -Wl,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map,--cref -Wl,--gc-sections"
)
```

### **8. 生成可执行文件**

链接主程序入口文件 main.c 和前面生成的静态库，得到 .elf 后缀的可执行文件：

```makefile
add_executable(${PROJECT_NAME}.elf SRC/main.c)
target_link_libraries(${PROJECT_NAME}.elf
    ${PROJECT_NAME}
)
```

### **9. 输出 hex 和 bin 文件**

某些时候可能需要用到 hex 或者 bin 格式的文件，可以使用 arm-none-eabi-objcopy 工具来生成。首先设置文件路径

```makefile
set(ELF_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.elf)
set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)
```

生成 hex 和 bin 文件并输出显示文件大小

```makefile
add_custom_command(TARGET "${PROJECT_NAME}.elf" POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -Obinary ${ELF_FILE} ${BIN_FILE}
    COMMAND ${CMAKE_OBJCOPY} -Oihex  ${ELF_FILE} ${HEX_FILE}
    COMMENT "Building ${PROJECT_NAME}.bin and ${PROJECT_NAME}.hex"

    COMMAND ${CMAKE_COMMAND} -E copy ${HEX_FILE} "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
    COMMAND ${CMAKE_COMMAND} -E copy ${BIN_FILE} "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.bin"

    COMMAND ${CMAKE_SIZE} --format=berkeley ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMENT "Invoking: Cross ARM GNU Print Size"
)
```

## **编译**

至此，CMakeLists.txt 就编写完毕了，可以开始编译飞控代码。首先确认已经安装了 CMake，通过 `cmake --version` 查看当前 CMake 版本。在飞控项目根目录下建立 build 文件夹`mkdir build`进入 build 文件夹，运行 CMake 生成 Makefile 文件

```
cd build
cmake ..

```

也可以附带编译模式选项，选择是编译 Debug 还是 Release 版本`cmake -DCMAKE_BUILD_TYPE=Debug ..`

![https://img-blog.csdnimg.cn/20190925172117867.png](https://img-blog.csdnimg.cn/20190925172117867.png)

Makefile 文件构建完毕后，使用 make 命令编译代码：

```
make -j
```

加上 - j 选项使用多线程编译，实测在笔者的笔记本电脑上只花费了 4 秒，速度还算可以。

出现如下输出便表示编译成功了！

![https://img-blog.csdnimg.cn/20190925172206458.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xvdmV1YXY=,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/20190925172206458.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xvdmV1YXY=,size_16,color_FFFFFF,t_70)

可以看到输出的 bin 文件大小为 247K，如果编译 Release 版本的话，大概只有 200K 左右。

### ***使用 Ninja 代替 make***

Ninja 是一个更加轻量级的编译构建系统，速度比 make 更快，我们可以利用 CMake 生成 Ninja 文件，代替 make，加快编译速度。

### **安装 Ninja**

`sudo apt-get install ninja-build`

### **CMake 生成 Ninja 文件**

`cmake -G Ninja ..`

### **编译**

`ninja`

![https://img-blog.csdnimg.cn/2019101210545077.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xvdmV1YXY=,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/2019101210545077.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xvdmV1YXY=,size_16,color_FFFFFF,t_70)

## **使用 VSCode 烧录和调试 STM32**

使用 OpenOCD，配合 VSCode 的 Cortex-Debug 插件，便能够实现 F5 一键烧录 + 在线调试，可以参考笔者前面写的一篇博文：[使用 VSCode 打造 APM 飞控的编译 + 烧录 + 调试一体的终极开发环境](https://blog.csdn.net/loveuav/article/details/89969810) ，此处就不再赘述了，实际效果如下图：

![https://img-blog.csdnimg.cn/20190925173023616.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xvdmV1YXY=,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/20190925173023616.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xvdmV1YXY=,size_16,color_FFFFFF,t_70)

附上天穹飞控的 Cortex-Debug 配置：

```makefile
{
    "version": "0.2.0",
    "configurations": [
      {
        "name": "Cortex Debug",
        "cwd": "${workspaceRoot}",
        "executable": "./build/BlueSkyPilot.elf",
        "request": "launch",
        "type": "cortex-debug",
        "servertype": "openocd",
        "configFiles": [
          "interface/jlink.cfg",
          "target/stm32f4x.cfg"
        ]
      }
    ]
  }

```

## **Tips**

gcc 编译器不支持原先在 MDK 中使用的__nop () 语句，需要额外加上一个宏定义：

```c
#define __nop() asm("nop")
```

## **附录：完整的 CMakeLists.txt**

可移步 [Github](https://github.com/loveuav/BlueSkyFlightControl) 查看飞控项目最新可用的 CMakeLists.txt：https://github.com/loveuav/BlueSkyFlightControl

```makefile
cmake_minimum_required(VERSION 3.10)
project(BlueSkyPilot)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_SIZE arm-none-eabi-size)

add_definitions(
-DSTM32F40_41xxx
-DUSE_STDPERIPH_DRIVER
-DARM_MATH_CM4
)

#set(CMAKE_BUILD_TYPE "Debug")
#set(CMAKE_BUILD_TYPE "Release")
set(MCU_FLAGS "-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")
set(CMAKE_C_FLAGS "${MCU_FLAGS} -w -Wno-unknown-pragmas")
set(CMAKE_C_FLAGS_DEBUG "-O0 -g2 -ggdb")
set(CMAKE_C_FLAGS_RELEASE "-O3")

include_directories(
    STMLIB
    STMLIB/inc
    STMLIB/CORE
    STMLIB/USB
    STMLIB/USB/STM32_USB_Device_Library/Class/cdc/inc
    STMLIB/USB/STM32_USB_Device_Library/Core/inc
    STMLIB/USB/STM32_USB_OTG_Driver/inc
    STMLIB/SDIO
    FreeRTOS/Source/include
    FreeRTOS/Source/portable/GCC/ARM_CM4F
    FatFs
    MAVLINK
    MAVLINK/common
    SRC/CONTROL
    SRC/DRIVER
    SRC/LOG
    SRC/MATH
    SRC/MESSAGE
    SRC/MODULE
    SRC/NAVIGATION
    SRC/SENSOR
    SRC/SYSTEM
    SRC/TASK
    ${CMAKE_CURRENT_BINARY_DIR}
)

set_property(SOURCE STMLIB/startup_stm32f40_41xxx.s PROPERTY LANGUAGE C)

add_library(stm32_lib
    STMLIB/startup_stm32f40_41xxx.s
    STMLIB/src/misc.c
    STMLIB/src/stm32f4xx_adc.c
    STMLIB/src/stm32f4xx_can.c
    STMLIB/src/stm32f4xx_dma.c
    STMLIB/src/stm32f4xx_flash.c
    STMLIB/src/stm32f4xx_rcc.c
    STMLIB/src/stm32f4xx_gpio.c
    STMLIB/src/stm32f4xx_tim.c
    STMLIB/src/stm32f4xx_spi.c
    STMLIB/src/stm32f4xx_pwr.c
    STMLIB/src/stm32f4xx_sdio.c
    STMLIB/src/stm32f4xx_usart.c
    STMLIB/src/stm32f4xx_syscfg.c
    STMLIB/system_stm32f4xx.c
    STMLIB/USB/usb_bsp.c
    STMLIB/USB/usbd_desc.c
    STMLIB/USB/STM32_USB_Device_Library/Class/cdc/src/usbd_cdc_core.c
    STMLIB/USB/STM32_USB_Device_Library/Core/src/usbd_ioreq.c
    STMLIB/USB/STM32_USB_Device_Library/Core/src/usbd_req.c
    STMLIB/USB/STM32_USB_Device_Library/Core/src/usbd_core.c
    STMLIB/USB/STM32_USB_OTG_Driver/src/usb_core.c
    STMLIB/USB/STM32_USB_OTG_Driver/src/usb_dcd_int.c
    STMLIB/USB/STM32_USB_OTG_Driver/src/usb_dcd.c
)

add_library(freertos
    FreeRTOS/Source/tasks.c
    FreeRTOS/Source/list.c
    FreeRTOS/Source/queue.c
    FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c
    FreeRTOS/Source/portable/MemMang/heap_4.c
)

add_library(fatfs
    FatFs/diskio.c
    FatFs/ff.c
    FatFs/option/ccsbcs.c
    STMLIB/SDIO/stm32f4_sdio_sd_LowLevel.c
    STMLIB/SDIO/stm32f4_sdio_sd.c
)
target_link_libraries(fatfs
    stm32_lib
)

file(GLOB SRC_DRIVER SRC/DRIVER/*.c)
file(GLOB SRC_CONTROL SRC/CONTROL/*.c)
file(GLOB SRC_LOG SRC/LOG/*.c)
file(GLOB SRC_MATH SRC/MATH/*.c)
file(GLOB SRC_MESSAGE SRC/MESSAGE/*.c)
file(GLOB SRC_MODULE SRC/MODULE/*.c)
file(GLOB SRC_NAVIGATION SRC/NAVIGATION/*.c)
file(GLOB SRC_SENSOR SRC/SENSOR/*.c)
file(GLOB SRC_SYSTEM SRC/SYSTEM/*.c)
file(GLOB SRC_TASK SRC/TASK/*.c)

add_library(${PROJECT_NAME}
    ${SRC_DRIVER}
    ${SRC_CONTROL}
    ${SRC_LOG}
    ${SRC_MATH}
    ${SRC_MESSAGE}
    ${SRC_MODULE}
    ${SRC_NAVIGATION}
    ${SRC_SENSOR}
    ${SRC_SYSTEM}
    ${SRC_TASK}
)
target_link_libraries(${PROJECT_NAME} -lm
    stm32_lib
    fatfs
    freertos
)

set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/STMLIB/STM32F405RGTx_FLASH.ld)
set(CMAKE_EXE_LINKER_FLAGS
"--specs=nano.specs -specs=nosys.specs -nostartfiles -T${LINKER_SCRIPT} -Wl,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map,--cref -Wl,--gc-sections"
)

add_executable(${PROJECT_NAME}.elf SRC/main.c)
target_link_libraries(${PROJECT_NAME}.elf
    ${PROJECT_NAME}
)

set(ELF_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.elf)
set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

add_custom_command(TARGET "${PROJECT_NAME}.elf" POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -Obinary ${ELF_FILE} ${BIN_FILE}
    COMMAND ${CMAKE_OBJCOPY} -Oihex  ${ELF_FILE} ${HEX_FILE}
    COMMENT "Building ${PROJECT_NAME}.bin and ${PROJECT_NAME}.hex"

    COMMAND ${CMAKE_COMMAND} -E copy ${HEX_FILE} "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
    COMMAND ${CMAKE_COMMAND} -E copy ${BIN_FILE} "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.bin"

    COMMAND ${CMAKE_SIZE} --format=berkeley ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMENT "Invoking: Cross ARM GNU Print Size"
)
```