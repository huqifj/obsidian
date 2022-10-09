# Python 装饰器（Decorator）
## 函数也是对象
```python
def hello():
    print('hello')

    
f = hello
f()
hello

hello.__name__
'hello'
f.__name__
'hello'
```

## 装饰器
在代码运行期间动态增加功能，但不改变原有函数定义。

例如，在 `hello` 函数前后增加日志打印功能。

### 定义装饰器
```python
def log(func):
    def wrapper(*args, **kw):
        print('call %s():' % func.__name__)
        return func(*args, **kw)
    return wrapper
```

上述装饰器接收一个函数，并返回一个函数。

### 使用装饰器
使用 **@** 符号调用装饰器，将装饰器放置于函数定义处，例如：
```python
@log
def hello():
    print('hello')

hello()
call hello():
hello
```

### 装饰器原理
经过装饰的函数，被调用时不再执行原始的函数，实际上执行的是装饰器返回的函数。

上文中，调用 `hello()` 实际上调用的是装饰器返回的 `wrapper()` 函数。相当于调用:
```python
hello = log(hello)
```

### 高阶装饰器
可以定义接收参数的装饰器：
```python
def log(text):
    def decorator(func):
        def wrapper(*args, **kw):
            print('%s %s():' % (text, func.__name__))
            return func(*args, **kw)
        return wrapper
    return decorator
```

上述装饰器的用法如下：
```python
@log('execute')
def hello():
	print('hello')
```

执行结果：
```python
hello()
execute wrapper():
execute hello():
hello
```

使用装饰器相当于如下调用：
```python
hello = log('execute')(hello)
```

### 问题
上文描述了带参数的装饰器，查看经过此装饰器装饰的函数，发现函数名改变了：

```python
hello.__name__
'wrapper'
```

如果经过装饰器，函数名被改变，将可能造成其它代码的运行错误（例如依赖函数名的代码），因此，需要将原始函数的属性拷贝到新函数。

### 完整的装饰器
上文中我们创建的装饰器实际上 **没有将原始函数的一些属性拷贝到新函数**，Python 内置的 `functools.wraps` 可以帮助我们完成这个工作。

无参数装饰器：
```python
import functools

def log(func):
    @functools.wraps(func)
    def wrapper(*args, **kw):
        print('call %s():' % func.__name__)
        return func(*args, **kw)
    return wrapper
```

带参数装饰器：
```python
import functools

def log(text):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kw):
            print('%s %s():' % (text, func.__name__))
            return func(*args, **kw)
        return wrapper
    return decorator
```

