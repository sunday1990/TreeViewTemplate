//
//  NodeTreeView.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "NodeTreeView.h"

@interface NodeTreeViewCell:UITableViewCell

@property (nonatomic,strong)id<NodeViewProtocol>nodeView;

@end

@interface NodeTreeView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSMutableArray <id<NodeModelProtocol>>*allNodes;

@property (nonatomic, strong) id<NodeModelProtocol>currentNode;

@property (nonatomic, assign) NodeTreeViewStyle treeViewStyle;

@end

@implementation NodeTreeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame treeViewStyle:(NodeTreeViewStyle)style{
    if (self = [super initWithFrame:frame]) {
        self.treeViewStyle = style;
        [self addSubview:self.tableview];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.treeViewStyle = NodeTreeViewStyleBreadcrumbs;//默认
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
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        node = self.currentNode.subNodes[indexPath.row];
    }else{
        node = self.allNodes[indexPath.row];
    }
    static NSString *CELLID = @"";
    NodeTreeViewCell *cell = [[NodeTreeViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID];
    if (self.treeDelegate) {
        [cell setNodeView:[self.treeDelegate nodeTreeView:self viewForNode:node]];
    }
    //刷新nodeView
    [cell.nodeView updateNodeViewWithNodeModel:node];
    UIView *nodeView = (UIView *)cell.nodeView;
    nodeView.frame = CGRectMake(nodeView.frame.origin.x, nodeView.frame.origin.y, nodeView.frame.size.width, node.nodeHeight);
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
#warning 此处应该根据是否需要手动刷新来执行相对应的代理事件
    if (self.treeDelegate) {
        [self.treeDelegate nodeTreeView:self didSelectNode:node];
    }
    if (!self.manualRefresh) {
        if (node.subNodes.count>0) {
            [self reloadTreeViewWithNode:node];
        }
    }
}

#pragma mark ======== Custom Delegate ========

#pragma mark ======== Event Response ========

#pragma mark ======== Private Methods ========

- (void)reloadTreeViewWithNode:(id<NodeModelProtocol>_Nonnull)node{
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        [self reloadTreeViewWithNode:node RowAnimation:UITableViewRowAnimationLeft];
    }else{
        [self reloadTreeViewWithNode:node RowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)reloadTreeViewWithNode:(id<NodeModelProtocol>_Nonnull)node RowAnimation:(UITableViewRowAnimation)animation{
    if (NodeTreeViewStyleBreadcrumbs == self.treeViewStyle) {
        self.frame = CGRectMake(0, 0, self.frame.size.width, node.subTreeHeight);
        self.currentNode = node;
        _tableview.frame = self.bounds;
        //更改数据源
        [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:animation];
    }else{
        if (self.allNodes.count == 0) {//初始为0，为根节点，最好增加属性判断一下是不是根节点
            [self.allNodes addObjectsFromArray:node.subNodes];
            self.frame = CGRectMake(0, 0, self.frame.size.width, node.subTreeHeight);
            _tableview.frame = self.bounds;
            [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:animation];
        }else{
            if (node.subNodes.count == 0) {//没有子节点，不需要展开也不需要收起
                NSLog(@"点击了叶子节点");
                [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:animation];
            }else{
                NSUInteger beginPosition = [self.allNodes indexOfObject:node] + 1;
                NSUInteger endPosition;
                if (node.isExpand) {//需要收起所有子节点
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
                if (node.isExpand) {//node本身处于展开状态,此时应该收起来，同时收起它的所有子节点,并且将所有展开的子节点的expand值变为NO
                    node.expand = !node.expand;
                    [self foldAllSubnodesOfNode:node];
                    __block NSUInteger deleteHeight = 0;
                    for (NSUInteger i = beginPosition; i<endPosition; i++) {
                        id<NodeModelProtocol> deleteNode = self.allNodes[i];
                        deleteHeight +=deleteNode.nodeHeight;
                    }
                    self.frame = CGRectMake(0, 0, self.frame.size.width,self.frame.size.height-deleteHeight);//?self.frame.size.height-node.subTreeHeight
                    _tableview.frame = self.bounds;
                    [self.allNodes removeObjectsAtIndexes:set];
                    [_tableview deleteRowsAtIndexPaths:indexPathes withRowAnimation:animation];
                }else{              //node本身处于收起来的状态,此时应该展开
                    node.expand = !node.expand;
                    self.frame = CGRectMake(0, 0, self.frame.size.width,self.frame.size.height+node.subTreeHeight);//self.frame.size.height+node.subTreeHeight
                    _tableview.frame = self.bounds;
                    [self.allNodes insertObjects:node.subNodes atIndexes:set];
                    [_tableview insertRowsAtIndexPaths:indexPathes withRowAnimation:animation];
                }
            }
        }
    }
}

#pragma mark 收起所有子节点
- (void)foldAllSubnodesOfNode:(id<NodeModelProtocol>)node{
    if (node.subNodes.count>0) {
        [node.subNodes enumerateObjectsUsingBlock:^(id<NodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isExpand) {
                obj.expand = NO;
                [self foldAllSubnodesOfNode:obj];
            }
        }];
    }else{
        return;
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
