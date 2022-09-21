# Python venv

## 虚拟环境示意图

## 创建虚拟环境

`python3 -m venv /path/to/new/virtual/environment`

## 激活虚拟环境

`myenv\Scripts\activate.bat`

## 关闭虚拟环境

`deactivate`

## 保存虚拟环境

`pip freeze >requirements.txt`

## 打开虚拟环境下的IDLE

`python -m idlelib.idle`

## 打包 Exe

```python
Pyinstaller -F [setup.py] # 打包 exe

Pyinstaller -F -w [setup.py] # 不带控制台的打包

Pyinstaller -F -i xx.ico [setup.py] # 打包指定 exe 图标打包
```