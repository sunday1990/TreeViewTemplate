//
//  UIView+Category.h
//  SpaceHome
//
//  Created by suhc on 2017/7/18.
//  Copyright © 2017年 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)
#pragma mark - 设置frame
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGSize size;

#pragma mark - 设置圆角
/**上边圆角*/
@property (nonatomic, assign) CGFloat cornerOnTop;

/**下边圆角*/
@property (nonatomic, assign) CGFloat cornerOnBottom;

/**左边圆角*/
@property (nonatomic, assign) CGFloat cornerOnLeft;

/**右边圆角*/
@property (nonatomic, assign) CGFloat cornerOnRight;

/**左上圆角*/
@property (nonatomic, assign) CGFloat cornerOnTopLeft;

/**右上圆角*/
@property (nonatomic, assign) CGFloat cornerOnTopRight;

/**左下圆角*/
@property (nonatomic, assign) CGFloat cornerOnBottomLeft;

/**右下圆角*/
@property (nonatomic, assign) CGFloat cornerOnBottomRight;

/**所有圆角*/
@property (nonatomic, assign) CGFloat cornerRadius;

#pragma mark - 设置虚线边框
/**
 *  添加虚线边框(调用此方法前需要先设置frame)
 *
 *  @param borderWidth 边框宽度(虚线线条厚度)
 *  @param dashPattern @[@有色部分的宽度,@无色部分的宽度]
 *  @param color   虚线颜色
 */
- (void)addDashBorderWithWidth:(CGFloat)borderWidth dashPattern:(NSArray<NSNumber *> *)dashPattern color:(UIColor *)color;

/**
 获取当前view所在的controller
 */
- (UIViewController *)controller;

/**
 获取当前view所在的navigationController
 */
- (UINavigationController *)navigationController;

/**
 获取当前view所在的navigationBar
 */
- (UINavigationBar *)navigationBar;

@end
