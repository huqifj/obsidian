# Qt 布局


![Untitled](assets/Qt%20布局/Untitled.png)

## 布局系统的结构

QLayout 是布局系统中的抽象基类，继承自 QObject 和 QLayoutItem, 其中四个子类分别为：

- QBoxLayout (箱式布局)
- QFormLayout (表单布局)
- QGridLayout (网格布局)
- QStackedLayout (栈布局)

## QBoxLayout 箱式布局

箱式布局提供了两个子类分别处理水平（QHBoxLayout）和垂直（QVBoxLayout）两个方向的排版，可以使视图排成一行或者一列来显示。

```c
#include <QVBoxLayout>
#include <QPushButton>

//  添加两个按钮
QPushButton *okBtn  = new QPushButton;
okBtn ->setText(tr("我在上面, 我最牛"));
QPushButton *celBtn = new QPushButton;
celBtn->setText(tr("我在下面, 我不服"));

//  创建一个垂直箱式布局, 将两个按钮扔进去
QVBoxLayout *layout = new QVBoxLayout;
layout->addWidget(okBtn);
layout->addWidget(celBtn);

//  设置界面的布局为垂直箱式布局
setLayout(layout);
```

## QFormLayout 表单布局

1. 按照图中，创建表单的第一行，共享给哪个用户的输入框，可以为输入框填写占位文字，双击 Form Layout 创建字段类型为 QComboBox（多选框）的一行。
2. 填写允许的权限内容。
3. 设置整个 Widget 布局为垂直箱式布局在 Form Layout 下拖拽过去一个 Horizontal Layout（水平箱式布局）。
4. 在箱式布局中添加 Horizontal Spacer（水平占位）后拖拽两个 Push Button 完成界面布局。

![Untitled](assets/Qt%20布局/Untitled%201.png)

如果是使用纯代码表单布局的话可以使用 addRow() 的方法来添加一行

## QGridLayout 网格布局

![Untitled](assets/Qt%20布局/Untitled%202.png)

- 在代码中，可以使用如下 API 来为网格视图添加一个从几行几列开始占据几行几列的控件：
    
    ```c
    void addWidget(QWidget *, int row, int column, int rowSpan, int columnSpan)
    ```
    

## QStackedLayout 栈布局

通常应用的界面会根据不同的状态有不同的内容，这时就可以使用 QStackedLayout 栈布局，栈布局提供了一个页面的栈，每个页面有完全独立的界面布局。可以非常清晰的对不同状态下的界面进行布局管理。

在 Qt 的可视化布局工具中，通过 Stacked Widget 来完成界面的栈布局。

## 布局相关属性

### 控件大小

- sizeHint (Read Only)：控件的建议尺寸
- minimumSizeHint (Read Only)：控件的建议最小尺寸
- 如果手动设置了最小尺寸 miniumSize，minimumSizeHint 会被忽略。

### 大小策略

大小策略属性 sizePolicy 也是 QWidget 类的属性，这个属性在水平和垂直两个方向分别起作用，控制着控件大小变化的策略。以下策略都在命名控件 QSizePolicy 中。

- Fixed：只能使用 sizeHint 的大小，任何操作都不会改变控件大小。
- Minimum：sizeHint 为最小大小，控件可以被拉伸。
- Maximum：sizeHint 为最大大小，控件可以被压缩。
- Preferred：sizeHint 为建议大小，控件既可以被压缩也可以被拉伸。
- MinimumExpanding：sizeHint 为最小大小，不能被压缩，被拉伸的优先级更高。
- Expanding：sizeHint 为建议大小，可以被压缩，被拉伸的优先级更高。
- Ignored：sizeHint 的值将会被忽略。
- 拉伸
    
    Expanding、MinimumExpanding 优先级相同，比 Preferred 和 Ignored 拉伸优先级高，Preferred 和 Ignored 相同。
    
    如果两个控件在一个水平箱式布局中管理，其中一个水平大小策略为 Preferred，另一个为 Expanding 或者 MinimumExpanding，如果水平拉伸窗体，则 Preferred 的控件大小不会改变，Expanding 或者是 MinimumExpanding 会被拉伸。
    
    如果两个控件水平大小策略一个为 Expanding，一个是 MinimumExpanding，这时拉伸窗体，则两个控件均会拉伸。
    
    如果两个控件都为 Fixed 无法拉伸时，控件间的间隙会被拉伸。
    
- 压缩
    
    Ignored 会忽略 sizeHint 和 minimumSizeHint 的属性，所以控件会继续被压缩。
    

### 伸缩性

在 QLayout 中提供了一个和控件大小策略相关的属性，layoutStretch 布局伸缩性，这个值是一个比例，在可视化工具中可以更直观的看到这个值的设置，如果在布局中有三个控件，则是三个控件的占比，用逗号分隔，如：1, 1, 1。

只有会被压缩或者拉伸的控件才会受该属性值影响（Fixed 不会受该属性影响）。

如果设置了伸缩性的比值（如果都为 0 表示不设置）前面提到的大小策略的优先级将会被忽略。此时对于前面提到的例子，如果两个控件在一个水平箱式布局中管理，其中一个水平大小策略为 Preferred，另一个为 Expanding，设置水平箱式布局的 layoutStretch 为 2, 1，则拉伸时，并不会像刚刚所说，只有 Expanding 的控件会被拉伸，而是都会被拉伸，按照一个 2 : 1 的拉伸比例拉伸。

### 窗体大小约束策略

layoutSizeConstraint 属性，用来约束窗体大小，只影响窗体，所以该属性只对最顶级的 QLayout 起作用。QLayout 命名空间中：

- SetDefaultConstraint：窗体最小值被设置为 minimumSize 值无法再缩小，如果 QLayout 内控件有更大的 minimumSize，则会取更大的 minimumSize。
- SetNoConstraint：窗体没有约束策略。
- SetFixedSize：窗体大小被设定为 sizeHint 的大小，无法改变。
- SetMinimumSize：窗体最小为 minimumSize 无法再缩小，如果 QLayout 内控件有更小的 minimumSize，则会取更小的 minimumSize，和 Default 不同的地方就是尽可能的小。
- SetMaxmumSize：窗体最大值为 maxmumSize，无法再放大。
- SetMinAndMaxSize：窗体最小为 minimumSize 无法再缩小，窗体最大值为 maxmumSize，无法再放大。

### 其他属性