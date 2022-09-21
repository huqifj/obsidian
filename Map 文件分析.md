# Map 文件分析

**Map 文件分为五个部分：**

- Section Cross References（交叉引用关系）
- Removing Unused input sections from the image（移除的未使用部分）
- Image Symbol Table（符号映射表）
- Memory Map of the image：（内存映射表）
- Image component sizes：（镜像组件大小）

## Section Cross References（交叉引用关系）

描述模块和模块之间的相互引用关系。

## Removing Unused input sections from the image（移除的未使用部分）

移除未使用的功能已减小程序体积，最后列出统计信息。

## Image Symbol Table（符号映射表）

符号映射表，列出每个符号在所在段的相对地址。分为 Local Symbols 和 Global Symbols。

**Local Symbols 记录了：**

- static 全局变量的地址和大小
- static 函数的地址和大小

**Global Symbols 记录了：**

- 全局变量的地址和大小
- 函数的地址和大小
- 汇编文件中标签的地址

**相关名词：**

- Symbol Name：符号名称
- Value：地址
- Ov Type：类型（Number、Section、Thumb Code、Data）
- Size：大小
- Object(Section)：模块

## Memory Map of the image（镜像内存映射）

映像文件可以分为加载域（Load Region）和运行域（Execution Region）。

Image Entry point : 0x080000c1 **指映射地址入口，程序从这里开始运行**。

- **加载域**
    
    Load Region LR_IROM1 (Base: 0x08000000, Size: 0x00003018, Max: 0x00010000, ABSOLUTE)
    
    加载域开始地址 0x08000000，大小 0x00003018，区域大小为 0x00010000。
    
- **执行域一**
    
    Execution Region ER_IROM1 (Exec base: 0x08000000, Load base: 0x08000000, Size: 0x0000300c, Max: 0x00010000, ABSOLUTE)
    
    执行域 ER_IROM1。执行地址 0x08000000，加载地址 0x08000000，大小 0x0000300C，区域大小 0x00010000。
    
- **执行域二**
    
    Execution Region RW_IRAM1 (Exec base: 0x20000000, Load base: 0x08003010, Size: 0x00000530, Max: 0x00004000, ABSOLUTE)
    
    执行域 RW_IRAM1。执行地址 0x20000000，加载地址 0x8003010，大小 0x00000530，区域大小 0x00004000。
    

**相关名词：**

- Exec Addr：执行地址，可能在 ROM 或 RAM
- Load Addr：加载地址
- Size：存储大小
- Type：类型（Data、Code、Zero、PAD）
- Attr：属性（RO、RW）
- Section Name：段名
- Object：目标

## Image component sizes（镜像组件占用）

**Object Name**、**Library Member Name**、**Library Name** 三大分类的各个 .o 文件（编译输出文件）所占用的 Code、RO Data、RW Data、ZI Data、Debug 类型所占用的空间。

**相关名词：**

- Code：代码
- inc.data：代码中的内联数据（文字池、短字符串）
- RO Data：只读数据
- RW Data：可读写数据
- ZI Data：初始化为 0 的数据
- Debug：显示调试数据占用，例如调试输入节和符号和字符串表。
- Grand Totals：镜像大小
- ELF Image Totals：ELF(Executable and Linking Format) 可执行链接格式镜像大小
- ROM Totals：所需最小 ROM 空间（不包含 Debug 信息和 ZI Data）

## 参考

[Analysis of MAP file in STM32 KEIL](https://blog.karatos.in/a?ID=00600-5b9c135d-31d4-4dd9-8154-9af0c892763e)

[STM32 Keil生成的map文件分析_丨匿名用户丨的博客-CSDN博客](https://blog.csdn.net/p1279030826/article/details/105411355)

[Keil综合（03）_map文件全解析_strongerHuang的博客-CSDN博客_keil map文件分析](https://blog.csdn.net/ybhuangfugui/article/details/75948282)