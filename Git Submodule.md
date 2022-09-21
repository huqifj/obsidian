# Submodule

## 基本命令

拉取一个带有 submodule 的仓库后，需要执行：

```bash
git submodule init
git submodule update

# 或者
git submodule update --init --recursive

# 或者在 clone 时添加选项
git clone <repo> --recurse-submodules
```

## 添加 submodule：

```bash
git submodule add https://github.com/spencermountain/spacetime.git [path]
```

## 删除 submodule：

1. 执行命令并 commit，这会删除文件树 <path-to-submodule> 和 submodule 在 .gitmodules 文件中的入口，也就是说，所有对此 submodule 的跟踪都会被移除：
    
```bash
git rm <path-to-submodule>
git commit -m "..."
```
    
2. 但是 .git 目录里的 submodule 还会被保留（.git/submodules/），这是为了可以 checkout 到过去的 commits 而不需要再次 fetch。
如果仍然想要删除这些信息，可以手动删除 .git/modules/ 和 .git/config 中的 submodle 入口。也可以通过以下命令自动删除：
    
```bash
rm -rf .git/modules/<path-to-submodule>
git config --remove-section submodule.<path-to-submodule>.
```