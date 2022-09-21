# Rebase VS Merge

# 变基的含义

先看一个简单例子。

假设我们有两条分支，一条名为 master 主分支，master 上有 a、b、c、d 四次提交，另一条为 develop 开发分支，develop **基于**提交 a，如下图所示：

![image_20201217095949.png](image_20201217095949.png)

如果我们想把 develop 从**基于 a** 改为**基于 master（即 d 提交）**，可以在 **develop** 分支上使用命令 `git rebase`，命令执行如下图所示：

![image_20201217095859.png](image_20201217095859.png)

可见执行命令后，develop 变为了基于 d。

上述即为“变基”的过程。git rebase 的中文翻译叫做“变基”，其中“基”的含义可以理解为当前开发“基于”哪一次提交，而“变基”的意思就是改变当前分支的“基”。

## 带有提交的变基

假设有两个分支，分别是 master 和 develop，它们都基于提交 a，如下图所示：

![image_20201217142422.png](image_20201217142422.png)

分支 master 和分支 develop 都在 a 的基础上，其实日常开发中很容易出现这种状态，即甲从服务器上拉取最新代码进行开发，在甲开发期间乙往服务器提交了一些代码，此时 git 的状态和上图类似。

在 develop 分支开发完毕后，如果要将自己的开发成果合并到 master，有以下两种做法：

1. merge：在 master 分支上执行 `git merge develop`
2. rebase：在 develop 分支上执行 `git rebase master`

分别来看两种做法的效果：

### merge

1. 在 master 执行 `git merge develop`
2. 解决冲突（因为编辑了同一个文件）
3. 使用 `git add`  添加解决了冲突的文件
4. 使用 `git commit`  产生一次新的提交已完成 merge 流程，此次 merge 默认的 commit message 是“[master e6c62d9] Merge branch 'develop' into master”

merge 流程结束后，分支如下图所示，产生了一次**额外的提交记录**：

![image_20201217143531.png](image_20201217143531.png)

### rebase

1. 在 develop 执行 `git rebase master`
2. 解决冲突
3. 使用 `git add`  添加解决了冲突的文件
4. 使用 `git rebase --continue`  完成 rebase

rebase 流程结束后，分支如下图所示：

![image_20201217153033.png](image_20201217153033.png)

可见此时 develop 和 master 的关系已经处于 fast-forward 状态，即不会产生新的提交记录了。

### 小结

通过上述 merge 和 rebase 的对比，可发现适当使用 rebase 有助于打造简洁愉悦的提交记录。

## 浓缩多次提交

假设目标是开发一个功能 A，本地开发时，研发人员常常会将任务分割为更小的阶段，多次提交，如下图所示：

![image_20201217155531.png](image_20201217155531.png)

而在将代码提交到服务器时，研发人员往往不希望有那么多杂乱的提交记录。使用 rebase 可以帮助我们做到这点：

![image_20201217164616.png](image_20201217164616.png)

如上图所示，执行命令 git rebase -i