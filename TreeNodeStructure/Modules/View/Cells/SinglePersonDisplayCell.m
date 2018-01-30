//
//  SinglePersonDisplayCell.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/24.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "SinglePersonDisplayCell.h"
#import "SinglePersonNodeView.h"

@interface SinglePersonDisplayCell ()

@property (nonatomic, strong) SinglePersonNodeView *singlePersonView;

@end

@implementation SinglePersonDisplayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    [self addSubview:self.singlePersonView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.singlePersonView.frame = self.bounds;
}

- (void)setModel:(SinglePersonNode *)model{
    _model = model;
    [self.singlePersonView updateNodeViewWithNodeModel:model];
}

- (SinglePersonNodeView *)SinglePersonNodeView{
    if (!_singlePersonView) {
        _singlePersonView = [[SinglePersonNodeView alloc]init];
    }
    return _singlePersonView;
}


@end
