# TreeViewTemplate

>   A TreeView Template that you can make deep customization，With the two tree templates provided, you can accomplish most of your business needs。

>   这是一个可以进行深度自定义的树形结构模板，通过提供的两个树形模板，基本可以完成大部分业务需求。

#  一、功能简介

#### 1、支持两种常见的树形结构。一种是向下无限展开式的树形结构（`ExpansionStyle`），另一种是面包屑形式的树形结构(`BreadcrumbsStyle`)。

#### 2、支持自定义`nodeModel`节点模型,自定义`nodeView`节点视图,自定义`node`节点的高度。本质上无需继承，任意模型与视图都可以拿来构成一颗树，只要遵守相对应的`NodeModelProtocol`和`NodeViewProtocol`协议，自己实现相对应的属性与方法即可，当然，也可以直接继承模板提供的节点模型基类，设置可以直接

#### 3、支持缩进。

#### 4、支持自动刷新与手动刷新两种方式，分别对应本地数据源与网络数据源，同时可以指定树的展开动画`RowAnimation`。建议使用手动刷新，这也是默认方式。

#### 5、支持自动布局。在`nodeView`高度发生变化或者设置了缩进，会自动递归的向所有的`subview`发送`setNeedLayout`消息，可以在需要重新布局的子视图中重写`layoutSubviews`进行重新布局。

#### 5、节点模型基类`BaseTreeNode`提供的一些辅助功能：
        * 自动递归计算树的根节点
        * 自动递归计算树的高度
        * 自动递归计算该节点所在的层级，默认根节点的层级为0
        * 其他基本操作

# 二、如何使用



