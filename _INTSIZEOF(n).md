# _INTSIZEOF(n)

## 1. 作用

`_INTSIZEOF(n)` 返回类型 n 占用的字节数，并且返回值为 `sizeof(int)` 的整数倍。换句话说，设空间最小粒度为 `sizeof(int)`，返回类型 n 占用的字节数。

```
#define _INTSIZEOF(n) ((sizeof(n) + sizeof(int) - 1) & ~(sizeof(int) - 1))

```

## 2. 解析

假设 n 类型占用的字节数是 y，`sizeof(int)` 的值为 x，则 `_INTSIZEOF(n)` 返回的值 z 计算如下：

```
if (y % x == 0) {	// 余数为零
    z = （y / x） * x;	// 式一
} else {			// 余数不为零
    z = ((y / x) + 1) * x;	// 式二
}

```

C 语言中的宏定义为何能得出和上述式子同样的结果呢？

我们的代码中使用条件分支来计算两种情况，如果不允许使用条件分支，则需要给**式一**中的 y 加上一个值 f：

```
z = ((y + f) / x) * x; // 式三

```

考虑 f 的范围：

```
// 余数
m = y % x;

if (m == 0) {
    // m 为 0 时，f 必须小于 x
} else if (m == 1) {
    // m 为 1 时，f 必须满足 1 + f >= x，即 f >= x - 1
} else {
	// m 为其他值时，f 必须满足 m + f >= x，即 f >= x - m
}

```

综合上述代码，取交集，得到 `f = x - 1`，将 f 代入式三中，得到 `z = ((y + x - 1) / x) * x`。

在 C 语言中，x 必定为 2^k，因此上式可以写成 `z = ((y + x - 1) >> k) << k`，这个移位操作相当于将 `(y + x -1)` 结果的低 k 位清零，也就是宏定义：

```
#define _INTSIZEOF(n) ((sizeof(n) + sizeof(int) - 1) & ~(sizeof(int) - 1))

```