//
//  UIView+Category.m
//  SpaceHome
//
//  Created by suhc on 2017/7/18.
//  Copyright © 2017年 David. All rights reserved.
//

#import "UIView+Category.h"
#import <objc/runtime.h>
@implementation UIView (Category)

- (void)setTop:(CGFloat)top{
    if (self.top != top) {
        self.frame = CGRectMake(self.left, top, self.width, self.height);
    }
}

- (CGFloat)top{
    return self.frame.origin.y;
}

- (void)setBottom:(CGFloat)bottom {
    if (self.bottom != bottom) {
        self.frame = CGRectMake(self.left, bottom - self.height, self.width, self.height);
    }
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setLeft:(CGFloat)left{
    if (self.left != left) {
        self.frame = CGRectMake(left, self.top, self.width, self.height);
    }
}

- (CGFloat)left{
    return self.frame.origin.x;
}

- (void)setRight:(CGFloat)right {
    if (self.right != right) {
        self.frame = CGRectMake(self.right - self.width, self.top, self.width, right);
    }
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    if (self.width != width) {
        self.frame = CGRectMake(self.left, self.top, width, self.height);
    }
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    if (self.height != height) {
        self.frame = CGRectMake(self.left, self.top, self.width, height);
    }
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

#pragma mark - 设置圆角
- (void)setCornerOnTop:(CGFloat)cornerOnTop{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(cornerOnTop, cornerOnTop)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    objc_setAssociatedObject(self, @selector(cornerOnTop), @(cornerOnTop), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerOnTop{
    return [objc_getAssociatedObject(self, @selector(cornerOnTop)) floatValue];
}

- (void)setCornerOnBottom:(CGFloat)cornerOnBottom{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(cornerOnBottom, cornerOnBottom)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    objc_setAssociatedObject(self, @selector(cornerOnBottom), @(cornerOnBottom), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerOnBottom{
    return [objc_getAssociatedObject(self, @selector(cornerOnBottom)) floatValue];
}

- (void)setCornerOnLeft:(CGFloat)cornerOnLeft{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                           cornerRadii:CGSizeMake(cornerOnLeft, cornerOnLeft)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    objc_setAssociatedObject(self, @selector(cornerOnLeft), @(cornerOnLeft), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerOnLeft{
    return [objc_getAssociatedObject(self, @selector(cornerOnLeft)) floatValue];
}

- (void)setCornerOnRight:(CGFloat)cornerOnRight{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(cornerOnRight, cornerOnRight)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    objc_setAssociatedObject(self, @selector(cornerOnRight), @(cornerOnRight), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerOnRight{
    return [objc_getAssociatedObject(self, @selector(cornerOnRight)) floatValue];
}

- (void)setCornerOnTopLeft:(CGFloat)cornerOnTopLeft{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:UIRectCornerTopLeft
                                           cornerRadii:CGSizeMake(cornerOnTopLeft, cornerOnTopLeft)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    objc_setAssociatedObject(self, @selector(cornerOnTopLeft), @(cornerOnTopLeft), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerOnTopLeft{
    return [objc_getAssociatedObject(self, @selector(cornerOnTopLeft)) floatValue];
}

- (void)setCornerOnTopRight:(CGFloat)cornerOnTopRight{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:UIRectCornerTopRight
                                           cornerRadii:CGSizeMake(cornerOnTopRight, cornerOnTopRight)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    objc_setAssociatedObject(self, @selector(cornerOnTopRight), @(cornerOnTopRight), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerOnTopRight{
    return [objc_getAssociatedObject(self, @selector(cornerOnTopRight)) floatValue];
}

- (void)setCornerOnBottomLeft:(CGFloat)cornerOnBottomLeft{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:UIRectCornerBottomLeft
                                           cornerRadii:CGSizeMake(cornerOnBottomLeft, cornerOnBottomLeft)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    objc_setAssociatedObject(self, @selector(cornerOnBottomLeft), @(cornerOnBottomLeft), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerOnBottomLeft{
    return [objc_getAssociatedObject(self, @selector(cornerOnBottomLeft)) floatValue];
}

- (void)setCornerOnBottomRight:(CGFloat)cornerOnBottomRight{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:UIRectCornerBottomRight
                                           cornerRadii:CGSizeMake(cornerOnBottomRight, cornerOnBottomRight)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    objc_setAssociatedObject(self, @selector(cornerOnBottomRight), @(cornerOnBottomRight), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerOnBottomRight{
    return [objc_getAssociatedObject(self, @selector(cornerOnBottomRight)) floatValue];
}

- (void)setCornerRadius:(CGFloat)cornerRadius{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                          cornerRadius:cornerRadius];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    objc_setAssociatedObject(self, @selector(cornerRadius), @(cornerRadius), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)cornerRadius{
    return [objc_getAssociatedObject(self, @selector(cornerRadius)) floatValue];
}

#pragma mark - 设置虚线边框
- (void)addDashBorderWithWidth:(CGFloat)borderWidth dashPattern:(NSArray<NSNumber *> *)dashPattern color:(UIColor *)color{
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = self.bounds;
    borderLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:self.layer.cornerRadius].CGPath;
    borderLayer.lineWidth = borderWidth;
    //虚线边框
    borderLayer.lineDashPattern = dashPattern;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = color.CGColor;
    [self.layer addSublayer:borderLayer];
}

//获取当前view所在的controller
- (UIViewController *)controller {
    for (UIView *next = self.superview; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

//获取当前view所在的navigationController
- (UINavigationController *)navigationController {
    UIViewController *controller = self.controller;
    if (controller.navigationController) {
        return controller.navigationController;
    }else{
        return nil;
    }
}

//获取当前view所在的navigationBar
- (UINavigationBar *)navigationBar{
    if (self.navigationController) {
        return self.navigationController.navigationBar;
    }else{
        return nil;
    }
}

@end
