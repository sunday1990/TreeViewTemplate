//
//  BreadcrumbViewController.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/30.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BreadcrumbViewController.h"
#import "BreadcrumbHeaderView.h"

@interface BreadcrumbViewController ()
/**
 面包屑
 */
@property (nonatomic, strong) BreadcrumbHeaderView *breadcrumbView;
@end

@implementation BreadcrumbViewController
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
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID treeStyle:NodeTreeViewStyleBreadcrumbs];
        //cell事件的block回调
        __weak typeof(self)weakSelf = self;
        cell.selectNode = ^(BaseTreeNode *node) {
            #warning 此处可以模拟网络获取节点进行展示
            [weakSelf selectNode:node nodeTreeAnimation:UITableViewRowAnimationFade];
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
    self.rowAnimation = rowAnimation;
    //更新header
    if (node.subNodes.count>0) {
        self.currentNode = node;
        if ([node isMemberOfClass:[SinglePersonNode class]]) {
            SinglePersonNode *cusNode = (SinglePersonNode *)node;
            [self.breadcrumbView addSelectedNode:node withTitle:cusNode.name];
        }else if ([node isMemberOfClass:[OrganizationNode  class]]){
            OrganizationNode *simpleNode = (OrganizationNode *)node;
            [self.breadcrumbView addSelectedNode:simpleNode withTitle:simpleNode.title];
        }else{
            [self.breadcrumbView addSelectedNode:node withTitle:@"xxx公司"];
        }
    }
    [self.tableview reloadData];
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
                [weakSelf selectNode:node nodeTreeAnimation:nodeTreeAnimation];
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


