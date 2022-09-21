# Qt 模型/视图


## 模型/视图架构

MVC 模式（Model–view–controller）是软件工程中的一种软件架构模式，把软件系统分为三个基本部分：模型（Model）、视图（View）和控制器（Controller）。

- 模型（Model） - 程序员编写程序应有的功能（实现算法等等）、数据库专家进行数据管理和数据库设计 (可以实现具体的功能)。
- 视图（View） - 界面设计人员进行图形界面设计。
- 控制器（Controller）- 负责转发请求，对请求进行处理。

Qt 将视图和模型结合起来，使用模型/视图架构。

- 当数据源的数据发生变化时，模型发出信号告知视图；
- 当用户与显示的项目交互时，视图发出信号来提供交互信息；
- 当编辑项目时，委托发出信号，告知模型和视图编辑器的状态。

### 模型

基类为 QAbstractItemModel 类。Qt 提供常用的模型来处理数据项：

- QStringListModel 用来存储 QString 项目列表；
- QStandardItemModel 用来管理树型结构的数据项；
- QFileSystemModel 提供了本地文件系统中文件和目录的信息；
- QSqlQueryModel、QSqlTableModel 和 QSqlRelationalTableModel 用来访问数据库。

还可以子类化 QAbstractItemModel、QAbstractListModel、QAbstractTableModel 来创建自定义模型。

### 视图

- QListView 将数据项显示为列表；
- QTableView 将数据项显示在表格中；
- QTreeView 将数据项显示在具有层次的列表中。

这些类都基于 QAbstractItemView 抽象基类，这些类可以直接使用，也可以被子类化来提供定制的视图。

### 委托

QAbstractItemDelegate 是委托的抽象基类。

## 模型类

### 基本概念

模型提供标准的接口供视图和委托来访问数据。这个标准的接口由 QAbstractItemModel 类定义， QAbstractItemModel 的子类以层次结构来表示数据，结构中包含了数据项表。视图可以访问模型中的数据，并可以使用任何形式将数据显示出来。当模型中的数据发生变化时，模型会通过信号和槽机制告知与其相关联的视图。

常用的 3 种模型分别是列表模型、表格模型和树模型：

![图 1](无标题-2022-03-27-1401.png)

图 1

- 模型索引
    
    指定行号、列号、父项模型索引以获取模型索引：
    
    ```c
    QModelIndex index = model->index(row, column, parent);
    ```
    
- 行和列
    
    行和列都从 0 开始编号，相对父项进行定位，**顶层父项模型索引**可以用 `QModelIndex()` 表示。图 1 中 Table Model 的 A、B、C 的模型索引可以使用如下代码获取：
    
    ```c
    QModelIndex indexA= model->index(0, 0, QModelIndex());
    QModelIndex indexA= model->index(1, 1, QModelIndex());
    QModelIndex indexA= model->index(2, 1, QModelIndex());
    ```
    
- 父项
    
    项目可能是其他项目的父项，为模型项请求一个索引时，需要指定其父项。图 1 中 Tree Model 中 A、B、C 的索引可以用如下代码获取：
    
    ```c
    QModelIndex indexA = model->index(0, 0, QModelIndex());
    QModelIndex indexC = model->index(2, 0, QModelIndex());
    QmodelIndex indexB = model->index(1, 0, indexA);
    ```
    
- 项角色
    
    可以通过向模型指定模型索引以及特定的角色来获取需要的类型的数据：
    
    ```c
    QVariant value = model->data(index, role);
    ```
    
    设置模型项角色数据：
    
    ```c
    // 方式一
    item1->setIcon(QIcon(pixmap1));
    item1->setToolTip("indexB");
    
    // 方式二
    item2->setData("C", Qt::EditRole);
    item2->setData("IndexC", Qt::ToolTipRole);
    item2->setData(QIcon(pixmap2), Qt::DecorationRole);
    ```
    
    常用的角色如下表所示：
    
    | 常量 | 描述 | 数据类型 |
    | --- | --- | --- |
    | Qt::DisplayRole | 数据被渲染为文本 | QString |
    | Qt::DecorationRole | 数据被渲染为图标等装饰 | QColor、QIcon、QPixmap |
    | Qt::EditRole | 数据可以在编辑器中进行编辑 | QString |
    | Qt::ToolTipRole | 数据显示在数据项的工具提示中 | QString |
    | Qt::StatusTipRole | 数据显示在状态栏中 | QString |
    | Qt::WhatsThisRole | 数据显示在数据项的“What‘s This？”模式下 | QString |
    | Qt::SizeHintRole | 数据项的大小提示，将会应用到视图 | QSize |

### 创建新的模型

## 视图类

### 基本概念

QAbstractItemView 提供标准视图接口以呈现数据。视图还处理项目间的导航和项目选择。

选择行为（QAbstractItemView::SelectionBehavior）：

| 常量 | 描述 |
| --- | --- |
| QAbstractItemView::SelectItems | 选择单个项目 |
| QAbstractItemView::SelectRows | 只选择行 |
| QAbstractItemView::SelectColumns | 只选择列 |

选择模式（QAbstractItemView::SelectionMode）：

| 常量 | 描述 |
| --- | --- |
| QAbstractItemView::SingleSelection | 当用户选择一个项目时，所有已经选择的项目将成为未选择状态，而且用户无法在已经选择的项目上单击来取消选择 |
| QAbstractItemView::ContiguousSelection | 如果用户在单击一个项目的同时按着 Shift 键，则所有当前项目和单击项目之间的项目都将被选择或者取消选择，这依赖于被单击项目的状态 |
| QAbstractItemView::ExtendedSelection | 具有 ContiguousSelection 的特性，而且还可以按着 Ctrl 键进行不连续的选择 |
| QAbstractItemView::MultiSelection | 用户选择一个项目时不影响其他已选择的项目 |
| QAbstractItemView::NoSelection | 项目无法被选择 |

一些视图可以显示标头，这是通过 QHeaderView 类实现的。使用 QAbstractItemModel::headerData() 函数从模型中获取数据。可以通过子类化 QHeaderView 类来实现设置标签的显示。

### 处理项目选择

在视图中被选择的项目的信息存储在一个 QItemSelectionModel 实例中。选择由范围指定，即记录每一个选择范围开始和结束的模型索引，非连续的选择使用多个范围描述。

- 当前项目和被选择的项目
    
    在视图中，总是有一个**当前项目**和**被选择的项目**，两者是独立的状态。一个项目可以即是当前项目，又是被选择的项目。
    
    视图负责确保总是有一个项目作为当前项目来实现键盘导航。
    
    当前项目和被选择项目的区别：
    
    | 当前项目 | 被选择的项目 |
    | --- | --- |
    | 只能有一个当前项目 | 可以有多个被选择的项目 |
    | 使用键盘导航键或者鼠标按键可以改变当前项目 | 项目是否处于被选择状态取决于几个预先定义好的模式（单项选择、多重选择等） |
    | 按下 F2 或双击左键可以编辑当前项目 | 当前项目可以通过指定一个范围来一起被使用 |
    | 当前项目会显示焦点矩形 | 被选择的项目会使用选择矩形来表示 |
- 使用选择模型
    
    可以通过视图的 selectionModel() 获取所属选择模型。
    
    可以使用 setSelectionModel() 函数为不同的视图设置相同的选择模型，这样视图可以共享选择。
    

## 委托类

### 基本概念

委托的标准接口在 QAbstractItemDelegate 类中定义。

使用 itemDelegate() 函数获取一个视图中使用的委托。

使用 setItemDelegate() 函数可以为一个**视图**安装一个自定义委托：

```c
SpinBoxDelegate *delegate = new SpinBoxDelegate(this);
tableView->setItemDelegate(delegate);
```

### 自定义委托