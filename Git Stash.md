# Stash

```bash
# 将工作区和暂存区保存到堆栈中
git stash

# 和 git stash 一样，只是可以添加注释
git stash save

# 查看 stash 中的内容
git stash list

# 从堆栈（先进后出）弹出一次 stash 内容到当前分支，同时删除该 stash
git stash pop

# 和 git stash pop 一样，只是不会删除堆栈
git stash apply

# 删除指定堆栈内容
git stash drop

# 清理所有堆栈内容
git stash clear

# 查看差异
git stash show
```