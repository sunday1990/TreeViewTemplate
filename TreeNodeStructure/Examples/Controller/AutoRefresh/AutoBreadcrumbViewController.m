//
//  AutoBreadcrumbViewController.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/31.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "AutoBreadcrumbViewController.h"
#import "BreadcrumbHeaderView.h"

@interface AutoBreadcrumbViewController ()
/**
 面包屑
 */
@property (nonatomic, strong) BreadcrumbHeaderView *breadcrumbView;

@end

@implementation AutoBreadcrumbViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======== NetWork ========

#pragma mark ======== System Delegate ========

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.currentNode.subTreeHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 12;
}

#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID = @"StructureTreeOrganizationDisplayCellID";
    TreeOrganizationDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID treeStyle:NodeTreeViewStyleBreadcrumbs treeRefreshPolicy:NodeTreeRefreshPolicyAutomic];
        //cell事件的block回调,只负责将所选择的点传递出来，更新headerview，不需要手动刷新
        __weak typeof(self)weakSelf = self;
        cell.selectNode = ^(BaseTreeNode *node) {
            if (node.subNodes.count > 0) {
                [weakSelf selectNode:node nodeTreeAnimation:weakSelf.rowAnimation];
            }
        };
    }
    [cell reloadTreeViewWithNode:self.currentNode RowAnimation:self.rowAnimation];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.breadcrumbView;
}

#pragma mark ======== Custom Delegate ========

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Method Overrides ========
- (void)selectNode:(BaseTreeNode *)node nodeTreeAnimation:(UITableViewRowAnimation)rowAnimation{
    //更新header
    if (node.subNodes.count>0) {
        if ([node isMemberOfClass:[SinglePersonNode class]]) {
            SinglePersonNode *personNode = (SinglePersonNode *)node;
            [self.breadcrumbView addSelectedNode:personNode withTitle:personNode.name];
        }else if ([node isMemberOfClass:[OrganizationNode  class]]){
            OrganizationNode *orgNode = (OrganizationNode *)node;
            [self.breadcrumbView addSelectedNode:orgNode withTitle:orgNode.title];
        }else{
            [self.breadcrumbView addSelectedNode:node withTitle:@"xxx公司"];
        }
    }
}

#pragma mark ======== Event Response ========

#pragma mark ======== Private Methods ========

#pragma mark ======== Setters && Getters ========
- (BreadcrumbHeaderView *)breadcrumbView{
    if (!_breadcrumbView) {
        _breadcrumbView = [[BreadcrumbHeaderView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
        _breadcrumbView.alwaysBounceVertical = NO;
        _breadcrumbView.bounces = YES;
        _breadcrumbView.showsHorizontalScrollIndicator = YES;
        _breadcrumbView.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0];
        __weak typeof(self)weakSelf = self;
        [_breadcrumbView addSelectedNode:weakSelf.currentNode withTitle:@"xxx公司"];
        _breadcrumbView.selectNode = ^(BaseTreeNode *node,UITableViewRowAnimation nodeTreeAnimation) {
            if (node.subNodes.count == 0) {
                NSLog(@"do nothing");
            }else{
                weakSelf.currentNode = node;
                weakSelf.rowAnimation = UITableViewRowAnimationRight;
                [weakSelf selectNode:node nodeTreeAnimation:weakSelf.rowAnimation];
                [weakSelf.tableview reloadData];
            }
        };
    }
    return _breadcrumbView;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


