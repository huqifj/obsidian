# Git


[Submodule](Git%20Submodule.md)

[Stash](Git%20Stash.md)

[Rebase VS Merge](Rebase%20VS%20Merge.md)

## 基本

```bash
git config --global user.name "username"
git config --global user.email "email"

ssh-keygen -t rsa -C "youremail@xxx.com"
```

## 推送

```bash
git push <远程主机名> <本地分支名>:<远程分支名>
git push <远程主机名> <分支名>  # 本地分支名和远程分支名相同时
```

## 拉取

```bash
git pull <远程主机名> <远程主机名>:<本地分支名>

# 拉取本地不存在的分支
git checkout -b 本地分支名 origin/远程分支名
```

## 删除远程分支

```bash
# 删除远程分支
git push origin --delete branch_name
```

## ****显示所有文件存在 modify 解决办法****

```bash
git config --global core.filemode false
git config --global core.autocrlf true  # windows
git config --global core.autocrlf input # linux
```

## 取消跟踪已跟踪文件

```python
git rm --cached <file>
git commit -m "commit info"
```

## 清除无效远程分支

```python
git remote show origin
git remote prune origin
```

## 更改远程仓库地址

```bash
git remote set-url name url
```

## CRLF

```bash
// 提交时转换为 LF，检出时转换为 CRLF（Windows 下用这个）
git config --global core.autocrlf true   

// 提交时转换为 LF，检出时不转换（Linux 下用这个）
git config --global core.autocrlf input   

// 提交检出均不转换（不包含 Linux 和 Windows 协同用这个）
git config --global core.autocrlf false
```

## 删除所有空白字符改变

```bash
# 提交所有非 white sapce diff change
git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -
# 将所有 white space diff files 恢复
git checkout .
```

## theirs vs ours
对于 merge 和 rebase 来说，这两个选项对应的分支正好是相反的。以上述示例项目为例。在使用 merge 时，ours 指的是当前分支，即 branch_a，theirs 指的是要被合并的分支，即 branch_b。而在 rebase 的过程中，theirs 指的是当前分支，即 branch_a，ours 指向修改参考分支，即 branch_b。

> merge 时：ours 指当前分支
> rebase 时，ours 指参考分支

这么容易混淆的概念记不住？ 没关系，我个人还有另一个比较直观的办法，就是直接查看冲突文件中的冲突标记。在进入冲突状态后，git 会将冲突的代码用 <<<<<<< ======= >>>>>>> 标识出来，方便我们手动解决。在冲突标记中，======= 之前表示的是 ours 分支，之后表示 theirs 分支，只需要查看某一处冲突代码即可判断出要保留的分支。

## 推送 tag
推送一个 tag
```git
git push <remote> <tagname>
```

推送所有 tags
```git
git push origin --tags
```
