//
//  BaseTreeNode.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//  自定义的node可以继承自这个类，也可以直接遵循NodeModelProtocol协议，然后自行配置

#import <Foundation/Foundation.h>
#import "NodeModelProtocol.h"
@interface BaseTreeNode : NSObject<NodeModelProtocol>

@end

