//
//  NodeViewProtocol.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//  统一视图，节点视图都需要遵循该协议

#ifndef NodeViewProtocol_h
#define NodeViewProtocol_h
#import "NodeModelProtocol.h"

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

#endif /* NodeViewProtocol_h */
