
//
//  ViewController.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "ViewController.h"

#import "NodeTreeView.h"
#import "OrganizationNode.h"
#import "SinglePersonNode.h"

#import "BreadcrumbHeaderView.h"
#import "TreeOrganizationDisplayCell.h"
#import "SearchByOrganizationInfoCell.h"
#import "SinglePersonDisplayCell.h"

#import "AttributeLabel.h"
#import "CustomSearchBar.h"

#define HEIGHT [UIScreen mainScreen].bounds.size.height

#define WIDTH [UIScreen mainScreen].bounds.size.width

@interface SearchConfiguration : NSObject
/**
 刷新方式
 */
@property (nonatomic, assign) UITableViewRowAnimation nodeTreeAnimation;

@end

@implementation SearchConfiguration

@end


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CustomSearchBarDelegate>
/**
 tableView
 */
@property (nonatomic, strong) UITableView *tableview;
/**
 面包屑
 */
@property (nonatomic, strong) BreadcrumbHeaderView *breadcrumbView;
/**
 当前展示的node
 */
@property (nonatomic, strong) BaseTreeNode *currentNode;
/**
 搜索条件配置
 */
@property (nonatomic, strong) SearchConfiguration *searchConfig;
/**
 自定义搜索框
 */
@property (nonatomic, strong) CustomSearchBar *searchBar;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableview];
    //数据处理
    BaseTreeNode *baseNode = [[BaseTreeNode alloc]init];
    baseNode.fatherNode = baseNode;
    for (int i = 0; i<10; i++) {
        if (i<8) {
            OrganizationNode *simpleNode = [[OrganizationNode alloc]init];
            simpleNode.fatherNode = baseNode;
            simpleNode.title = [NSString stringWithFormat:@"部门%d",i];
            for (int j = 0; j<5; j++) {
                SinglePersonNode *personNode = [[SinglePersonNode alloc]init];
                personNode.fatherNode = simpleNode;
                personNode.nodeHeight = 60;
                personNode.name = [NSString stringWithFormat:@"分部门%d",j];
                for (int k = 0; k<6; k++) {
                    OrganizationNode *personNode0 = [[OrganizationNode alloc]init];
                    personNode0.fatherNode = personNode;
                    personNode0.title = [NSString stringWithFormat:@"人员%d",k];
                    personNode0.nodeHeight = 80;
                    for (int m = 0; m<7; m++) {
                        SinglePersonNode *personNode1 = [[SinglePersonNode alloc]init];
                        personNode1.fatherNode = personNode0;
                        personNode1.nodeHeight = 60;
                        personNode1.name = [NSString stringWithFormat:@"张三%d",m];
                        personNode1.IDNum =@"1003022";
                        personNode1.dePartment =@"资金部-权证部";
                        
                        [personNode0.subNodes addObject:personNode1];
                    }
                    [personNode.subNodes addObject:personNode0];
                }
                [simpleNode.subNodes addObject:personNode];
            }
            [baseNode.subNodes addObject:simpleNode];
        }else{
            SinglePersonNode *singlePersonNode1 = [[SinglePersonNode alloc]init];
            singlePersonNode1.fatherNode = baseNode;
            singlePersonNode1.nodeHeight = 60;
            singlePersonNode1.name = [NSString stringWithFormat:@"张三%d",i];
            singlePersonNode1.IDNum =@"1003022";
            [baseNode.subNodes addObject:singlePersonNode1];
        }
    }
    self.currentNode = baseNode;
    [self.tableview reloadData];
}

#pragma mark ======== System Delegate ========

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"currentTreeHeight:%f",self.currentNode.currentTreeHeight);
//    return self.currentNode.currentTreeHeight;
    return self.currentNode.subTreeHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CELL_ID = @"StructureTreeOrganizationDisplayCellID";
    TreeOrganizationDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[TreeOrganizationDisplayCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
        //cell事件的block回调
        __weak typeof(self)weakSelf = self;
        cell.selectNode = ^(BaseTreeNode *node) {
            [weakSelf reloadTreeWithNode:node nodeTreeAnimation:UITableViewRowAnimationNone];
        };
    }
    if (self.currentNode) {
        [cell reloadTreeViewWithNode:self.currentNode RowAnimation:self.searchConfig.nodeTreeAnimation];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.searchBar.frame.size.height;
    }else{
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
        return 12;
}

#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.searchBar;//搜索框
    }else{
        return self.breadcrumbView;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark ======== Custom Delegate ========

- (BOOL)customSearchBarShouldReturn:(CustomSearchBar *)searchBar{
    NSLog(@"start to search");
    return YES;
}

- (void)customSearchBar:(CustomSearchBar *)searchBar textDidChange:(NSString *)text{
    NSLog(@"search text is : %@",text);
}

- (void)customSearchBar:(CustomSearchBar *)searchBar removeItem:(id<CustomSearchInputItemProtocol>)item{
    SinglePersonNode *personNode = (SinglePersonNode *)item;
    personNode.selected = NO;
    [self.tableview reloadData];
}

#pragma mark ======== Private Methods ========

- (void)reloadTreeWithNode:(BaseTreeNode *)node nodeTreeAnimation:(UITableViewRowAnimation)rowAnimation{
    //更新header
    if (node.subNodes.count>0) {
        self.currentNode = node;
        self.searchConfig.nodeTreeAnimation = rowAnimation;
        if ([node isMemberOfClass:[SinglePersonNode class]]) {
            SinglePersonNode *cusNode = (SinglePersonNode *)node;
            [self.breadcrumbView addSelectedNode:node withTitle:cusNode.name];
        }else if ([node isMemberOfClass:[OrganizationNode  class]]){
            OrganizationNode *simpleNode = (OrganizationNode *)node;
            [self.breadcrumbView addSelectedNode:simpleNode withTitle:simpleNode.title];
        }else{
            [self.breadcrumbView addSelectedNode:node withTitle:@"xxx公司"];
        }
        [self.tableview reloadData];
    }
    //更新SinglePersonNodeView
    if ([node isMemberOfClass:[SinglePersonNode class]]) {
        //expand模式下，需要self.currentNode = node
//        self.currentNode = node;
        
        
        SinglePersonNode *cusNode = (SinglePersonNode *)node;
        cusNode.inputItemtitle = cusNode.name;
        if (cusNode.selected) {
            NSLog(@"选中了%@",cusNode.name);
            [self.searchBar addItem:cusNode];
        }else{
            NSLog(@"去掉了%@",cusNode.name);
            [self.searchBar removeItem:cusNode];
        }
        [self.tableview reloadData];
    }
}

#pragma mark ======== Setters && Getters ========
- (BreadcrumbHeaderView *)breadcrumbView{
    if (!_breadcrumbView) {
        _breadcrumbView = [[BreadcrumbHeaderView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
        _breadcrumbView.alwaysBounceVertical = NO;
        _breadcrumbView.bounces = YES;
        _breadcrumbView.showsHorizontalScrollIndicator = YES;
        _breadcrumbView.backgroundColor = [UIColor whiteColor];
        __weak typeof(self)weakSelf = self;
        [_breadcrumbView addSelectedNode:weakSelf.currentNode withTitle:@"xxx公司"];
        _breadcrumbView.selectNode = ^(BaseTreeNode *node,UITableViewRowAnimation nodeTreeAnimation) {
            if (node.subNodes.count == 0) {
                NSLog(@"do nothing");
            }else{
                [weakSelf reloadTreeWithNode:node nodeTreeAnimation:nodeTreeAnimation];//此处需要指定动画刷新方式
            }
        };
    }
    return _breadcrumbView;
}

- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, WIDTH, HEIGHT-44) style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tableFooterView = [[UIView alloc]init];
        _tableview.backgroundColor = [UIColor grayColor];
    }
    return _tableview;
}

- (SearchConfiguration *)searchConfig{
    if (!_searchConfig) {
        _searchConfig = [[SearchConfiguration alloc]init];
    }
    return _searchConfig;
}

- (CustomSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[CustomSearchBar alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 44) searchBarStyle:CustomSearchBarStyleSingleLine];
        _searchBar.placeHolder = @"搜索";
        _searchBar.delegate = self;
        _searchBar.backgroundColor = [UIColor grayColor];
    }
    return _searchBar;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
