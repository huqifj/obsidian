需要安装 Python3.10 或更新版本。

以下操作使用 Windows PowerShell。

## 克隆仓库
1. 克隆仓库 `git clone http://192.168.1.24:11030/huqf/ev.git`，可能会提示输入登录信息，按照提示操作即可（注意密码输入时是没有回显的），克隆后默认处于主分支（main）；
2. 初始化子模块 `git submodule init`；
3. 更新子模块 `git submodule update`。

## 创建配置文件
创建 hcibuild.ini 配置文件，存放在工程根目录下，示例：
```
[Configuration]
; MDK 程序
mdk_exe = C:/Keil_v5/UV4/UV4.exe

; 工程文件
uv_pro = ./project.uvprojx

; rt-thread 软件包目录
pkgs_dir = ./packages-index

; 定义主板型号的头文件
mb_def_file = ./rtconfig.h

; 编译生成的 bin 文件路径
bin_path = ./hci.bin

; 编译生成的 hex 文件路径
hex_path = ./build/rtthread-n32g45x.hex

; CHANGELOG 文件路径
changelog_path = ./CHANGELOG.txt

; 固件存储路径
fw_dir = D:/hci/Firmware/

; boot 文件路径
eb04v1_boot = D:/hci/Firmware/boot/eb04v1
eb04v2_boot = D:/hci/Firmware/boot/eb04v2
eb12v1_boot = D:/hci/Firmware/boot/eb12v1
eb16v1_boot = D:/hci/Firmware/boot/eb16v1
eb16v2_boot = D:/hci/Firmware/boot/eb16v2
ev01v1_boot = D:/hci/Firmware/boot/ev01v1
ev01v2_boot = D:/hci/Firmware/boot/ev01v2
ev01v3_boot = D:/hci/Firmware/boot/ev01v3
ev01v4_boot = D:/hci/Firmware/boot/ev01v4
ev02v1_boot = D:/hci/Firmware/boot/ev02v1
ev02v2_boot = D:/hci/Firmware/boot/ev02v2
```

## 配置工程
执行 `./hcibuild.exe` 配置工程。如果提示错误，一般是缺少相关 python 包，按照提示安装相应软件包即可。例如：
```python
pip install kconfiglib
pip install windows-curses
pip install SCons
```

成功执行时界面如图所示：
```
1. 配置 & 构建工程
2. 打包固件（不重新编译）
3. 配置 & 构建 & 编译 & 打包固件
q. 退出
Input:
```
选择选项 1。

跳转到如下界面:
```
RT-Thread Kernel  --->
RT-Thread Components  --->
RT-Thread online packages  --->
Onchip peripheral  --->
HCI Configuration  --->
```
选择 HCI Configuration。

跳转到如下界面：
```
Select Mother Board (Using EV02V2)  --->
[ ] Using YKCCN QR Code
[ ] Using LEYAOYAO QR Code
[*] Using LCD
[*] Using LED
	LED Board (Using LED_V1)  --->
[ ] Using second server
```
选择 Select Mother Board。

跳转到如下界面：
```
( ) Using EV01V1
( ) Using EV01V2
( ) Using EV01V3
( ) Using EV01V4
( ) Using EV02V1
(X) Using EV02V2
```

根据实际情况选择主板，然后按 ESC 保存并退出，程序会自动构建对应主板的 Keil 工程。

## 编译
打开工程根目录下 project.uvprojx 编译即可。

