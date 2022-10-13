## 模块（Modele）
模块是一个包含 Python 定义和语句的文件，文件名即是模块名，文件名的后缀是 `.py`。

在模块中，模块名可以当作全局变量访问，变量名为 `__name__`。

模块例子 `fibo.py`：
```python
# Fibonacci numbers module

def fib(n):    # write Fibonacci series up to n
    a, b = 0, 1
    while a < n:
        print(a, end=' ')
        a, b = b, a+b
    print()

def fib2(n):   # return Fibonacci series up to n
    result = []
    a, b = 0, 1
    while a < n:
        result.append(a)
        a, b = b, a+b
    return result
```

在 Python 解释器中，可以以如下方式引用模块：
```python
>>> import fibo
```

这种方式不会把 `fibo` 内的的命名空间添加到当前命名空间，只会添加模块名 `fibo`。通过模块名可以访问模块内的函数：
```python
>>> fibo.fib(1000)
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987
>>> fibo.fib2(100)
[0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
>>> fibo.__name__
'fibo'
```

对于经常使用的模块内的函数，可以给它分配一个本地命名：
```python
>>> fib = fibo.fib
>>> fib(500)
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377
```

### 使用模块
将模块中的命名添加到当前命名空间：
```python
>>> from fibo import fib, fib2
>>> fib(500)
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377
```
这种方式不会将模块名添加到本地命名空间（`fibo` 未定义）。

使用如下方式可以包含模块中的所有命名：
```python
>>> from fibo import *
>>> fib(500)
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377
```
这种方式会包含模块中的所有命名（除了以双下划线（`__`）开头的）。但不推荐使用此种引用方式，因为模块中可能会包含某些难以察觉的本地已定义的命名。

如果在模块名后加上 `as`，`as` 之后的命名将会绑定到模块：
```python
>>> import fibo as fib
>>> fib.fib(500)
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377
```

还可以利用 `from` 关键字达到类似的效果：
```python
>>> from fibo import fib as fibonacci
>>> fibonacci(500)
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377
```

为了保证效率，模块只会被载入一次，因此，如果模块被改变，应该重启解释器。或者使用 `importlib.reload()`，例如：
```python
import importlib

importlib.reload(modulename)
```

### 将模块作为脚本执行
当运行以下语句时：
```shell
$ python fibo.py <arguments>
```
模块将被执行，但是模块名 `__name__` 将被设置为 `__main__`。这意味着当在模块末尾添加如下语句时：
```python
if __name__ == "__main__":
    import sys
    fib(int(sys.argv[1]))
```
这些语句将被执行。

利用这个特性，`.py` 文件不仅可以作为模块被引用，还可以作为脚本被执行。

作为脚本执行：
```shell
$ python fibo.py 50
0 1 1 2 3 5 8 13 21 34
```

作为模块被引用：
```python
>>> import fibo
>>>
```

### 模块的搜索路径
当包含一个名为 `spam` 的模块，解释器首先搜索内置模块。内置模块可以使用 `sys.builtin_module_names` 列出。如果未找到，解释器将会在 `sys.path` 列出的目录中查找 `spam.py`。`sys.path` 由以下位置初始化：
* 当前文件所在目录（没有文件时则查找当前工作目录）
* `PYTHONPATH` 环境变量，是一串目录列表
* 依赖于安装的默认值（通常是 `site-packages` 目录，由 `site` 模块处理）

在初始化之后，Python 程序可以更改 `sys.path`。例如：
```python
>>> import sys
>>> sys.path.append('/ufs/guido/lib/python')
```

### dir() 函数
内嵌的 `dir()` 函数用于列出模块定义的命名，包括变量、模块、函数等等，它返回的是一个经过排序的字符串列表：
```python
>>> import fibo, sys
>>> dir(fibo)
['__name__', 'fib', 'fib2']
>>> dir(sys)  
['__breakpointhook__', '__displayhook__', '__doc__', '__excepthook__',
 '__interactivehook__', '__loader__', '__name__', '__package__', '__spec__',
 '__stderr__', '__stdin__', '__stdout__', '__unraisablehook__',
 '_clear_type_cache', '_current_frames', '_debugmallocstats', '_framework',
 '_getframe', '_git', '_home', '_xoptions', 'abiflags', 'addaudithook',
 'api_version', 'argv', 'audit', 'base_exec_prefix', 'base_prefix',
 'breakpointhook', 'builtin_module_names', 'byteorder', 'call_tracing',
 'callstats', 'copyright', 'displayhook', 'dont_write_bytecode', 'exc_info',
 'excepthook', 'exec_prefix', 'executable', 'exit', 'flags', 'float_info',
 'float_repr_style', 'get_asyncgen_hooks', 'get_coroutine_origin_tracking_depth',
 'getallocatedblocks', 'getdefaultencoding', 'getdlopenflags',
 'getfilesystemencodeerrors', 'getfilesystemencoding', 'getprofile',
 'getrecursionlimit', 'getrefcount', 'getsizeof', 'getswitchinterval',
 'gettrace', 'hash_info', 'hexversion', 'implementation', 'int_info',
 'intern', 'is_finalizing', 'last_traceback', 'last_type', 'last_value',
 'maxsize', 'maxunicode', 'meta_path', 'modules', 'path', 'path_hooks',
 'path_importer_cache', 'platform', 'prefix', 'ps1', 'ps2', 'pycache_prefix',
 'set_asyncgen_hooks', 'set_coroutine_origin_tracking_depth', 'setdlopenflags',
 'setprofile', 'setrecursionlimit', 'setswitchinterval', 'settrace', 'stderr',
 'stdin', 'stdout', 'thread_info', 'unraisablehook', 'version', 'version_info',
 'warnoptions']
```

当传参为空时，`dir()` 列出当前已定义的命名：
```python
>>> a = [1, 2, 3, 4, 5]
>>> import fibo
>>> fib = fibo.fib
>>> dir()
['__builtins__', '__name__', 'a', 'fib', 'fibo', 'sys']
```

`dir()` 不会列出内嵌的函数和变量，如果你想查看，可以使用标准模块 `builtins`：
```python
>>> import builtins
>>> dir(builtins)  
['ArithmeticError', 'AssertionError', 'AttributeError', 'BaseException',
 'BlockingIOError', 'BrokenPipeError', 'BufferError', 'BytesWarning',
 'ChildProcessError', 'ConnectionAbortedError', 'ConnectionError',
 'ConnectionRefusedError', 'ConnectionResetError', 'DeprecationWarning',
 'EOFError', 'Ellipsis', 'EnvironmentError', 'Exception', 'False',
 'FileExistsError', 'FileNotFoundError', 'FloatingPointError',
 'FutureWarning', 'GeneratorExit', 'IOError', 'ImportError',
 'ImportWarning', 'IndentationError', 'IndexError', 'InterruptedError',
 'IsADirectoryError', 'KeyError', 'KeyboardInterrupt', 'LookupError',
 'MemoryError', 'NameError', 'None', 'NotADirectoryError', 'NotImplemented',
 'NotImplementedError', 'OSError', 'OverflowError',
 'PendingDeprecationWarning', 'PermissionError', 'ProcessLookupError',
 'ReferenceError', 'ResourceWarning', 'RuntimeError', 'RuntimeWarning',
 'StopIteration', 'SyntaxError', 'SyntaxWarning', 'SystemError',
 'SystemExit', 'TabError', 'TimeoutError', 'True', 'TypeError',
 'UnboundLocalError', 'UnicodeDecodeError', 'UnicodeEncodeError',
 'UnicodeError', 'UnicodeTranslateError', 'UnicodeWarning', 'UserWarning',
 'ValueError', 'Warning', 'ZeroDivisionError', '_', '__build_class__',
 '__debug__', '__doc__', '__import__', '__name__', '__package__', 'abs',
 'all', 'any', 'ascii', 'bin', 'bool', 'bytearray', 'bytes', 'callable',
 'chr', 'classmethod', 'compile', 'complex', 'copyright', 'credits',
 'delattr', 'dict', 'dir', 'divmod', 'enumerate', 'eval', 'exec', 'exit',
 'filter', 'float', 'format', 'frozenset', 'getattr', 'globals', 'hasattr',
 'hash', 'help', 'hex', 'id', 'input', 'int', 'isinstance', 'issubclass',
 'iter', 'len', 'license', 'list', 'locals', 'map', 'max', 'memoryview',
 'min', 'next', 'object', 'oct', 'open', 'ord', 'pow', 'print', 'property',
 'quit', 'range', 'repr', 'reversed', 'round', 'set', 'setattr', 'slice',
 'sorted', 'staticmethod', 'str', 'sum', 'super', 'tuple', 'type', 'vars',
 'zip']
```

## 包（Package）
包使用「点式模块名」来结构化模块。例如，模块名 `A.B` 指示子模块 `B` 在包 `A` 中。这样的方式可以避免命名空间冲突。

假设你想设计一个模块集（包）来同意处理音频文件和音频数据。需要考虑**格式、音效、过滤器**。下面是一种可能的目录结构：
```
sound/                          Top-level package
      __init__.py               Initialize the sound package
      formats/                  Subpackage for file format conversions
              __init__.py
              wavread.py
              wavwrite.py
              aiffread.py
              aiffwrite.py
              auread.py
              auwrite.py
              ...
      effects/                  Subpackage for sound effects
              __init__.py
              echo.py
              surround.py
              reverse.py
              ...
      filters/                  Subpackage for filters
              __init__.py
              equalizer.py
              vocoder.py
              karaoke.py
              ...
```

每当引入这个包，Python 将在 `sys.path` 中搜索包目录，一次来查找子目录。

目录中必须有 `__init__.py` 文件，Python 才会将其视为一个包，这种规定避免 Python 将普通的文件名视为包，而屏蔽掉包搜索路径中后续的包。最简情况下，`__init__.py` 可以为空文件，但它也可以用来执行包初始化或设置 `__all__` 变量，这将在后续讨论。

可以引用包中独立的模块：
```python
import sound.effects.echo
```
使用这种方式，必须以全名调用：
```python
sound.effects.echo.echofilter(input, output, delay=0.7, atten=4)
```

另一种引用方案：
```python
from sound.effects import echo
```
使用这种方式，则不必使用模块前缀，可以这样调用：
```python
echo.echofilter(input, output, delay=0.7, atten=4)
```

直接引用函数或变量：
```python
from sound.effects.echo import echofilter
```
调用：
```python
echofilter(input, output, delay=0.7, atten=4)
```

使用 `from package import item` 方式时，`item` 可以是包的子模块，或在包中定义的函数、类、变量。`import` 语句按以下顺序进行判定：
1. 查看其是否在包中已定义
2. 将其视为一个模块并且尝试去加载
3. 如果以上两项都不成立，则抛出 `ImportError` 异常。

相反的，使用 `import item.subitem.subsubitem` 形式时，除了最后一项，其他项必须是一个包，最后一项可以是模块或包，但是不能是一个类、函数或变量。

### import *

