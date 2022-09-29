# Python Poetry

## 安装

[参考链接](https://python-poetry.org/docs/master/#installing-with-the-official-installer)

PowerShell 命令：

```powershell
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py - --version 1.2.0b2
```

以上命令将会：

1. 使用 `venv` 创建虚拟环境（%APPDATA%\\pypoetry）
2. 在上述虚拟环境安装最新版本或指定版本的 Poetry
3. 在 Python 用户目录（`C:\\Users\\chuan\\AppData\\Roaming\\Python`）安装 poetry 脚本

poetry.exe 路径为 C:\Users\huqf\AppData\Roaming\Python\Scripts

## 卸载

在安装脚本添加后缀 `--uninstall` 即可:
```powershell
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py - --version 1.2.0b2 --uninstall
```

## 使用

### 初始化

命令：`poetry new poetry-demo`，执行后将创建 poetry-demo 文件夹。

查看目录树：`tree /f /a`

```powershell
PS C:\Users\chuan\Documents\hci_cpa> tree /f /a
文件夹 PATH 列表
卷序列号为 3E99-2EE4
C:.
\---poetry-demo
    |   pyproject.toml
    |   README.rst
    |
    +---poetry_demo
    |       __init__.py
    |
    \---tests
            test_poetry_demo.py
            __init__.py
```

### 指定虚拟环境路径

在 Windows 中，poetry 创建的虚拟环境默认路径是 **{cache-dir}\virtualenvs**。使用以下命令可以配置为在 **当前目录** 下创建虚拟环境：

```powershell
cd poetry-demo
poetry config virtualenvs.in-project true --local
```

其中 `--local` 关键字说明此设置只对本目录有效。

### 查看所有配置项

`poetry config --list`

### 指定依赖版本

```python
[tool.poetry.dependencies]
python = ">=3.10, <3.11"
pendulum = "^2.1.2"
PySide6 = "^6.3.1"
```

### 初始化 ENV

以下命令将会创建 python 虚拟环境：
```powershell
poetry install
```

### 添加并安装依赖

- 方式一：在 pyproject.toml 文件中添加依赖，然后使用命令 `poetry install`
- 方式二：`poetry add pyside6`

### 使用虚拟环境

- 方式一：添加命令前缀 `poetry run` ，例如 `poetry run python your_script.py` 或 `poetry run pytest` 。
- 方式二：`poetry shell` 使用虚拟环境 shell，使用 exit 退出。

### 查看虚拟环境

`poetry env info`

```powershell
PS C:\Users\chuan\Documents\My_Code\hci_cpa> poetry env info

Virtualenv
Python:         3.10.4
Implementation: CPython
Path:           C:\Users\chuan\Documents\My_Code\hci_cpa\.venv
Executable:     C:\Users\chuan\Documents\My_Code\hci_cpa\.venv\Scripts\python.exe
Valid:          True

System
Platform:   win32
OS:         nt
Python:     3.10.4
Path:       C:\Users\chuan\AppData\Local\Programs\Python\Python310
Executable: C:\Users\chuan\AppData\Local\Programs\Python\Python310\python.exe
PS C:\Users\chuan\Documents\My_Code\hci_cpa>
```

### 删除虚拟环境

1. 使用 `poetry env info` 查看虚拟机地址
2. 从指定删除虚拟机目录

## 常见问题

### 修改默认 SHELL

- 使用 Poetry (version 1.2.0b2)。
- 设置环境变量 SHELL 为 PowerShell 可执行文件地址。PowerShell 的地址为 %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe

### 无法加载 Activate.ps1

管理员方式打开 PowerShell，执行 `Set-ExecutionPolicy RemoteSigned`

```powershell
Windows PowerShell
版权所有 (C) Microsoft Corporation。保留所有权利。
 
尝试新的跨平台 PowerShell https://aka.ms/pscore6
 
PS C:\Windows\system32> Set-ExecutionPolicy RemoteSigned
 
执行策略更改
执行策略可帮助你防止执行不信任的脚本。更改执行策略可能会产生安全风险，如 https:/go.microsoft.com/fwlink/?LinkID=135170
中的 about_Execution_Policies 帮助主题所述。是否要更改执行策略?
[Y] 是(Y)  [A] 全是(A)  [N] 否(N)  [L] 全否(L)  [S] 暂停(S)  [?] 帮助 (默认值为“N”): Y
```

Policy 的有效参数:
- Restricted: 不载入任何配置文件，不运行任何脚本。 "Restricted" 是默认的。
- AllSigned: 只有被 Trusted publisher 签名的脚本或者配置文件才能使用，包括你自己再本地写的脚本。
- RemoteSigned: 对于从 Internet 上下载的脚本或者配置文件，只有被 Trusted，publisher 签名的才能使用。
- Unrestricted: 可以载入所有配置文件，可以运行所有脚本文件。如果你运行一个从 internet 下载并且没有签名的脚本，在运行之前，你会被提示需要一定的权限。
- Bypass: 所有东西都可以使用，并且没有提示和警告。
- Undefined: 删除当前 scope 被赋予的 ExecutionPolicy，但是 Group Policy scope 的 Execution Policy 不会被删除。
