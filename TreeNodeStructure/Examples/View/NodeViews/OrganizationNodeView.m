//
//  OrganizationNodeView.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "OrganizationNodeView.h"

@interface OrganizationNodeView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *rightImgView;

@end

@implementation OrganizationNodeView

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
    OrganizationNode *simpleNode = (OrganizationNode *)node;
    self.titleLabel.text = simpleNode.title;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(12, 0, 200, self.frame.size.height);
    self.rightImgView.frame = CGRectMake(self.frame.size.width - 12 -12, self.frame.size.height/2-6, 12, 12);
}

#pragma mark ======== Private Methods ========

- (void)setupSubviews{
    [self addSubview:self.titleLabel];
    [self addSubview:self.rightImgView];
}

#pragma mark ======== Setters && Getters ========
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentLeft;

    }
    return _titleLabel;
}

- (UIImageView *)rightImgView{
    if (!_rightImgView) {
        _rightImgView = [[UIImageView alloc]init];
        _rightImgView.image = [UIImage imageNamed:@"next"];

    }
    return _rightImgView;
}

@end
