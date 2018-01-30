//
//  SinglePersonNodeView.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "SinglePersonNodeView.h"

@interface SinglePersonNodeView ()
/**
 姓名
 */
@property (nonatomic, strong) UILabel *nameLabel;
/**
 工号
 */
@property (nonatomic, strong) UILabel *IDLabel;
/**
 部门
 */
@property (nonatomic, strong) UILabel *departmentLabel;
/**
 选择按钮
 */
@property (nonatomic, strong) UIButton *selectBtn;

@end

@implementation SinglePersonNodeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark ======== Custom Delegate ========

#pragma mark NodeViewProtocol
- (void)updateNodeViewWithNodeModel:(id<NodeModelProtocol>)node{
    //将node转为该view对应的指定node，然后执行操作
    SinglePersonNode *personNode = (SinglePersonNode *)node;
    if (personNode.selected == YES) {
        self.selectBtn.selected = YES;
    }else{
        self.selectBtn.selected = NO;
        
    }
    _nameLabel.text = personNode.name;
    _IDLabel.text = personNode.IDNum;
    _departmentLabel.text = personNode.dePartment;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _selectBtn.frame = CGRectMake(12, self.frame.size.height/2-6, 12, 12);
    _nameLabel.frame = CGRectMake(12+12+12, 0, 60, self.frame.size.height);
    _IDLabel.frame = CGRectMake(12+12+12+60+12, self.frame.size.height/2-7, 60, 14);
    _departmentLabel.frame = CGRectMake(12+12+12+60+12+60+12, 0, self.frame.size.width-(12+12+12+60+12+60+12+12), self.frame.size.height);
}

#pragma mark ======== Private Methods ========

- (void)setupSubviews{
    [self addSubview:self.selectBtn];
    [self addSubview:self.nameLabel];
    [self addSubview:self.IDLabel];
    [self addSubview:self.departmentLabel];
}

- (void)btnSelect:(UIButton *)btn{
    btn.selected = !btn.selected;
}

#pragma mark ======== Setters && Getters ========

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.numberOfLines = 0;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    }
    return _nameLabel;
}

- (UILabel *)IDLabel{
    if (!_IDLabel) {
        _IDLabel = [[UILabel alloc]init];
        _IDLabel.font = [UIFont systemFontOfSize:14];
        _IDLabel.textColor = [UIColor blackColor];
    }
    return _IDLabel;
}

- (UILabel *)departmentLabel{
    if (!_departmentLabel) {
        _departmentLabel = [[UILabel alloc]init];
        _departmentLabel.font = [UIFont systemFontOfSize:14];
        _departmentLabel.textColor = [UIColor blackColor];
        _departmentLabel.numberOfLines = 0;
        _departmentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _departmentLabel;
}

- (UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setImage:[UIImage imageNamed:@"node_normal"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"node_selected"] forState:UIControlStateSelected];
    }
    return _selectBtn;
}

@end
