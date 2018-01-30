//
//  CustomSearchBar.m
//  CustomSearchBar
//
//  Created by ccSunday on 2018/1/25.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "CustomSearchBar.h"
#import <objc/runtime.h>

CGFloat margin = 12;//元素间距与边界间距均为12
CGFloat cellHeight = 44;

#pragma mark ExtendTextFieldDelegate

@protocol ExtendTextFieldDelegate <UITextFieldDelegate>
@optional
/**点击了删除键 */
- (void)textFieldDidDeleteBackward:(UITextField *)textField;
@end

#pragma mark UITextField + DeleteBackward

@interface UITextField (DeleteBackward)
@property (nonatomic, assign) id<ExtendTextFieldDelegate>delegate;
@end

@implementation UITextField (DeleteBackward)
+ (void)load {
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"deleteBackward"));
    Method method2 = class_getInstanceMethod([self class], @selector(exchange_deleteBackward));
    method_exchangeImplementations(method1, method2);
}

- (void)exchange_deleteBackward {
    [self exchange_deleteBackward];
    if ([self.delegate respondsToSelector:@selector(textFieldDidDeleteBackward:)]){
        id <ExtendTextFieldDelegate> delegate  = (id<ExtendTextFieldDelegate>)self.delegate;
        [delegate textFieldDidDeleteBackward:self];
    }
}
@end

#pragma mark NSString + _StringSize
@interface NSString (_StringSize)
- (CGFloat)widthForFont:(UIFont *)font;
@end

@implementation NSString (_StringSize)
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

#pragma mark UIView + _FrameExtension
@interface UIView (_FrameExtension)
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
@end

@implementation UIView (_FrameExtension)

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
@end

#pragma mark CustomSearchBar

@interface CustomSearchBar()<ExtendTextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *leftImgView;

@property (nonatomic, assign) CustomSearchBarStyle searchBarstyle;

@end

@implementation CustomSearchBar

static void *DeleteBackwardItemSelectedKey = &DeleteBackwardItemSelectedKey;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame searchBarStyle:(CustomSearchBarStyle)style{
    if (self = [super initWithFrame:frame]) {
        self.searchBarstyle = style;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChanged) name:UITextFieldTextDidChangeNotification object:nil];
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.searchBarstyle == CustomSearchBarStyleSingleLine) {
        self.scrollView.frame = CGRectMake(0, 0, self.width-200, self.height);
        self.textField.frame = CGRectMake(self.scrollView.right, 0, self.width-self.scrollView.width, self.height);
        if (self.dataArray.count>0) {
            UILabel *lastLabel = self.scrollView.subviews.lastObject;
            if (lastLabel.right>self.scrollView.width) {
                [self.scrollView setContentOffset:CGPointMake(lastLabel.right-self.scrollView.width+12, 0) animated:YES];
                self.scrollView.contentSize = CGSizeMake(lastLabel.right+12,0);
            }else{//删除
//                UILabel *firstLabel = self.scrollView.subviews.firstObject;
                NSLog(@"总长度小于scrollview的宽度");
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                self.scrollView.contentSize = CGSizeMake(self.scrollView.width,0);
            }
        }else{
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width,0);
        }
    }else{
        if (self.dataArray.count>0) {
            UILabel *label = [self.subviews lastObject];
            self.textField.frame = CGRectMake(label.right+margin, label.top-(44/2-25/2), self.width - label.right - margin, 44);
            self.height = label.bottom + (44/2-25/2);
        }else{
            self.textField.frame = CGRectMake(0, 0, self.width, self.height);
            self.height = 44;
        }
    }
}

#pragma mark ======= SystemDelegate =======
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    id delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(customSearchBarShouldReturn:)]) {
        return  [delegate customSearchBarShouldReturn:self];
    }else{
        return YES;
    }
}

#pragma mark ======= CustomDelegate =======
- (void)textFieldDidDeleteBackward:(UITextField *)textField{
    if (textField.text.length == 0) {
        if (self.dataArray.count>0) {
            UILabel *lastLabel;
            if (self.searchBarstyle == CustomSearchBarStyleSingleLine) {
                lastLabel = [self.scrollView.subviews lastObject];
            }else{
                 lastLabel = [self.subviews lastObject];
            }
            //get if selected
            BOOL selected = (BOOL)objc_getAssociatedObject(lastLabel, DeleteBackwardItemSelectedKey);
            if (selected) {
                [lastLabel removeFromSuperview];
                id delegate = self.delegate;
                id<CustomSearchInputItemProtocol>item = [self.dataArray lastObject];
                [self.dataArray removeLastObject];
                [self layoutSubviews];
                if (delegate && [delegate respondsToSelector:@selector(customSearchBar:removeItem:)]) {
                    [delegate customSearchBar:self removeItem:item];
                }
            }else{
                //set
                objc_setAssociatedObject(lastLabel, DeleteBackwardItemSelectedKey, @(YES), OBJC_ASSOCIATION_RETAIN);
                lastLabel.backgroundColor = [UIColor grayColor];
            }
        }
    }
}

#pragma mark ======= Notifications =======

- (void)textFieldTextDidChanged{
    UILabel *lastLabel = [self.subviews lastObject];
    BOOL selected = (BOOL)objc_getAssociatedObject(lastLabel, DeleteBackwardItemSelectedKey);
    if (selected) {
        objc_removeAssociatedObjects(lastLabel);
        objc_setAssociatedObject(lastLabel, DeleteBackwardItemSelectedKey, @(NO), OBJC_ASSOCIATION_RETAIN);
        lastLabel.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
    }
    id delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(customSearchBar:textDidChange:)]) {
        [delegate customSearchBar:self textDidChange:self.textField.text];
    }
}

#pragma mark ======= PrivateMethods =======

- (void)setupSubviews{
    [self addSubview:self.textField];
    if (self.searchBarstyle == CustomSearchBarStyleSingleLine) {
        [self addSubview:self.scrollView];
    }
}

#pragma mark  追加单个元素
- (BOOL)addItem:(id<CustomSearchInputItemProtocol>)item{
    if (![self.dataArray containsObject:item]) {
        if ([self reachTheLimit]) {
            return NO;
        }
        [self.dataArray addObject:item];
        [self reloadSearchBar];
        return YES;
    }else{
        return NO;
    }
}

#pragma mark  从数组中追加多个元素
- (BOOL)addItemFromArray:(NSArray <id<CustomSearchInputItemProtocol>> *)items{
    if ([self reachTheLimit]) {
        return NO;
    }
    //存在问题
    [self.dataArray addObjectsFromArray:items];
    [self reloadSearchBar];
    return YES;
}

#pragma mark  移除单个元素
- (void)removeItem:(id<CustomSearchInputItemProtocol>)item{
    if ([self.dataArray containsObject:item]) {
        [self.dataArray removeObject:item];
        [self reloadSearchBar];
    }
}

#pragma mark  从数组中移除多个元素
- (void)removeItemsFromArray:(NSArray <id<CustomSearchInputItemProtocol>> *)items{
    [self.dataArray removeObjectsInArray:items];
    [self reloadSearchBar];
}

#pragma mark 刷新searchBar的布局
- (void)reloadSearchBar{
    self.textField.text = nil;
    if (self.searchBarstyle == CustomSearchBarStyleSingleLine) {//单行
        [self resetSingleLineSearchBar];
    }else{//多行
        [self resetMultipleLinesSearchBar];
    }
}

#pragma mark 判断有没有达到上限
- (BOOL)reachTheLimit{
    id dataSource = self.dataSource;
    if (dataSource && [dataSource respondsToSelector:@selector(maxInputItemsOfCustomSearchBar:)]) {
        NSInteger maxItems = [dataSource maxInputItemsOfCustomSearchBar:self];
        if (self.dataArray.count == maxItems) {
            return YES;
        }
    }
    return NO;
}

#pragma mark 刷新单行searchBar的布局
- (void)resetSingleLineSearchBar{
    //codes here:
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];//移除obj
    }];
     __block CGFloat left = 12;
    __block CGFloat top = 44/2-25/2;
    
    [self.dataArray enumerateObjectsUsingBlock:^(id<CustomSearchInputItemProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat labelWidth = [obj.inputItemtitle widthForFont:[UIFont systemFontOfSize:14]]+30;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, top, labelWidth, 25)];
        label.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        label.text = obj.inputItemtitle;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.layer.cornerRadius = 25/2;
        label.layer.masksToBounds = YES;
        [self.scrollView addSubview:label];
        left += labelWidth+12;
    }];
    [self setNeedsLayout];
}

#pragma mark 刷新多行searchBar的布局
- (void)resetMultipleLinesSearchBar{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != self.textField) {//不是自定义的textfield
            [obj removeFromSuperview];//移除obj
        }
    }];
    self.height = 44;
   __block CGFloat length = margin;
   __block CGFloat left = margin;
   __block CGFloat top = 44/2-25/2;
    [self.dataArray enumerateObjectsUsingBlock:^(id<CustomSearchInputItemProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat labelWidth = [obj.inputItemtitle widthForFont:[UIFont systemFontOfSize:14]]+30;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, top, (int)labelWidth, 25)];
        label.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        label.text = obj.inputItemtitle;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.layer.cornerRadius = 25/2;
        label.layer.masksToBounds = YES;
        [self addSubview:label];
        length = length + labelWidth + margin;
        if (length < self.width - 25) {
            left = length;
        }else{
            length = margin;
            left = margin;
            top  += 44;
            label.frame = CGRectMake(left, top, labelWidth, 25);
            length = length + labelWidth + margin;
            left = length;
            self.height += 44;
            //是否需要告知外界自身高度发生改变？
        }
    }];
}

#pragma mark ======= Getters && Setters =======

- (void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolder = placeHolder;
    self.textField.placeholder = _placeHolder;
}
- (void)setSearchIcon:(NSString *)searchIcon{
    _searchIcon = searchIcon;
    self.leftImgView.image = [UIImage imageNamed:searchIcon];
}

-(NSMutableArray<id<CustomSearchInputItemProtocol>> *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITextField *)textField{
    if (!_textField) {
        UITextField *textField = [[UITextField alloc]init];
        textField.placeholder = @"";
        textField.font = [UIFont systemFontOfSize:14];
        textField.returnKeyType = UIReturnKeySearch;
        textField.backgroundColor = [UIColor whiteColor];
        textField.delegate = self;
        textField.textColor = [UIColor blackColor];
        _textField = textField;
    }
    return _textField;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.bounces = YES;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}

- (UIImageView *)leftImgView{
    if (!_leftImgView) {
        _leftImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        _leftImgView.backgroundColor = [UIColor clearColor];
        _leftImgView.contentMode = UIViewContentModeCenter;
    }
    return _leftImgView;
}

#pragma mark ======= Others =======
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
