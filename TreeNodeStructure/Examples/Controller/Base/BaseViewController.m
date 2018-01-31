//
//  BaseViewController.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/30.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation BaseViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.rowAnimation = UITableViewRowAnimationNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableview];
    [self.view addSubview:self.dismissBtn];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======== NetWork ========

#pragma mark ======== System Delegate ========

#pragma mark ======== Custom Delegate ========
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentNode?1:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.currentNode.currentTreeHeight;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID = @"StructureTreeOrganizationDisplayCellID";
    TreeOrganizationDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID treeStyle:NodeTreeViewStyleExpansion];
        //cell事件的block回调
        __weak typeof(self)weakSelf = self;
        cell.selectNode = ^(BaseTreeNode *node) {
            [weakSelf selectNode:node nodeTreeAnimation:UITableViewRowAnimationNone];
        };
    }
    [cell reloadTreeViewWithNode:self.currentNode RowAnimation:UITableViewRowAnimationNone];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Event Response ========
- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ======== Private Methods ========
- (void)loadData{
    //数据处理
    BaseTreeNode *baseNode = [[BaseTreeNode alloc]init];
    baseNode.fatherNode = baseNode;//父节点等于自身
    _baseNode = baseNode;
    for (int i = 0; i<10; i++) {
        if (i<8) {
            OrganizationNode *simpleNode = [[OrganizationNode alloc]init];
            simpleNode.title = [NSString stringWithFormat:@"部门%d",i];
            for (int j = 0; j<5; j++) {
                OrganizationNode *personNode = [[OrganizationNode alloc]init];
                personNode.nodeHeight = 60;
                personNode.title = [NSString stringWithFormat:@"%@的分部门%d",simpleNode.title,j];
                for (int k = 0; k<6; k++) {
                    OrganizationNode *personNode0 = [[OrganizationNode alloc]init];
                    personNode0.title = [NSString stringWithFormat:@"分部门%d的人员%d",j,k];
                    personNode0.nodeHeight = 80;
                    for (int m = 0; m<7; m++) {
                        SinglePersonNode *personNode1 = [[SinglePersonNode alloc]init];
                        personNode1.nodeHeight = 60;
                        personNode1.name = [NSString stringWithFormat:@"%@-张三%d",personNode.title,m];
                        personNode1.IDNum =@"1003022";
                        personNode1.dePartment =@"资金部";
                        [personNode0 addSubNode:personNode1];
                    }
                    [personNode addSubNode:personNode0];
                }
                [simpleNode addSubNode:personNode];
            }
            [baseNode addSubNode:simpleNode];
        }else{
            SinglePersonNode *singlePersonNode1 = [[SinglePersonNode alloc]init];
            singlePersonNode1.nodeHeight = 60;
            singlePersonNode1.name = [NSString stringWithFormat:@"张三%d",i];
            singlePersonNode1.IDNum =@"1003022";
            [baseNode addSubNode:singlePersonNode1];
        }
    }
    self.currentNode = baseNode;
    [self.tableview reloadData];
}

- (void)selectNode:(BaseTreeNode *)node nodeTreeAnimation:(UITableViewRowAnimation)rowAnimation{
    self.currentNode = node;
    [self.tableview reloadData];
}

#pragma mark ======== Setters && Getters ========
- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) style:UITableViewStylePlain];
        _tableview.tableFooterView = [[UIView alloc]init];
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    return _tableview;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(6,12 , 44, 40);
        _dismissBtn.contentMode = UIViewContentModeLeft;
        [_dismissBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
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


