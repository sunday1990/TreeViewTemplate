//
//  BreadcrumbHeaderView.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTreeNode.h"

@interface BreadcrumbHeaderView : UIScrollView

@property (nonatomic, copy) void(^selectNode)(BaseTreeNode *node,UITableViewRowAnimation nodeTreeAnimation);

- (void)addSelectedNode:(BaseTreeNode *)node withTitle:(NSString *)title;

@end
