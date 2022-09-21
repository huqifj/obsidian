# 右左原则——解析 C 语言声明


## 说明

本文仅为整理翻译。英文原文： [http://cseweb.ucsd.edu/~ricko/rt_lt.rule.html](http://cseweb.ucsd.edu/~ricko/rt_lt.rule.html)

「右左原则」是一种用来解译 C 语言声明的规则，它十分有规律。你也可以使用右左原则来帮助创建 C 语言声明。

本文介绍右左原则，并结合一些例子进行说明。读完本文之后，一切 C 语言声明对你将变得一目了然。

## 规则

首先，请看下表，在声明中遇到以下符号时，将他们以规定的读法读出来：

| 符号 | 读作 |
| ---- | ---- |
| *    |指针，指向……      |
| []   |      数组，元素为……|
| ()     |      函数，返回……|

运用以上规则，我们执行以下步骤：

- STEP1

找到你想解译的标识符，这是你的起点。然后，把标识符读作：「标识符是……」。例如：

```
int a; // a 是……
```

- STEP2

使用前面说的规则，查看标识符「右侧」的符号。

现在，假设你遇到「圆括号对」，那么你知道这个是一个函数。于是，你就说：「标识符是『函数，返回……』」。例如：

```
int a(); // a 是函数，返回……
```

或者，假设你遇到了「方括号对」，那么你就说：「标识符是『数组，元素为……』」。例如：

```
int a[]; // a 是数组，元素为……
```

继续向右扫描直到结束，或直到遇到「右圆括号」时，跳转到 STEP3。

（如果你遇到「左圆括号」，那只是「圆括号对」的开始，圆括号对里面可能有其它内容，这里我们先忽略它们，后文再对它们进行讲解。）

- STEP3

使用前面说的规则，查看标识符「左侧」的符号。

假设遇到的符号没有列在前面的列表中，那无需处理，直接读出来就行（例如「int」），直接读出来。

如果遇到了列表中的符号，那么就按列表的规则将它们读出来。

一直向左扫描直到结束，或直到遇到「左圆括号」，跳转到 STEP2。

重复「STEP2」和「STEP3」直到你的声明产生。

## 例子

### 例子之一
```
int *p[];

1) 找到标识符：
                             int *p[];
                                  ^
   「p 是……」

2) 向右扫描直到结束，或直到遇到「右圆括号」：
                             int *p[];
                                   ^^
   「p 是数组，元素为……」

3) 向右扫描结束，因此开始向左扫描：
                             int *p[];
                                 ^
   「p 是数组，元素为指针，指向……」

4) 继续向左扫描:
                             int *p[];
                             ^^^

   「p 是数组，元素为指针，指向 int」
   （或「p 是数组，每个数组元素为 int 类型的指针」）
```

### 例子之二

```
int *(*func())();

1) 找到标识符：
                             int *(*func())();
                                    ^^^^
   「func 是……」

2) 向右扫描：
                             int *(*func())();
                                        ^^
   「func 是函数，返回……」

3) 因为遇到「右圆括号」，因此开始向左扫描：
                             int *(*func())();
                                   ^
   「func 是函数，返回指针，指向……」

4) 因为遇到「左圆括号」，因此开始向右扫描：
                             int *(*func())();
                                           ^^
   「func 是函数，返回指针，指向函数，函数返回……」

5) 因为扫描到了尽头，因此开始向左扫描：
                             int *(*func())();
                                 ^
   「func 是函数，返回指针，指向函数，函数返回指针，指向……」

6) 最后，继续向左扫描：
                             int *(*func())();
                             ^^^
   「func 是函数，返回指针，指向函数，返回指针，指向 int」
```

如你所见，右左原则十分有用。在你创建声明时，你也可以使用这个规则来检查你的声明是否正确。此外，右左原则还可以提示你下一个符号应该放在哪里，或者声明中是否需要括号。

有些声明看起来比实际复杂，可能是因为数组包含了长度，或是函数包含了参数列表。例如：

```
[3]           // 读作：数组（长度为 3），元素为……
(char *, int) // 读作：函数，形参为 (char *, int)，返回……
```

一个实际的例子：

```
int (*(*fun_one)(char *,double))[9][20];
```

我不再列出每个步骤来解析它，好吧，它是：「func_one 是指针，指向函数，函数的形参为 `(char *, double)`，返回指针，指针指向数组（大小 9），元素为数组（大小 20），元素为 int」。

如你所见，如果你去除掉数组大小和参数列表，它并不复杂：

```
int (*(*fun_one)())[][];
```

你也可以先以上述简单的形式解析声明，然后再把数组大小和形参列表加上去。

## 非法声明

使用右左原则很有可能创建出「非法的」声明，因此你需要知道 C 语言中怎样的声明才是合法的。举个例子，如果上面的 `fun_one` 变成这样：

```
int *((*fun_one)())[][];
```

它将会被解析为：「fun_one 是指针，指向函数，返回数组，元素为数组，元素为指针，指向 int」。因为函数不能返回一个「数组」，只能返回「指向数组的指针」，因此这个声明是非法的。

非法的组合包括：

```
[]() - 无法声明元素为函数的数组
()() - 无法声明返回函数的函数
()[] - 无法声明返回数组的函数
```

在上面的情形，你可以添加一对「圆括号」和一个「*」，把非法的「数组」或「函数」变为合法的「指针，指向数组」或「指针，指向函数」，使得声明合法：

```
(*[])() - 数组，元素为函数指针
(*())() - 函数，返回函数指针
(*())[] - 函数，返回指向数组的指针
```

## 更多例子

下面是一些合法的和非法的声明例子：

```
int i;                  // an int
int *p;                 // an int pointer (ptr to an int)
int a[];                // an array of ints
int f();                // a function returning an int
int **pp;               // a pointer to an int pointer (ptr to a ptr to an int)
int (*pa)[];            // a pointer to an array of ints
int (*pf)();            // a pointer to a function returning an int
int *ap[];              // an array of int pointers (array of ptrs to ints)
int aa[][];             // an array of arrays of ints
int af[]();             // an array of functions returning an int (ILLEGAL)
int *fp();              // a function returning an int pointer
int fa()[];             // a function returning an array of ints (ILLEGAL)
int ff()();             // a function returning a function returning an int(ILLEGAL)
int ***ppp;             // a pointer to a pointer to an int pointer
int (**ppa)[];          // a pointer to a pointer to an array of ints
int (**ppf)();          // a pointer to a pointer to a function returning an int
int *(*pap)[];          // a pointer to an array of int pointers
int (*paa)[][];         // a pointer to an array of arrays of ints
int (*paf)[]();         // a pointer to a an array of functions returning an int(ILLEGAL)
int *(*pfp)();          // a pointer to a function returning an int pointer
int (*pfa)()[];         // a pointer to a function returning an array of ints(ILLEGAL)
int (*pff)()();         // a pointer to a function returning a functionreturning an int (ILLEGAL)
int **app[];            // an array of pointers to int pointers
int (*apa[])[];         // an array of pointers to arrays of ints
int (*apf[])();         // an array of pointers to functions returning an int
int *aap[][];           // an array of arrays of int pointers
int aaa[][][];          // an array of arrays of arrays of ints
int aaf[][]();          // an array of arrays of functions returning an int(ILLEGAL)
int *afp[]();           // an array of functions returning int pointers (ILLEGAL)
int afa[]()[];          // an array of functions returning an array of ints(ILLEGAL)
int aff[]()();          // an array of functions returning functionsreturning an int (ILLEGAL)
int **fpp();            // a function returning a pointer to an int pointer
int (*fpa())[];         // a function returning a pointer to an array of ints
int (*fpf())();         // a function returning a pointer to a functionreturning an int
int *fap()[];           // a function returning an array of int pointers (ILLEGAL)
int faa()[][];          // a function returning an array of arrays of ints(ILLEGAL)
int faf()[]();          // a function returning an array of functionsreturning an int (ILLEGAL)
int *ffp()();           // a function returning a functionreturning an int pointer (ILLEGAL)
```