//
//  AttributeLabel.h
//  AttributeLabel
//
//  Created by ccSunday on 2017/8/17.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

/**
 方便的实现富文本效果，把需要高亮显示的文字用<>包括起来,把需要引入的图片名字用[]包括起来即可，如果需要显示<和>或者[和]，则在前面加\\进行转义
 例如：@"中华人民共和国<万岁>![love.png]我<中华>!";输出效果是：中华人民共和国万岁!❤️我中华!
 其中“万岁”高亮显示，并且可以点击(在实现回调block的前提下)
 */
#import <UIKit/UIKit.h>

@interface AttributeLabel : UITextView

/**高亮文字字体大小，默认和普通文本字体大小一致*/
@property (nonatomic, strong) UIFont *highlightFont;

/**高亮文字字体颜色，默认和普通文本颜色相同*/
@property (nonatomic, strong) UIColor *highlightColor;

/**高亮文字点击回调*/
@property (nonatomic, copy) void(^HighlightAction)(NSString *highlightText);

/**文字之间的垂直间距*/
@property (nonatomic, assign) CGFloat lineSpacing;

/**首行缩进*/
@property (nonatomic, assign) CGFloat firstLineHeadIndent;

/**段落之间的间距*/
@property (nonatomic, assign) CGFloat paragraphSpacing;

@end
