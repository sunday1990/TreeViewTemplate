//
//  SearchByOrganizationInfoCell.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/24.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "SearchByOrganizationInfoCell.h"

@interface SearchByOrganizationInfoCell()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *rightImgView;

@end

@implementation SearchByOrganizationInfoCell

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
    [self addSubview:self.titleLabel];
    [self addSubview:self.rightImgView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(12, 0, 200, self.frame.size.height);
    self.rightImgView.frame = CGRectMake(self.frame.size.width - 12 -12, self.frame.size.height/2-6, 12, 12);
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"按组织架构查找";
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor blackColor];
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
