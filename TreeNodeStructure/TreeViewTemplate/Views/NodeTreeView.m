//
//  NodeTreeView.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "NodeTreeView.h"

#pragma mark 判断树在某一节点是否应该收起
static inline bool TreeShouldFoldAtNode(BOOL autoRefresh, id<NodeModelProtocol> node){
    BOOL shouldFold;
    if (autoRefresh) {//自动刷新
        if (node.isExpand) {
            shouldFold = YES;
        }else{
            shouldFold =  NO;
        }
    }else{  //手动刷新刷新
        if (node.isExpand) {
            shouldFold =  NO;
        }else{
            shouldFold = YES;
        }
    }
    return shouldFold;
}

#pragma mark NodeTreeViewStyleExpansion模式下，初始化数据源，递归的将所有需要展开的节点，加入数据源中
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

#pragma mark 递归的将某节点下所有子节点的展开状态置为NO
static inline void RecursiveFoldAllSubnodesAtNode(id<NodeModelProtocol>node){
    if (node.subNodes.count>0) {
        [node.subNodes enumerateObjectsUsingBlock:^(id<NodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isExpand) {
                obj.expand = NO;
                RecursiveFoldAllSubnodesAtNode(node);
            }
        }];
    }else{
        return;
    }
}

#pragma mark 递归的向view的所有子view发送setNeedsLayout消息，进行重新布局
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

#pragma mark NodeTreeViewCell
@interface NodeTreeViewCell:UITableViewCell

@property (nonatomic,strong)id<NodeViewProtocol>nodeView;

@end

#pragma mark NodeTreeView
@interface NodeTreeView ()<UITableViewDelegate,UITableViewDataSource>
{
    struct {
        unsigned int indentAtNodelevel:1;
        unsigned int didSelectNode:1;
        unsigned int viewForNode:1;
    }_treeViewDelegateFalg;
    
}
@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSMutableArray <id<NodeModelProtocol>>*allNodes;

@property (nonatomic, strong) id<NodeModelProtocol>currentNode;

@property (nonatomic, assign) NodeTreeViewStyle treeViewStyle;

@property (nonatomic, assign,getter=isAutoRefresh) BOOL autoRefresh;

@end


@implementation NodeTreeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must use initWithFrame: treeViewStyle: instead" userInfo:nil];
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame treeViewStyle:NodeTreeViewStyleBreadcrumbs];
}

- (instancetype)initWithFrame:(CGRect)frame treeViewStyle:(NodeTreeViewStyle)style{
    if (self = [super initWithFrame:frame]) {
        self.treeViewStyle = style;
        self.alwaysBounceVertical = NO;
        self.bounces = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.scrollEnabled = self.treeViewStyle == NodeTreeViewStyleExpansion;        
        self.refreshPolicy = NodeTreeRefreshPolicyManaul;
        [self addSubview:self.tableview];
        
    }
    return self;
}

#pragma mark ======== System Delegate ========

#pragma mark DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        return self.currentNode.subNodes.count;
    }else{
        return self.allNodes.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NodeModelProtocol>node;
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        node = self.currentNode.subNodes[indexPath.row];
    }else{
        node = self.allNodes[indexPath.row];
    }
    return node.nodeHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NodeModelProtocol>node;
    id delegate  = self.treeDelegate;
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        node = self.currentNode.subNodes[indexPath.row];
    }else{
        node = self.allNodes[indexPath.row];
    }
    static NSString *CELLID = @"";
    NodeTreeViewCell *cell = [[NodeTreeViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID];
    if (delegate) {
        if (_treeViewDelegateFalg.viewForNode) {
            [cell setNodeView:[self.treeDelegate nodeTreeView:self viewForNode:node]];
        }else{
            NSString *error = [NSString stringWithFormat:@"NodeTreeView:%@ failed to obtain a nodeView from its delegate",self];
            NSAssert(_treeViewDelegateFalg.viewForNode, error);
        }
    }
    //刷新nodeView
    [cell.nodeView updateNodeViewWithNodeModel:node];
    //设置缩进
    if (self.indepent>0) {
        [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.frame =  CGRectMake(node.nodeLevel * self.indepent, 0, cell.contentView.frame.size.width - node.nodeLevel * self.indepent, obj.frame.size.height);
        }];
    }else{
        
        if (_treeViewDelegateFalg.indentAtNodelevel) {//delegate && [delegate respondsToSelector:@selector(nodeTreeView:indentAtNodeLevel:)
            CGFloat indentationWidth = [delegate nodeTreeView:self indentAtNodeLevel:node.nodeLevel];
            [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.frame =  CGRectMake(indentationWidth, 0,tableView.frame.size.width-indentationWidth, obj.frame.size.height);
            }];
        }
    }
    //改变高度
    UIView *nodeView = (UIView *)cell.nodeView;
    nodeView.frame = CGRectMake(nodeView.frame.origin.x, nodeView.frame.origin.y, nodeView.frame.size.width, node.nodeHeight);
    //递归调用所有子view的layoutSubviews方法，重新布局
    RecursiveLayoutSubviews(nodeView);
    return cell;
}

#pragma mark Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NodeModelProtocol>node;
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        node = self.currentNode.subNodes[indexPath.row];
    }else{
        node = self.allNodes[indexPath.row];
    }
    //判断刷新方式
    if (self.autoRefresh) {
        if (node.subNodes.count>0) {
            //自动刷新，不需要立马改变node的展开状态，RowAnimation刷新动画是固定的
            [self reloadTreeViewWithNode:node];
        }
        
    }else{
        if (node.subNodes.count>0) {
            //手动刷新，需要第一时间改变node的展开状态,由外界控制刷新时机和RowAnimation刷新动画
            node.expand = !node.expand;
        }
    }
    
    //告知代理
    if (_treeViewDelegateFalg.didSelectNode) {
        [self.treeDelegate nodeTreeView:self didSelectNode:node];
    }
    //如果是自动刷新，则在代理方法执行完后会自动执行刷新方法
    if (self.autoRefresh) {
        id nodeView = [self nodeViewForNode:node];
        if ([nodeView respondsToSelector:@selector(updateNodeViewWithNodeModel:)]) {
            [nodeView updateNodeViewWithNodeModel:node];
        }
    }
}

#pragma mark ======== Private Methods ========

- (void)reloadTreeViewWithNode:(id<NodeModelProtocol>_Nonnull)node{
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        [self reloadTreeViewWithNode:node RowAnimation:UITableViewRowAnimationLeft];
    }else{
        [self reloadTreeViewWithNode:node RowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)reloadTreeViewWithNode:(id<NodeModelProtocol>_Nonnull)node RowAnimation:(UITableViewRowAnimation)animation{
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        self.frame = CGRectMake(0, 0, self.frame.size.width, node.subTreeHeight);
        _tableview.frame = self.bounds;//self.bounds
        self.currentNode = node;
        [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:animation];
    }else{
        if (self.allNodes.count == 0) {
            //默认根节点展开，不然没有意义
            node.expand = YES;
            //初始化数据源，递归的将所有需要展开的节点，加入数据源中
            RecursiveInitializeAllNodesWithRootNode(self.allNodes, node);
            self.frame = CGRectMake(0, 0, self.frame.size.width, node.currentTreeHeight);
            _tableview.frame = self.bounds;
            [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:animation];
        }else{
            if (node.subNodes.count == 0) {//没有子节点，不需要展开也不需要收起，刷新指定cell即可
                NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:[self.allNodes indexOfObject:node]  inSection:0];
                [self.tableview reloadRowsAtIndexPaths:@[selectIndexPath] withRowAnimation:animation];
            }else{
                NSUInteger beginPosition = [self.allNodes indexOfObject:node] + 1;
                NSUInteger endPosition;
                if (TreeShouldFoldAtNode(self.autoRefresh, node)) {//需要收起所有子节点
                    id<NodeModelProtocol> fatherNode = node.fatherNode;
                    if (fatherNode!=nil && fatherNode != node) {//有父节点，并且自身不是根节点，获取跟该node节点在同一级别下的下一兄弟节点，这之间的所有元素都删除掉
                        if (node.fatherNode.subNodes.lastObject == node) {//该node节点是不是最后一个节点
                            endPosition = beginPosition + node.subNodes.count - 1;
                        }else{
                            id<NodeModelProtocol> brotherNode = [node.fatherNode.subNodes objectAtIndex:[node.fatherNode.subNodes indexOfObject:node]+1];
                            endPosition = [self.allNodes indexOfObject:brotherNode]-1;
                        }
                    }else{
                        return;
                    }
                }else{//需要展开
                    endPosition = beginPosition + node.subNodes.count - 1;
                }
                if (beginPosition < 1) {
                    return;
                }
                NSMutableArray <NSIndexPath *>*indexPathes = [NSMutableArray array];
                for (NSUInteger i = beginPosition; i<=endPosition; i++) {
                    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
                    [indexPathes addObject:indexpath];
                }
                NSRange range = NSMakeRange(beginPosition, endPosition-beginPosition+1);
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                if (TreeShouldFoldAtNode(self.autoRefresh, node)) {//node本身处于展开状态,此时应该收起来，同时收起它的所有子节点,并且将所有展开的子节点的expand值变为NO
                    if (self.autoRefresh) {
                        node.expand = !node.expand;
                    }
                    RecursiveFoldAllSubnodesAtNode(node);
                    self.frame = CGRectMake(0, 0, self.frame.size.width,node.currentTreeHeight);//self.frame.size.height-deleteHeight
                    _tableview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height+2);//self.bounds
                    //self.contentSize = CGSizeMake(0, self.frame.size.height+12);
                    [self.allNodes removeObjectsAtIndexes:set];
                    [_tableview deleteRowsAtIndexPaths:indexPathes withRowAnimation:animation];
                }else{              //node本身处于收起来的状态,此时应该展开
                    if (self.autoRefresh) {
                        node.expand = !node.expand;
                    }
                    self.frame = CGRectMake(0, 0, self.frame.size.width,node.currentTreeHeight);
                    _tableview.frame = self.bounds;
                    [self.allNodes insertObjects:node.subNodes atIndexes:set];
                    [_tableview insertRowsAtIndexPaths:indexPathes withRowAnimation:animation];
                }
            }
        }
    }
}

- (id<NodeViewProtocol>_Nonnull)nodeViewForNode:(id<NodeModelProtocol>_Nonnull)node{
    NSInteger index;
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        index = [self.currentNode.subNodes indexOfObject:node];
    }else{
        index = [self.allNodes indexOfObject:node];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NodeTreeViewCell *nodeCell = [self.tableview cellForRowAtIndexPath:indexPath];
    return nodeCell.nodeView;
}

#pragma mark ======== Setters && Getters ========
- (void)setTreeDelegate:(id<NodeTreeViewDelegate>)treeDelegate{
    _treeDelegate = treeDelegate;
    id delegate = _treeDelegate;
    _treeViewDelegateFalg.didSelectNode = [delegate respondsToSelector:@selector(nodeTreeView:didSelectNode:)];
    _treeViewDelegateFalg.indentAtNodelevel = [delegate respondsToSelector:@selector(nodeTreeView:indentAtNodeLevel:)];
    _treeViewDelegateFalg.viewForNode = [delegate respondsToSelector:@selector(nodeTreeView:viewForNode:)];
    
}
- (void)setRefreshPolicy:(NodeTreeRefreshPolicy)refreshPolicy{
    if (refreshPolicy != NodeTreeRefreshPolicyManaul && refreshPolicy != NodeTreeRefreshPolicyAutomic) {//避免外界赋值错误，如果错误会默认变为手动刷新
        refreshPolicy = NodeTreeRefreshPolicyManaul;
    }
    _refreshPolicy = refreshPolicy;
    if (NodeTreeRefreshPolicyManaul == _refreshPolicy) {//手动刷新
        self.autoRefresh = NO;
    }else{//自动刷新
        self.autoRefresh = YES;
    }
}

- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tableFooterView = [[UIView alloc]init];
        _tableview.backgroundColor = [UIColor whiteColor];
        _tableview.scrollEnabled = NO;
    }
    return _tableview;
}

- (NSMutableArray<id<NodeModelProtocol>> *)allNodes{
    if (!_allNodes) {
        _allNodes = [NSMutableArray array];
    }
    return _allNodes;
}
@end


@implementation NodeTreeViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setNodeView:(id<NodeViewProtocol>)nodeView{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _nodeView = nodeView;
    UIView *subNodeView = (UIView *)_nodeView;
    [self.contentView addSubview:subNodeView];
}
@end
