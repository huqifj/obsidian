# LLVM/Clang

## LLVM

LLVM 将传统的编译过程拆分成了前端、优化器和后端三个部分。

- 前端是预处理、词法分析、语法分析、生成抽象语法树（AST）和产生中间表示（IR）的过程。
- 中间优化器则是对 IR 进行优化处理的过程。
- 后端是根据中间表示（IR）生成最终目标平台的机器语言的过程。

![Untitled](assets/LLVM%20Clang/Untitled.png)

这样做的好处是可以对编译过程进行解耦，当增加对一门语言的支持时，只需要增加一个前端（FrontEnd）；当需要增加一个编译的目标平台时，则只需要增加一个后 (BackEnd）；优化器无关乎语言和平台，只在中间表示（IR）的层面上进行。

## Clang

Clang 是一个 C、C++、Objective-C、Objective-C++ 编程语言的编译器前端，使用 LLVM 作为后端。