//
//  NodeModelProtocol.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//  统一模型，节点模型都需要遵循该协议

#ifndef NodeModelProtocol_h
#define NodeModelProtocol_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NodeModelProtocol
@required
/**
 该节点元素自身的高度
 */
@property (nonatomic, assign) CGFloat nodeHeight;
/**
 该节点元素对应的所有子节点,添加子节点的时候，不要直接向数组中添加，而应该通过addNode的方式，这样会自动设置父节点
 */
@property (nonatomic, strong) NSMutableArray<id<NodeModelProtocol>> *subNodes;
/**
 添加node节点
 
 @param node node节点
 */
- (void)addSubNode:(id<NodeModelProtocol>)node;
/**
 删除节点
 
 @param node node节点
 */
- (void)deleteSubNode:(id<NodeModelProtocol>)node;
/**
 父节点，注意根节点的父节点需要手动设置为自身
 */
@property (nonatomic, weak) id<NodeModelProtocol> fatherNode;
/**
 该节点相对于根节点处于第几级
 */
@property (nonatomic, assign) NSInteger nodeLevel;

@optional
/**
 ID标记
 */
@property (nonatomic, copy) NSString *nodeID;
/**
该节点展开后的所有儿子节点的高度之和
 */
@property (nonatomic, assign) CGFloat subTreeHeight;
/**
 该节点所在树的当前整体高度
 */
@property (nonatomic, assign) CGFloat currentTreeHeight;
/**
 在NodeTreeViewStyleExpansion模式下，需要确定该节点是否展开
 */
@property (nonatomic, assign, getter = isExpand) BOOL expand;
/**
 从node数组中添加节点

 @param nodes nodes数组
 */
- (void)addSubNodesFromArray:(NSArray<id<NodeModelProtocol>> *)nodes;

@end

#endif /* NodeModelProtocol_h */
