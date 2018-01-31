# TreeViewTemplate

>   A TreeView Template that you can make deep customization，With the two tree templates provided, you can accomplish most of your business needs。

>   这是一个可以进行深度自定义的树形结构模板，通过提供的两个树形模板，基本可以完成大部分业务需求。


## 一、功能简介

#### 1、支持两种常见的树形结构

一种是向下无限展开式的树形结构（`ExpansionStyle`），另一种是面包屑形式的树形结构(`BreadcrumbsStyle`)。

#### 2、支持自定义`nodeModel`节点模型,自定义`nodeView`节点视图,自定义`node`节点的高度

本质上无需继承，任意模型与视图都可以拿来构成一颗树，只要遵守相对应的`NodeModelProtocol`和`NodeViewProtocol`协议，自己实现相对应的属性与方法即可，当然，也可以直接继承模板提供的节点模型基类，或者直接继承协议，自定义一个新的协议。

#### 3、支持缩进

#### 4、支持自动刷新与手动刷新两种方式
分别对应本地数据源与网络数据源，同时可以指定树的展开动画`RowAnimation`。建议使用手动刷新，这也是默认方式。

#### 5、支持自动布局
在`nodeView`高度发生变化或者设置了缩进，会自动递归的向所有的`subview`发送`setNeedLayout`消息，可以在需要重新布局的子视图中重写`layoutSubviews`进行重新布局。

#### 6、节点模型基类`BaseTreeNode`提供的一些辅助功能：
* 自动递归计算树的根节点
* 自动递归计算树的高度
* 自动递归计算该节点所在的层级，默认根节点的层级为0
* 其他基本操作

## 二、如何使用
### 安装
* 手动安装：将`TreeViewTemplate`文件夹拖入项目
* CocoaPod：podfile加入`pod 'TreeViewTemplate'`(待完善)

### 使用
#### 1、创建`NodeTreeView`
```
/**
初始化方法

@param frame frame
@param style 展现形式：BreadcrumbsStyle或者ExpansionStyle
@return treeView实例
*/
- (instancetype _Nullable )initWithFrame:(CGRect)frame
treeViewStyle:(NodeTreeViewStyle)style;

```
#### 2、设置代理
```
@protocol NodeTreeViewDelegate
@required
/**
返回对应节点下的视图：视图可以遵循NodeViewProtocol协议，让view具有一些统一的行为>
一种node对应一种nodeView

@param node node节点
@return node视图
*/
- (id<NodeViewProtocol>_Nonnull)nodeTreeView:(NodeTreeView *_Nonnull)treeView viewForNode:(id<NodeModelProtocol>_Nonnull)node;

@optional

/**
返回对应级别下的缩进

@param treeView treeView
@param nodeLevel 对应的nodeLevel
@return 该level下对应的缩进
*/
- (CGFloat)nodeTreeView:(NodeTreeView *_Nonnull)treeView indentAtNodeLevel:(NSInteger)nodeLevel;
/**
点击事件回调

@param treeView 树
@param node 节点模型
*/
- (void)nodeTreeView:(NodeTreeView *_Nonnull)treeView didSelectNode:(id<NodeModelProtocol>_Nonnull)node;

@end

```
#### 3、设置是否需要自动刷新，不建议使用自动刷新
```
/**
树的刷新策略
默认是手动刷新：NodeTreeRefreshPolicyManaul
*/
@property (nonatomic, assign) NodeTreeRefreshPolicy refreshPolicy;

```
#### 4、如果数据是实时获得的，那么需要手动调用刷新方法
```
/**
刷新node节点对应的树
*/
- (void)reloadTreeViewWithNode:(id<NodeModelProtocol>_Nonnull)node;

/**
刷新node节点对应的树，可以指定动画展开的方式
@param node  node节点
*/
- (void)reloadTreeViewWithNode:(id<NodeModelProtocol>_Nonnull)node
RowAnimation:(UITableViewRowAnimation)animation;

```
#### 5、使用时建议将treeView作为一个cell,放在一个tableview中使用。

#### 6、关于`NodeModelProtocol`节点模型协议
* 声明了一些遵守该协议的模型需要手动实现的属性和方法。
* 属性声明：节点高度、子节点数组、父节点、节点所在的层级、节点展开后的所有儿子节点的高度之和、该节点所在树的当前整体高度、节点是否展开。
* 方法声明：增加节点、从数组中增加节点、删除节点。

#### 7、关于`NodeViewProtocol`节点模型协议
* 定义了所有节点视图必须实现的方法,如下所示：
```

@protocol NodeViewProtocol
@required
/**
更新单个Node行

@param node node模型
*/
- (void)updateNodeViewWithNodeModel:(id<NodeModelProtocol>)node;
/**
需要在该方法中，对cell进行重新布局，为了处理在缩进的时候宽度变化造成的影响
*/
- (void)layoutSubviews;

@end
```

## 三、对递归的使用

在处理树的时候，用到的一些递归操作：

```
====================  NodeTreeView.m中对递归的使用   ====================
1、#pragma mark NodeTreeViewStyleExpansion模式下，初始化数据源，递归的将所有需要展开的节点，加入到初始数据源中

static inline void RecursiveInitializeAllNodesWithRootNode(NSMutableArray *allNodes,id<NodeModelProtocol>rootNode){
    if (rootNode.expand == NO || rootNode.subNodes.count == 0) {
        return;
    }else{
        if (allNodes.count == 0) {
            [allNodes addObjectsFromArray:rootNode.subNodes];
        }else{
            NSUInteger beginPosition = [allNodes indexOfObject:rootNode] + 1;
            NSUInteger endPosition = beginPosition + rootNode.subNodes.count - 1;
            NSRange range = NSMakeRange(beginPosition, endPosition-beginPosition+1);
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
            [allNodes insertObjects:rootNode.subNodes atIndexes:set];
        }
        for (id<NodeModelProtocol>subNode in rootNode.subNodes) {
            rootNode = subNode;
            RecursiveInitializeAllNodesWithRootNode(allNodes, rootNode);
        }
    }
}

2、#pragma mark 递归的将某节点下所有子节点的展开状态置为NO

static inline void RecursiveFoldAllSubnodesAtNode(id<NodeModelProtocol>node){

    if (node.subNodes.count>0) {
        [node.subNodes enumerateObjectsUsingBlock:^(id<NodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isExpand) {
            obj.expand = NO;
            RecursiveFoldAllSubnodesAtNode(node);
        }}];
    }else{
        return;
    }
}

3、#pragma mark 递归的向view的所有子view发送setNeedsLayout消息，进行重新布局

static inline void RecursiveLayoutSubviews(UIView *_Nonnull view){
    if (view.subviews.count == 0) {
        return;
    }else{
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
            [subView setNeedsLayout];
            RecursiveLayoutSubviews(subView);
    }];
}
}

====================  BaseTreeNode.m中对递归的使用   ====================
CGFloat treeHeight;

CGFloat tempNodeLevel;

4、#pragma mark 获取根节点

static inline id<NodeModelProtocol>RecursiveGetRootNodeWithNode(id<NodeModelProtocol> node){
    if (node.fatherNode == node) {
        node.expand = YES;
        return node;
    }else{
        node = node.fatherNode;
        tempNodeLevel = tempNodeLevel+1;
        return  RecursiveGetRootNodeWithNode(node);
    }
}

5、#pragma mark 根据根节点获取树的高度

static inline void RecursiveCalculateTreeHeightWithRootNode(id<NodeModelProtocol> rootNode){
    if (rootNode.subNodes.count == 0||!rootNode.isExpand) {
        return ;
    }
    if (!isnan(rootNode.subTreeHeight)) {
        treeHeight += rootNode.subTreeHeight;
    }
    for (id<NodeModelProtocol>obj in rootNode.subNodes) {
        RecursiveCalculateTreeHeightWithRootNode(obj);
    }
}

```
## 四、效果展示

1、面包屑模式-自动

![面包屑模式-自动](https://user-gold-cdn.xitu.io/2018/1/31/1614ba34ac5701fc?w=285&h=428&f=gif&s=493107)

2、面包屑模式-手动

![面包屑模式-手动](https://user-gold-cdn.xitu.io/2018/1/31/1614ba3e54dd43d0?w=299&h=449&f=gif&s=468026)

3、Expansion模式-自动

![Expansion模式-自动](https://user-gold-cdn.xitu.io/2018/1/31/1614ba44592cab16?w=241&h=362&f=gif&s=515876)

4、Expansion模式-手动

![Expansion模式-手动](https://user-gold-cdn.xitu.io/2018/1/31/1614ba4a344fce1c?w=214&h=321&f=gif&s=522766)


GitHub下载地址：[TreeViewTemplate](https://github.com/sunday1990/TreeViewTemplate)













