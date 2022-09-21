# Python 批量导入/导出依赖


# 使用 pipreqs

1. 安装批量导出软件包
    
    `pip install pipreqs`
    
2. 导出依赖
    
    首先尝试 `pipreqs ./` ，如果失败，可尝试 `pipreqs ./ --encoding=utf8` ，如果失败，请检查系统是否开启了代理。
    
    导出成功会在指定目录生成 requirements.txt 文件
    
3. 导入依赖
    
    `pip install -r requirements.txt`
    

## 使用 freeze

`pip freeze | Out-File -Encoding UTF8 requirements.txt`