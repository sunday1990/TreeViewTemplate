//
//  TreeOrganizationDisplayCell.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTreeNode.h"
#import "NodeTreeView.h"

@interface TreeOrganizationDisplayCell : UITableViewCell

@property (nonatomic, strong) BaseTreeNode *node;

@property (nonatomic, copy) void(^selectNode)(BaseTreeNode *node);

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier treeStyle:(NodeTreeViewStyle)treeStyle;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier treeStyle:(NodeTreeViewStyle)treeStyle treeRefreshPolicy:(NodeTreeRefreshPolicy)policy;
/**
 刷新node节点对应的树
 */
- (void)reloadTreeViewWithNode:(BaseTreeNode *)node RowAnimation:(UITableViewRowAnimation)animation;;

@end
