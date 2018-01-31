//
//  BaseViewController.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/30.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssistMicros.h"

#import "OrganizationNode.h"
#import "SinglePersonNode.h"

#import "TreeOrganizationDisplayCell.h"

@interface BaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    BaseTreeNode *_baseNode;
}
/**
 tableView
 */
@property (nonatomic, strong) UITableView *tableview;
/**
 当前展示的node
 */
@property (nonatomic, strong) BaseTreeNode *currentNode;
/**
 tableview展开方式
 */
@property (nonatomic, assign) UITableViewRowAnimation rowAnimation;

- (void)selectNode:(BaseTreeNode *)node nodeTreeAnimation:(UITableViewRowAnimation)rowAnimation;

@end

