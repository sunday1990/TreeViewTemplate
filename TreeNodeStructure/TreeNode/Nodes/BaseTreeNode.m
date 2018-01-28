//
//  BaseTreeNode.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BaseTreeNode.h"

@implementation BaseTreeNode
@synthesize
subNodes = _subNodes,
nodeHeight = _nodeHeight,
nodeID = _nodeID,
fatherNode = _fatherNode,
/*NodeTreeViewStyleBreadcrumbs*/
subTreeHeight = _subTreeHeight,
/*NodeTreeViewStyleExpansion*/
expand = _expand,
currentTreeHeight = _currentTreeHeight;

- (instancetype)init{
    if (self = [super init]) {
        _subNodes = [NSMutableArray array];
        _nodeHeight = 44;
        _subTreeHeight = 0;
    }
    return self;
}

- (CGFloat)subTreeHeight{
    if (!_subTreeHeight) {
        __block CGFloat tempSubTreeHeight;
        [self.subNodes enumerateObjectsUsingBlock:^(id<NodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            tempSubTreeHeight += obj.nodeHeight;
        }];
        _subTreeHeight = tempSubTreeHeight;
    }
    return _subTreeHeight;
}

- (CGFloat)currentTreeHeight{
    _currentTreeHeight =  [self getCurrentTreeHeightWithNode:self];
    return _currentTreeHeight;
}

- (CGFloat)getCurrentTreeHeightWithNode:(id<NodeModelProtocol>)node{
    id<NodeModelProtocol> rootNode = [self getRootNode:node];
//    NSLog(@"rootNode:%@",rootNode);
    return [self getTreeHeightAtFatherNode:rootNode];
    
    
    
    CGFloat treeHeight;
    if (node == node.fatherNode||node.fatherNode == nil) {
        return node.subTreeHeight;
    }else{//自身不等于父节点
        if (node.isExpand) {
            treeHeight = node.subTreeHeight;
        }else{
            treeHeight = 0;
        }
        
        
        __block CGFloat otherHeight = 0;
        [node.fatherNode.subNodes enumerateObjectsUsingBlock:^(id<NodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {//兄弟节点的孙子节点，也有可能处于展开状态，需要遍历到最内层
            if (obj.isExpand && obj!= node) {
                //此处在继续遍历obj的所有子节点，如果仍然有展开的，则继续相加，直至没有展开的
                
                otherHeight += obj.subTreeHeight;
            }
        }];
        
        node = node.fatherNode;
        return treeHeight + otherHeight + [self getCurrentTreeHeightWithNode:node];
    }
}

#warning 高度计算错误
#pragma mark 根据父节点获取该父节点树的高度，先序遍历树
- (CGFloat)getTreeHeightAtFatherNode:(id<NodeModelProtocol>)fatherNode{
    CGFloat treeHeight = 0;
//    if (fatherNode.subNodes.count == 0||!fatherNode.isExpand) {//叶子节点
//        return 0;
//    }else{
//        for (id<NodeModelProtocol>obj in fatherNode.subNodes) {
//            if (obj.isExpand) {
//               treeHeight += [self getTreeHeightAtFatherNode:obj];
//            }
//        }
//        treeHeight = fatherNode.subTreeHeight;
//        return treeHeight;
//    }
    if (fatherNode.subNodes.count == 0||!fatherNode.isExpand) {//叶子节点
        return 0;
    }
    treeHeight = fatherNode.subTreeHeight;
    for (id<NodeModelProtocol>obj in fatherNode.subNodes) {
        if (obj.isExpand) {
            NSLog(@"内部height:%f",obj.subTreeHeight);
            treeHeight += obj.subTreeHeight;
//            obj.subTreeHeight;//记录该值，加入计算,这个值需要记录下来，或者直接进行添加
            //递归
            [self getTreeHeightAtFatherNode:obj];
        }
    }
    return treeHeight;
    
}

#pragma mark 获取根节点
- (id<NodeModelProtocol>)getRootNode:(id<NodeModelProtocol>)node{
    if (node.fatherNode == node) {
        node.expand = YES;
        return node;
    }else{
        node = node.fatherNode;
        return  [self getRootNode:node];
    }
}

- (void)addNode:(id<NodeModelProtocol>)node{
    [self.subNodes addObject:node];
}
/**
 从node数组中添加节点
 
 @param nodes nodes数组
 */
- (void)addNodesFromArray:(NSArray<id<NodeModelProtocol>> *)nodes{
    [self.subNodes addObjectsFromArray:nodes];
    
}
/**
 删除节点
 
 @param node node节点
 */
- (void)deleteNode:(id<NodeModelProtocol>)node{
    [self.subNodes removeObject:node];
}

@end
