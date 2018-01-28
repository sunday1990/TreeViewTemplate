//
//  BreadcrumbHeaderView.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BreadcrumbHeaderView.h"

@interface NSString (BreadcrumbStringSize)
- (CGFloat)widthForFont:(UIFont *)font;
@end

@implementation NSString (BreadcrumbStringSize)
- (CGFloat)widthForFont:(UIFont *)font {
    CGSize size = [self sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

@end

@interface BreadcrumbHeaderView ()

@property (nonatomic, strong) NSMutableArray <BaseTreeNode *>*allNodes;

@property (nonatomic, strong) NSMutableArray <NSString *>*allTitles;

@end

@implementation BreadcrumbHeaderView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addSelectedNode:(BaseTreeNode *)node withTitle:(NSString *)title{
    [self.allNodes addObject:node];
    [self.allTitles addObject:title];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat left = 12;
    if (self.allTitles.count == self.allNodes.count) {
        for (int i = 0; i<self.allNodes.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat btnWidth;
            btn.tag = 1000+i;
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            if (i == self.allNodes.count-1) {
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn setTitle:[NSString stringWithFormat:@"%@",self.allTitles[i]] forState:UIControlStateNormal];
                [btn setImage:nil forState:UIControlStateNormal];
                btnWidth = [self.allTitles[i] widthForFont:[UIFont systemFontOfSize:14]];
            }else{
                [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [btn setTitle:[NSString stringWithFormat:@"%@->",self.allTitles[i]] forState:UIControlStateNormal];
                btnWidth = [btn.titleLabel.text widthForFont:[UIFont systemFontOfSize:14]]+6;
            }
            btn.frame = CGRectMake(left, 0, btnWidth, self.frame.size.height);
            left += btnWidth;
            if (left>[UIScreen mainScreen].bounds.size.width) {
                self.contentSize = CGSizeMake(left+([UIScreen mainScreen].bounds.size.width)/2,0);
            }else{
                self.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,0);
            }
            [self addSubview:btn];
        }
    }
}

- (void)btnClick:(UIButton *)btn{
    if (self.subviews.lastObject == btn) {
        return;
    }
    NSInteger index = btn.tag - 1000;
    BaseTreeNode *node = self.allNodes[index];
    if (node.subNodes.count>0) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag >= btn.tag) {
                [obj removeFromSuperview];
                [self.allNodes removeLastObject];
                [self.allTitles removeLastObject];
            }
        }];
    }
    if (self.selectNode) {
        self.selectNode(node,UITableViewRowAnimationNone);
    }
}

- (NSMutableArray<BaseTreeNode *> *)allNodes{
    if (!_allNodes) {
        _allNodes = [NSMutableArray array];
    }
    return _allNodes;
}

- (NSMutableArray<NSString *> *)allTitles{
    if (!_allTitles) {
        _allTitles = [NSMutableArray array];
    }
    return _allTitles;
}

@end
