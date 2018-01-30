//
//  SinglePersonNode.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTreeNode.h"
@interface SinglePersonNode : BaseTreeNode
/**
 姓名
 */
@property (nonatomic, copy) NSString *name;
/**
 工号
 */
@property (nonatomic, copy) NSString *IDNum;
/**
 部门
 */
@property (nonatomic, copy) NSString *dePartment;
/**
 是否选中
 */
@property (nonatomic, assign,getter=isSelected) BOOL selected;

@end
