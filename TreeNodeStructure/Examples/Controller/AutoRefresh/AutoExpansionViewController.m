//
//  AutoExpansionViewController.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/31.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "AutoExpansionViewController.h"

@interface AutoExpansionViewController ()

@end

@implementation AutoExpansionViewController
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID = @"StructureTreeOrganizationDisplayCellID";
    TreeOrganizationDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID treeStyle:NodeTreeViewStyleExpansion treeRefreshPolicy:NodeTreeRefreshPolicyAutomic];
        __weak typeof(self)weakSelf = self;
        cell.selectNode = ^(BaseTreeNode *node) {
            [weakSelf.tableview reloadData];
        };
    }
    [cell reloadTreeViewWithNode:self.currentNode RowAnimation:UITableViewRowAnimationFade];
    
    return cell;
}

#pragma mark ======== Custom Delegate ========

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Event Response ========

#pragma mark ======== Private Methods ========

#pragma mark ======== Setters && Getters ========

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


